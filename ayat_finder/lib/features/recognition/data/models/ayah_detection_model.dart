import 'package:ayat_finder/features/recognition/domain/entities/ayah_detection.dart';

class AyahDetectionModel extends AyahDetection {
  const AyahDetectionModel({
    required super.surahNumber,
    required super.ayahNumber,
    required super.arabicText,
    super.confidence,
  });

  factory AyahDetectionModel.fromJson(Map<String, dynamic> json) {
    return AyahDetectionModel(
      surahNumber: (json['surah_number'] as num?)?.toInt() ?? 0,
      ayahNumber: (json['ayah_number'] as num?)?.toInt() ?? 0,
      arabicText:
          (json['ayah_text_tashkeel'] ??
                  json['ayah_text'] ??
                  json['text'] ??
                  '')
              .toString(),
      confidence: (json['match_confidence'] as num?)?.toDouble(),
    );
  }
}
