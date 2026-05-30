import 'package:ayat_finder/features/recognition/domain/entities/detection_result.dart';
import 'package:ayat_finder/features/recognition/domain/entities/history_entry.dart';
import 'package:flutter/foundation.dart';

enum AppPhase {
  onboarding,
  idle,
  recording,
  analyzing,
  result,
  error,
  history,
  settings,
}

@immutable
class HomeState {
  HomeState({
    required this.phase,
    required this.isPaused,
    required this.recordingDuration,
    required this.lastResult,
    required this.errorMessage,
    required List<HistoryEntry> history,
    required this.audioReceived,
    required this.transcriptionDone,
    required this.matchingDone,
    required this.currentJobId,
    required this.selectedReciterId,
    required this.isAudioLoading,
    required this.isResultAudioPlaying,
  }) : history = List<HistoryEntry>.unmodifiable(history);

  factory HomeState.initial() {
    return HomeState(
      phase: AppPhase.onboarding,
      isPaused: false,
      recordingDuration: Duration.zero,
      lastResult: null,
      errorMessage: null,
      history: <HistoryEntry>[],
      audioReceived: false,
      transcriptionDone: false,
      matchingDone: false,
      currentJobId: null,
      selectedReciterId: '',
      isAudioLoading: false,
      isResultAudioPlaying: false,
    );
  }

  final AppPhase phase;
  final bool isPaused;
  final Duration recordingDuration;
  final DetectionResult? lastResult;
  final String? errorMessage;
  final List<HistoryEntry> history;
  final bool audioReceived;
  final bool transcriptionDone;
  final bool matchingDone;
  final String? currentJobId;
  final String selectedReciterId;
  final bool isAudioLoading;
  final bool isResultAudioPlaying;

  static const Object _unset = Object();

  HomeState copyWith({
    AppPhase? phase,
    bool? isPaused,
    Duration? recordingDuration,
    Object? lastResult = _unset,
    Object? errorMessage = _unset,
    List<HistoryEntry>? history,
    bool? audioReceived,
    bool? transcriptionDone,
    bool? matchingDone,
    Object? currentJobId = _unset,
    String? selectedReciterId,
    bool? isAudioLoading,
    bool? isResultAudioPlaying,
  }) {
    return HomeState(
      phase: phase ?? this.phase,
      isPaused: isPaused ?? this.isPaused,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      lastResult: identical(lastResult, _unset)
          ? this.lastResult
          : lastResult as DetectionResult?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      history: history ?? this.history,
      audioReceived: audioReceived ?? this.audioReceived,
      transcriptionDone: transcriptionDone ?? this.transcriptionDone,
      matchingDone: matchingDone ?? this.matchingDone,
      currentJobId: identical(currentJobId, _unset)
          ? this.currentJobId
          : currentJobId as String?,
      selectedReciterId: selectedReciterId ?? this.selectedReciterId,
      isAudioLoading: isAudioLoading ?? this.isAudioLoading,
      isResultAudioPlaying: isResultAudioPlaying ?? this.isResultAudioPlaying,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is HomeState &&
        other.phase == phase &&
        other.isPaused == isPaused &&
        other.recordingDuration == recordingDuration &&
        other.lastResult == lastResult &&
        other.errorMessage == errorMessage &&
        _listEquals(other.history, history) &&
        other.audioReceived == audioReceived &&
        other.transcriptionDone == transcriptionDone &&
        other.matchingDone == matchingDone &&
        other.currentJobId == currentJobId &&
        other.selectedReciterId == selectedReciterId &&
        other.isAudioLoading == isAudioLoading &&
        other.isResultAudioPlaying == isResultAudioPlaying;
  }

  @override
  int get hashCode {
    return Object.hash(
      phase,
      isPaused,
      recordingDuration,
      lastResult,
      errorMessage,
      Object.hashAll(history),
      audioReceived,
      transcriptionDone,
      matchingDone,
      currentJobId,
      selectedReciterId,
      isAudioLoading,
      isResultAudioPlaying,
    );
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}
