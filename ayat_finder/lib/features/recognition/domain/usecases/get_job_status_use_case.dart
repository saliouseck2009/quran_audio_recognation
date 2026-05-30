import 'package:ayat_finder/core/state/data_state.dart';
import 'package:ayat_finder/features/recognition/domain/entities/job_status.dart';
import 'package:ayat_finder/features/recognition/domain/repositories/recognition_repository.dart';

class GetJobStatusUseCase {
  const GetJobStatusUseCase(this._repository);

  final RecognitionRepository _repository;

  Future<DataState<JobStatus>> call({required String jobId}) {
    return _repository.fetchJobStatus(jobId: jobId);
  }
}
