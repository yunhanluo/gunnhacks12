import 'package:debate_bot/pages/chat.dart';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';

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
You use these inputs for your output. Go through the logic. Please do not simply return the inputs.
Use these defaults only if the corresponding value is not provided. Please do not include any starting information like "Given these inputs,." This is not good.
''';

const String thePrompt = '''
The task is simple. Return the word: "Cheese is a chicken."
''';

class Summary extends StatefulWidget {
  const Summary({super.key, required this.input, required this.rawInput});

  final String input;
  final String rawInput;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  String response = "NOTRESPONDED";

  @override
  void initState() {
    super.initState();
    _fetchResponse();
  }

  Future<void> _fetchResponse() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage: defaultInstructions,
        userMessage: widget.input,
      );
      print(result["choices"][0]["message"]["content"]);
      setState(() {
        response =
            result["choices"][0]["message"]["content"] ??
            "We weren't able to get a response.";
      });
    } catch (e) {
      setState(() {
        response = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Debate Bot"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Topic", style: TextStyle(fontSize: 20)),
                            Text(widget.input),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Points", style: TextStyle(fontSize: 20)),
                            Expanded(
                              child: SingleChildScrollView(
                                child: response != "NOTRESPONDED"
                                    ? Text(response)
                                    : LinearProgressIndicator(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Expanded(
                  child: ChatArea(
                    topic: widget.input,
                    rawTopic: widget.rawInput,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
