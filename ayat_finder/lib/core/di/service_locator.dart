import 'package:ayat_finder/core/network/app_config.dart';
import 'package:ayat_finder/features/recognition/data/datasources/recognition_remote_data_source.dart';
import 'package:ayat_finder/features/recognition/data/repositories/recognition_repository_impl.dart';
import 'package:ayat_finder/features/recognition/data/services/quran_audio_player_service.dart';
import 'package:ayat_finder/features/recognition/data/services/reciter_preferences_service.dart';
import 'package:ayat_finder/features/recognition/domain/repositories/recognition_repository.dart';
import 'package:ayat_finder/features/recognition/domain/usecases/get_job_status_use_case.dart';
import 'package:ayat_finder/features/recognition/domain/usecases/get_metadata_use_case.dart';
import 'package:ayat_finder/features/recognition/domain/usecases/submit_audio_use_case.dart';
import 'package:ayat_finder/features/recognition/presentation/cubit/home_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (!getIt.isRegistered<http.Client>()) {
    getIt.registerLazySingleton<http.Client>(http.Client.new);
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  if (!getIt.isRegistered<ReciterPreferencesService>()) {
    getIt.registerLazySingleton<ReciterPreferencesService>(
      () => ReciterPreferencesService(getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<QuranAudioPlayerService>()) {
    getIt.registerLazySingleton<QuranAudioPlayerService>(
      () => QuranAudioPlayerService(client: getIt<http.Client>()),
    );
  }

  if (!getIt.isRegistered<RecognitionRemoteDataSource>()) {
    getIt.registerLazySingleton<RecognitionRemoteDataSource>(
      () => RecognitionRemoteDataSource(
        client: getIt<http.Client>(),
        baseUrl: kApiBaseUrl,
      ),
    );
  }

  if (!getIt.isRegistered<RecognitionRepository>()) {
    getIt.registerLazySingleton<RecognitionRepository>(
      () => RecognitionRepositoryImpl(getIt<RecognitionRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<SubmitAudioUseCase>()) {
    getIt.registerLazySingleton<SubmitAudioUseCase>(
      () => SubmitAudioUseCase(getIt<RecognitionRepository>()),
    );
  }

  if (!getIt.isRegistered<GetJobStatusUseCase>()) {
    getIt.registerLazySingleton<GetJobStatusUseCase>(
      () => GetJobStatusUseCase(getIt<RecognitionRepository>()),
    );
  }

  if (!getIt.isRegistered<GetMetadataUseCase>()) {
    getIt.registerLazySingleton<GetMetadataUseCase>(
      () => GetMetadataUseCase(getIt<RecognitionRepository>()),
    );
  }

  if (getIt.isRegistered<HomeCubit>()) {
    getIt.unregister<HomeCubit>();
  }
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      submitAudioUseCase: getIt<SubmitAudioUseCase>(),
      getJobStatusUseCase: getIt<GetJobStatusUseCase>(),
      getMetadataUseCase: getIt<GetMetadataUseCase>(),
      reciterPreferencesService: getIt<ReciterPreferencesService>(),
      quranAudioPlayerService: getIt<QuranAudioPlayerService>(),
    ),
  );
}
