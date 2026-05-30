import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ayat_finder/core/error/app_exception.dart';
import 'package:ayat_finder/core/state/data_state.dart';
import 'package:ayat_finder/features/recognition/domain/entities/detection_result.dart';
import 'package:ayat_finder/features/recognition/domain/entities/history_entry.dart';
import 'package:ayat_finder/features/recognition/domain/entities/job_status.dart';
import 'package:ayat_finder/features/recognition/domain/usecases/get_job_status_use_case.dart';
import 'package:ayat_finder/features/recognition/domain/usecases/get_metadata_use_case.dart';
import 'package:ayat_finder/features/recognition/domain/usecases/submit_audio_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required SubmitAudioUseCase submitAudioUseCase,
    required GetJobStatusUseCase getJobStatusUseCase,
    required GetMetadataUseCase getMetadataUseCase,
    AudioRecorder? recorder,
  }) : _submitAudioUseCase = submitAudioUseCase,
       _getJobStatusUseCase = getJobStatusUseCase,
       _getMetadataUseCase = getMetadataUseCase,
       _recorder = recorder ?? AudioRecorder(),
       super(HomeState.initial());

  final SubmitAudioUseCase _submitAudioUseCase;
  final GetJobStatusUseCase _getJobStatusUseCase;
  final GetMetadataUseCase _getMetadataUseCase;
  final AudioRecorder _recorder;

  Timer? _recordingTimer;
  Timer? _pollTimer;

  AppPhase get phase => state.phase;
  bool get isPaused => state.isPaused;
  Duration get recordingDuration => state.recordingDuration;
  DetectionResult? get lastResult => state.lastResult;
  String? get errorMessage => state.errorMessage;
  List<HistoryEntry> get history => state.history;
  bool get audioReceived => state.audioReceived;
  bool get transcriptionDone => state.transcriptionDone;
  bool get matchingDone => state.matchingDone;

  Future<void> init() async {
    final status = await Permission.microphone.status;
    emit(
      state.copyWith(
        phase: status.isGranted ? AppPhase.idle : AppPhase.onboarding,
      ),
    );
  }

  Future<void> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      emit(state.copyWith(phase: AppPhase.idle, errorMessage: null));
      return;
    }

    _setFailure(const PermissionException('Permission micro refusée.'));
  }

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      _setFailure(
        const PermissionException('Permission micro non disponible.'),
      );
      return;
    }

    final temporaryDirectory = await getTemporaryDirectory();
    final filePath =
        '${temporaryDirectory.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: filePath,
    );

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(
        state.copyWith(
          recordingDuration:
              state.recordingDuration + const Duration(seconds: 1),
        ),
      );
    });

    emit(
      state.copyWith(
        phase: AppPhase.recording,
        recordingDuration: Duration.zero,
        isPaused: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> pauseOrResumeRecording() async {
    if (state.phase != AppPhase.recording) {
      return;
    }

    if (state.isPaused) {
      await _recorder.resume();
    } else {
      await _recorder.pause();
    }

    emit(state.copyWith(isPaused: !state.isPaused));
  }

  Future<void> cancelRecording() async {
    _recordingTimer?.cancel();
    await _recorder.stop();

    emit(
      state.copyWith(
        recordingDuration: Duration.zero,
        isPaused: false,
        phase: AppPhase.idle,
      ),
    );
  }

  Future<void> stopAndAnalyze() async {
    _recordingTimer?.cancel();
    final path = await _recorder.stop();

    if (path == null || path.isEmpty || !File(path).existsSync()) {
      _setFailure(const ValidationException('Audio invalide ou vide.'));
      return;
    }

    emit(
      state.copyWith(
        phase: AppPhase.analyzing,
        isPaused: false,
        audioReceived: false,
        transcriptionDone: false,
        matchingDone: false,
        errorMessage: null,
      ),
    );

    final submitState = await _submitAudioUseCase.call(audioFilePath: path);

    switch (submitState) {
      case DataSuccess<String>(:final data):
        emit(
          state.copyWith(
            currentJobId: data,
            audioReceived: true,
            transcriptionDone: false,
            matchingDone: false,
          ),
        );
        _startStatusPolling();
      case DataFailure<String>(:final exception):
        _setFailure(exception);
    }
  }

  void openHistory() {
    emit(state.copyWith(phase: AppPhase.history));
  }

  void backToIdle() {
    emit(state.copyWith(phase: AppPhase.idle));
  }

  void retry() {
    emit(state.copyWith(phase: AppPhase.idle, errorMessage: null));
  }

  void _startStatusPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final jobId = state.currentJobId;
      if (jobId == null) {
        return;
      }

      final statusState = await _getJobStatusUseCase.call(jobId: jobId);
      switch (statusState) {
        case DataFailure<JobStatus>(:final exception):
          _pollTimer?.cancel();
          _setFailure(exception);
          return;
        case DataSuccess<JobStatus>(:final data):
          if (data.status == 'processing') {
            emit(state.copyWith(transcriptionDone: true));
            return;
          }

          if (data.status == 'completed') {
            _pollTimer?.cancel();
            final metadataState = await _getMetadataUseCase.call(jobId: jobId);
            switch (metadataState) {
              case DataSuccess<DetectionResult>(:final data):
                _consumeResult(data);
              case DataFailure<DetectionResult>(:final exception):
                _setFailure(exception);
            }
            return;
          }

          if (data.status == 'failed') {
            _pollTimer?.cancel();
            _setFailure(ApiException(data.errorMessage ?? 'Analyse échouée'));
          }
      }
    });
  }

  void _consumeResult(DetectionResult result) {
    if (result.ayahs.isEmpty) {
      _setFailure(const ValidationException('Aucun verset reconnu.'));
      return;
    }

    final updatedHistory = <HistoryEntry>[
      HistoryEntry(createdAt: DateTime.now(), success: true, result: result),
      ...state.history,
    ];

    emit(
      state.copyWith(
        phase: AppPhase.result,
        matchingDone: true,
        lastResult: result,
        history: updatedHistory,
      ),
    );
  }

  void _setFailure(AppException exception) {
    log('HomeCubit failure: ${exception.message}', name: 'HomeCubit');

    final updatedHistory = <HistoryEntry>[
      HistoryEntry(
        createdAt: DateTime.now(),
        success: false,
        errorMessage: exception.message,
      ),
      ...state.history,
    ];

    emit(
      state.copyWith(
        phase: AppPhase.error,
        errorMessage: exception.message,
        history: updatedHistory,
      ),
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> close() async {
    _recordingTimer?.cancel();
    _pollTimer?.cancel();
    await _recorder.dispose();
    return super.close();
  }
}
