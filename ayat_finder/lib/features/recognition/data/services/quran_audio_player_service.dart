import 'dart:async';
import 'dart:convert';

import 'package:ayat_finder/core/error/app_exception.dart';
import 'package:ayat_finder/features/recognition/domain/entities/ayah_detection.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class QuranAudioPlayerService {
  QuranAudioPlayerService({
    required this.client,
    AudioPlayer? audioPlayer,
    this.apiBaseUrl = 'https://api.alquran.cloud/v1',
  }) : _audioPlayer = audioPlayer ?? AudioPlayer() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      final processingState = state.processingState;
      final isPlaying =
          state.playing && processingState != ProcessingState.completed;
      _isPlayingController.add(isPlaying);
    });
  }

  final http.Client client;
  final String apiBaseUrl;
  final AudioPlayer _audioPlayer;

  late final StreamSubscription<PlayerState> _playerStateSubscription;
  final StreamController<bool> _isPlayingController =
      StreamController<bool>.broadcast();

  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  bool get isPlaying => _audioPlayer.playing;

  Future<void> playAyahs({
    required List<AyahDetection> ayahs,
    required String reciterId,
  }) async {
    if (ayahs.isEmpty) {
      throw const ValidationException('Aucun verset à lire.');
    }

    final sources = <AudioSource>[];
    for (final ayah in ayahs) {
      final url = await _fetchAyahAudioUrl(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        reciterId: reciterId,
      );
      if (url != null && url.isNotEmpty) {
        sources.add(AudioSource.uri(Uri.parse(url)));
      }
    }

    if (sources.isEmpty) {
      throw const ApiException('Aucun audio disponible pour cette récitation.');
    }

    await _audioPlayer.stop();
    await _audioPlayer.setAudioSources(sources);
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<String?> _fetchAyahAudioUrl({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final uri = Uri.parse(
      '$apiBaseUrl/ayah/$surahNumber:$ayahNumber/$reciterId',
    );
    final response = await client.get(uri);

    if (response.statusCode >= 400) {
      throw ApiException(
        'Impossible de charger l’audio (HTTP ${response.statusCode}).',
        code: response.statusCode,
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>?;
    final audio = data?['audio']?.toString();
    return audio;
  }

  Future<void> dispose() async {
    await _playerStateSubscription.cancel();
    await _audioPlayer.dispose();
    await _isPlayingController.close();
  }
}
