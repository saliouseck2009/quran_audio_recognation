import 'dart:convert';

import 'package:http/http.dart' as http;

class RecognitionRemoteDataSource {
  const RecognitionRemoteDataSource({
    required this.client,
    required this.baseUrl,
  });

  final http.Client client;
  final String baseUrl;

  Future<String> submitAudio({required String audioFilePath}) async {
    final uri = Uri.parse('$baseUrl/transcribe/async');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('audio_file', audioFilePath),
    );

    final streamedResponse = await request.send();
    final body = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 400) {
      throw HttpExceptionPayload(
        message: 'Upload failed (${streamedResponse.statusCode}): $body',
        code: streamedResponse.statusCode,
      );
    }

    final payload = jsonDecode(body) as Map<String, dynamic>;
    final jobId = payload['job_id'] as String?;
    if (jobId == null || jobId.isEmpty) {
      throw const HttpExceptionPayload(
        message: 'Invalid API response: missing job_id',
      );
    }

    return jobId;
  }

  Future<Map<String, dynamic>> getJobStatus({required String jobId}) async {
    final uri = Uri.parse('$baseUrl/jobs/$jobId/status');
    final response = await client.get(uri);

    if (response.statusCode >= 400) {
      throw HttpExceptionPayload(
        message: 'Status failed (${response.statusCode}): ${response.body}',
        code: response.statusCode,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMetadata({required String jobId}) async {
    final uri = Uri.parse('$baseUrl/jobs/$jobId/metadata');
    final response = await client.get(uri);

    if (response.statusCode >= 400) {
      throw HttpExceptionPayload(
        message: 'Metadata failed (${response.statusCode}): ${response.body}',
        code: response.statusCode,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class HttpExceptionPayload implements Exception {
  const HttpExceptionPayload({required this.message, this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'HttpExceptionPayload(message: $message, code: $code)';
}
