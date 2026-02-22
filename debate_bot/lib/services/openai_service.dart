import 'package:debate_bot/pages/chat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class OpenAIService {
  static final String _apiKey = dotenv.env["OPENAI_API_KEY"] ?? 'fallback';

  static Future<dynamic> askAI({
    String? systemMessage,
    String? userMessage,
    List<Message>? userMessages,
    double? penalty,
    Map? responseFormat,
  }) async {
    List<Map<String, String>> messageAdditions = [];
    if (userMessages != null) {
      for (Message message in userMessages) {
        if (message.sender == Sender.system) continue;

        messageAdditions.add({
          'role': message.sender == Sender.human ? "user" : "assistant",
          'content': message.message,
        });
      }
    }

    final evalResponse = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages':
            <Map<String, String>>[
              if (systemMessage != null)
                {'role': 'system', 'content': systemMessage},
              if (userMessage != null) {'role': 'user', 'content': userMessage},
            ] +
            messageAdditions,
        'max_tokens': 500,
        'temperature': 0.7,
        'frequency_penalty': ?penalty,
        'response_format': ?responseFormat,
      }),
    );

    return jsonDecode(evalResponse.body);
  }
}
