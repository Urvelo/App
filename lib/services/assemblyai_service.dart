import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AssemblyAiService {
  AssemblyAiService({required this.apiKey});

  final String apiKey;
  final _base = 'https://api.assemblyai.com/v2';

  Map<String, String> get _headers => {
        'authorization': apiKey,
        'content-type': 'application/json',
      };

  Future<String> uploadFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ArgumentError('File does not exist: $filePath');
    }

    final bytes = await file.readAsBytes();
    final response = await http.post(
      Uri.parse('$_base/upload'),
      headers: {
        'authorization': apiKey,
        'content-type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode ~/ 100 != 2) {
      throw HttpException('AssemblyAI upload failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['upload_url'] as String;
  }

  Future<String> createTranscript(String audioUrl) async {
    final response = await http.post(
      Uri.parse('$_base/transcript'),
      headers: _headers,
      body: jsonEncode({
        'audio_url': audioUrl,
        'language_detection': true,
        'punctuate': true,
        'format_text': true,
      }),
    );

    if (response.statusCode ~/ 100 != 2) {
      throw HttpException('AssemblyAI create transcript failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<String> waitForTranscriptText(
    String transcriptId, {
    Duration interval = const Duration(seconds: 8),
    int maxPollCount = 900,
  }) async {
    for (var i = 0; i < maxPollCount; i++) {
      final response = await http.get(
        Uri.parse('$_base/transcript/$transcriptId'),
        headers: _headers,
      );

      if (response.statusCode ~/ 100 != 2) {
        throw HttpException(
          'AssemblyAI polling failed (${response.statusCode}): ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'unknown';

      if (status == 'completed') {
        return data['text'] as String? ?? '';
      }

      if (status == 'error') {
        throw StateError('AssemblyAI error: ${data['error'] ?? 'unknown'}');
      }

      await Future<void>.delayed(interval);
    }

    throw TimeoutException('Transcription timed out after long polling.');
  }
}
