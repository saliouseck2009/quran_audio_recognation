import 'package:ayat_finder/core/state/data_state.dart';
import 'package:ayat_finder/features/recognition/domain/entities/detection_result.dart';
import 'package:ayat_finder/features/recognition/domain/entities/job_status.dart';

abstract interface class RecognitionRepository {
  Future<DataState<String>> submitAudio({required String audioFilePath});

  Future<DataState<JobStatus>> fetchJobStatus({required String jobId});

  Future<DataState<DetectionResult>> fetchMetadata({required String jobId});
}
