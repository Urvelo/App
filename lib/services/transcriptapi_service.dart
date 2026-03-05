import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TranscriptApiService {
  TranscriptApiService({required this.apiKey});

  final String apiKey;
  static const _base = 'https://transcriptapi.com/api/v2';

  Future<String> getYoutubeTranscriptText(String videoOrUrl) async {
    final uri = Uri.parse('$_base/youtube/transcript').replace(
      queryParameters: {
        'video_url': videoOrUrl,
        'format': 'text',
        'include_timestamp': 'false',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json, text/plain;q=0.9',
      },
    );

    if (response.statusCode ~/ 100 != 2) {
      throw HttpException('TranscriptAPI request failed: ${response.body}');
    }

    final body = response.body.trim();
    if (body.isEmpty) {
      return '';
    }

    // API can return plain text directly or JSON depending on format/options.
    if (!body.startsWith('{') && !body.startsWith('[')) {
      return body;
    }

    final parsed = jsonDecode(body);
    if (parsed is Map<String, dynamic>) {
      if (parsed['text'] is String) {
        return (parsed['text'] as String).trim();
      }
      final transcript = parsed['transcript'];
      if (transcript is List) {
        final lines = transcript
            .map((e) => (e is Map<String, dynamic> ? e['text'] : null))
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        return lines.join(' ');
      }
    }

    throw StateError('TranscriptAPI response format not recognized.');
  }
}
