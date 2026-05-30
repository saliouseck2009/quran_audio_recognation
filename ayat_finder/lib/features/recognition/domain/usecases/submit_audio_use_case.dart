import 'package:ayat_finder/core/state/data_state.dart';
import 'package:ayat_finder/features/recognition/domain/repositories/recognition_repository.dart';

class SubmitAudioUseCase {
  const SubmitAudioUseCase(this._repository);

  final RecognitionRepository _repository;

  Future<DataState<String>> call({required String audioFilePath}) {
    return _repository.submitAudio(audioFilePath: audioFilePath);
  }
}
