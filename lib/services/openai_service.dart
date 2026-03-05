import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class OpenAiService {
  OpenAiService({required this.apiKey});

  final String apiKey;

  Future<String> improveFinnishTranscript(String inputText) async {
    if (inputText.trim().isEmpty) {
      return inputText;
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'temperature': 0.2,
        'messages': [
          {
            'role': 'system',
            'content':
                'You improve transcript text. Fix spelling, punctuation and readability while preserving meaning. Keep original language.',
          },
          {
            'role': 'user',
            'content': inputText,
          },
        ],
      }),
    );

    if (response.statusCode ~/ 100 != 2) {
      throw HttpException('OpenAI request failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>? ?? [];
    if (choices.isEmpty) {
      throw StateError('OpenAI returned no choices.');
    }

    final first = choices.first as Map<String, dynamic>;
    final message = first['message'] as Map<String, dynamic>? ?? {};
    final content = message['content'];

    if (content is String) {
      return content.trim();
    }

    if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        if (part is Map<String, dynamic>) {
          final text = part['text'];
          if (text is String) {
            buffer.writeln(text);
          }
        }
      }
      return buffer.toString().trim();
    }

    throw StateError('OpenAI response format not recognized.');
  }
}
