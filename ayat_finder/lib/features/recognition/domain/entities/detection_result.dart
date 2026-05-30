import 'package:ayat_finder/features/recognition/domain/entities/ayah_detection.dart';
import 'package:flutter/foundation.dart';

@immutable
class DetectionResult {
  DetectionResult({
    required this.jobId,
    required List<AyahDetection> ayahs,
    required this.surahNumber,
    required this.transcription,
  }) : ayahs = List<AyahDetection>.unmodifiable(ayahs);

  final String jobId;
  final List<AyahDetection> ayahs;
  final int? surahNumber;
  final String transcription;

  DetectionResult copyWith({
    String? jobId,
    List<AyahDetection>? ayahs,
    int? surahNumber,
    String? transcription,
  }) {
    return DetectionResult(
      jobId: jobId ?? this.jobId,
      ayahs: ayahs ?? this.ayahs,
      surahNumber: surahNumber ?? this.surahNumber,
      transcription: transcription ?? this.transcription,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DetectionResult &&
        other.jobId == jobId &&
        _listEquals(other.ayahs, ayahs) &&
        other.surahNumber == surahNumber &&
        other.transcription == transcription;
  }

  @override
  int get hashCode {
    return Object.hash(
      jobId,
      Object.hashAll(ayahs),
      surahNumber,
      transcription,
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
