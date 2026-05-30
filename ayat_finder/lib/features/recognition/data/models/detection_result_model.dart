import 'package:ayat_finder/features/recognition/data/models/ayah_detection_model.dart';
import 'package:ayat_finder/features/recognition/domain/entities/detection_result.dart';

class DetectionResultModel extends DetectionResult {
  DetectionResultModel({
    required super.jobId,
    required super.ayahs,
    required super.surahNumber,
    required super.transcription,
  });

  factory DetectionResultModel.fromMetadataJson({
    required String jobId,
    required Map<String, dynamic> json,
  }) {
    final ayahsJson = (json['ayahs'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    final ayahs = ayahsJson
        .map(AyahDetectionModel.fromJson)
        .toList(growable: false);

    return DetectionResultModel(
      jobId: jobId,
      ayahs: ayahs,
      surahNumber: (json['surah_number'] as num?)?.toInt(),
      transcription: (json['transcription'] ?? '').toString(),
    );
  }
}
