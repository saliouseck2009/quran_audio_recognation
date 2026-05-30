import 'package:flutter/foundation.dart';

@immutable
class JobStatus {
  const JobStatus({required this.status, this.errorMessage});

  final String status;
  final String? errorMessage;

  JobStatus copyWith({String? status, String? errorMessage}) {
    return JobStatus(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is JobStatus &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, errorMessage);
}
