import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class OpenAIService {
  static final String _apiKey = dotenv.env["OPENAI_API_KEY"] ?? 'fallback';

  static Future<dynamic> askAI({
    String? systemMessage,
    String? userMessage,
  }) async {
    final evalResponse = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': <Map<String, String>>[
            if (systemMessage != null)
              {'role': 'system', 'content': systemMessage},
            if (userMessage != null)
              {'role': 'user', 'content': userMessage},
          ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    return jsonDecode(evalResponse.body);
  }
}
