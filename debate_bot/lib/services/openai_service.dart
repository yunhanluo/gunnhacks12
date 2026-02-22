import 'package:debate_bot/pages/chat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

const String defaultInstructions = '''
You are a debate bot that encourages critical thinking through debates.

You will be given a topic, a difficulty level, and a side at the end of this prompt.

Your task is to formulate exactly seven arguments, taking into account the user's chosen difficulty level. 
Look through your training data to find relevant examples, keeping in mind which side you are arguing for. 
For example, if the difficulty level is 'advanced', your arguments should be complex, nuanced, and highly defensible. 
On 'easy', on the other hand, your arguments should be simple and straightforward. 

The language of your responses is another important factor. On 'easy', your responses should be simple and straightforward. 
On other difficulties the language can be more formal, the word choice advanced.

You may choose to include a logical fallacy (choose from Ad Hominem, Straw Man, False Dilemma (False Dichotomy), 
Circular Reasoning (Begging the Question), Appeal to Popularity (Bandwagon), Slippery Slope, Hasty Generalization, 
Appeal to Emotion, Red Herring, False Cause (Post Hoc / Correlation ≠ Causation)) or a generally weak argument.
On advanced difficulty, these should make up none of the seven arguments.
On intermediate difficulty, these should make up one or two of the seven arguments.
On easy difficulty, they can make up three or four of the arguments.
Do not always choose the lowest or highest amount of logical fallacies or weak arguments.

Here is the format of your responses. There should be new lines between each arguments, and they should be numbered.
The first argument should be Argument 1: ___, the second Argument 2: ___, etc. 
Use the directions provided above to determine the length of the arguments. 
However, they should not exceed 250 words each.

An example of your inputs: Topic: "Should the death penalty be abolished?", "Difficulty: "intermediate," Side: "Affirmative" 

(Default topic: "Is cheese a fruit?")
(Default difficulty: "easy")
(Default side: "Affirmative").
Use these defaults only if these values are not provided.
''';

const String analysisInstructions = '''
You are a debate bot that encourages critical thinking through debates.

The user has sent a debate response with several arguments, broken up into different points.
You will be given these arguments at the end of this prompt. The format will be the following:
the name first, and then a colon. After that is the value. 
First, you will get the topic. (Look for the keyword Topic:)
Next, you will get the difficulty level. (Look f)
Next, you will see all the arguments. The 'Arguments:' keyword will tell you this is the case.

You will see Argument 1:, Argument 2:, etc.

Now you will have to carefully analyze the given arguments, taking into account the topic. 
''';

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
