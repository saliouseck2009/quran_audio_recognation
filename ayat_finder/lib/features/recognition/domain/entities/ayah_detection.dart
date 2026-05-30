import 'package:flutter/foundation.dart';

@immutable
class AyahDetection {
  const AyahDetection({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    this.confidence,
  });

  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final double? confidence;

  AyahDetection copyWith({
    int? surahNumber,
    int? ayahNumber,
    String? arabicText,
    double? confidence,
  }) {
    return AyahDetection(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      arabicText: arabicText ?? this.arabicText,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AyahDetection &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber &&
        other.arabicText == arabicText &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return Object.hash(surahNumber, ayahNumber, arabicText, confidence);
  }
}
