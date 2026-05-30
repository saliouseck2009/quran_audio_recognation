import 'package:ayat_finder/core/state/data_state.dart';
import 'package:ayat_finder/features/recognition/domain/entities/detection_result.dart';
import 'package:ayat_finder/features/recognition/domain/repositories/recognition_repository.dart';

class GetMetadataUseCase {
  const GetMetadataUseCase(this._repository);

  final RecognitionRepository _repository;

  Future<DataState<DetectionResult>> call({required String jobId}) {
    return _repository.fetchMetadata(jobId: jobId);
  }
}
