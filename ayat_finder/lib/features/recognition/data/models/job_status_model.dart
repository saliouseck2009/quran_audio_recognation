import 'package:ayat_finder/features/recognition/domain/entities/job_status.dart';

class JobStatusModel extends JobStatus {
  const JobStatusModel({required super.status, super.errorMessage});

  factory JobStatusModel.fromJson(Map<String, dynamic> json) {
    return JobStatusModel(
      status: (json['status'] ?? '').toString(),
      errorMessage: json['error_message']?.toString(),
    );
  }
}
