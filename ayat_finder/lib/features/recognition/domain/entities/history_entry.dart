import 'package:ayat_finder/features/recognition/domain/entities/detection_result.dart';
import 'package:flutter/foundation.dart';

@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.createdAt,
    required this.success,
    this.result,
    this.errorMessage,
  });

  final DateTime createdAt;
  final bool success;
  final DetectionResult? result;
  final String? errorMessage;

  HistoryEntry copyWith({
    DateTime? createdAt,
    bool? success,
    DetectionResult? result,
    String? errorMessage,
  }) {
    return HistoryEntry(
      createdAt: createdAt ?? this.createdAt,
      success: success ?? this.success,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is HistoryEntry &&
        other.createdAt == createdAt &&
        other.success == success &&
        other.result == result &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(createdAt, success, result, errorMessage);
  }
}
