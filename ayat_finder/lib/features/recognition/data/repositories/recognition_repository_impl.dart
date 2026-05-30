import 'dart:io';

import 'package:ayat_finder/core/error/app_exception.dart';
import 'package:ayat_finder/core/state/data_state.dart';
import 'package:ayat_finder/features/recognition/data/datasources/recognition_remote_data_source.dart';
import 'package:ayat_finder/features/recognition/data/models/detection_result_model.dart';
import 'package:ayat_finder/features/recognition/data/models/job_status_model.dart';
import 'package:ayat_finder/features/recognition/domain/entities/detection_result.dart';
import 'package:ayat_finder/features/recognition/domain/entities/job_status.dart';
import 'package:ayat_finder/features/recognition/domain/repositories/recognition_repository.dart';

class RecognitionRepositoryImpl implements RecognitionRepository {
  const RecognitionRepositoryImpl(this._remoteDataSource);

  final RecognitionRemoteDataSource _remoteDataSource;

  @override
  Future<DataState<String>> submitAudio({required String audioFilePath}) async {
    try {
      final jobId = await _remoteDataSource.submitAudio(
        audioFilePath: audioFilePath,
      );
      return DataSuccess<String>(jobId);
    } on SocketException catch (exception) {
      return DataFailure<String>(
        NetworkException('Unable to reach backend: ${exception.message}'),
      );
    } on HttpExceptionPayload catch (exception) {
      return DataFailure<String>(
        ApiException(exception.message, code: exception.code),
      );
    } catch (_) {
      return const DataFailure<String>(
        UnknownException('Unexpected upload error'),
      );
    }
  }

  @override
  Future<DataState<JobStatus>> fetchJobStatus({required String jobId}) async {
    try {
      final json = await _remoteDataSource.getJobStatus(jobId: jobId);
      return DataSuccess<JobStatus>(JobStatusModel.fromJson(json));
    } on SocketException catch (exception) {
      return DataFailure<JobStatus>(
        NetworkException('Unable to reach backend: ${exception.message}'),
      );
    } on HttpExceptionPayload catch (exception) {
      return DataFailure<JobStatus>(
        ApiException(exception.message, code: exception.code),
      );
    } catch (_) {
      return const DataFailure<JobStatus>(
        UnknownException('Unexpected status error'),
      );
    }
  }

  @override
  Future<DataState<DetectionResult>> fetchMetadata({
    required String jobId,
  }) async {
    try {
      final json = await _remoteDataSource.getMetadata(jobId: jobId);
      return DataSuccess<DetectionResult>(
        DetectionResultModel.fromMetadataJson(jobId: jobId, json: json),
      );
    } on SocketException catch (exception) {
      return DataFailure<DetectionResult>(
        NetworkException('Unable to reach backend: ${exception.message}'),
      );
    } on HttpExceptionPayload catch (exception) {
      return DataFailure<DetectionResult>(
        ApiException(exception.message, code: exception.code),
      );
    } catch (_) {
      return const DataFailure<DetectionResult>(
        UnknownException('Unexpected metadata error'),
      );
    }
  }
}
