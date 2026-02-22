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
  String title_response = "NOTRESPONDED";
  String points_response = "NOTRESPONDED";
  String outline_response = "NOTRESPONDED";

  @override
  void initState() {
    super.initState();

    _fetchpoints_response();
    _fetchtitle_response();
    _fetchoutline_response();
  }

  Future<void> _fetchpoints_response() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage:
            "You are to be a debate assistant. Please provide good debate points in the format - [point 1 goes here. just put the point directly in here, no prefixing or anything of that sort] \n - [point 2 goes here]\n... Please make the points concise but easily understandable. Aim for quantity, but please sort by quality as well.",
        userMessage: widget.input,
      );
      setState(() {
        points_response =
            result["choices"][0]["message"]["content"] ?? "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        points_response = "Error: $e";
      });
    }
  }

  Future<void> _fetchtitle_response() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage:
            "Please provide a very, very short summary of the debate topic. Include the aff/neg stance by adding it at the beginning (either 'Affirmative', or 'Negative'), followed by a colon, then the rest of the summary. Make sure to be precise, around 5 words max. Don't say anything like 'arguing for/against... topic', just say the topic. Please make it title format, and do NOT add a period.",
        userMessage: widget.input,
      );
      setState(() {
        title_response =
            result["choices"][0]["message"]["content"] ?? "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        title_response = "Error: $e";
      });
    }
  }

  Future<void> _fetchoutline_response() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage:
            "You are a debate speech outline assistant. Given a debate topic and stance, produce a classically formatted speech outline with the following structure:\nI. Introduction\n   A. Hook\n   B. Thesis statement\nII. Body\n   A. First argument\n      1. Evidence/support\n   B. Second argument\n      1. Evidence/support\n   C. Third argument\n      1. Evidence/support\nIII. Rebuttal\n   A. Anticipated counterargument\n   B. Response\nIV. Conclusion\n   A. Summary\n   B. Closing statement\n\nKeep each point concise but clear.",
        userMessage: widget.input,
      );
      print(result["choices"][0]["message"]["content"]);
      setState(() {
        outline_response =
            result["choices"][0]["message"]["content"] ?? "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        outline_response = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "Dashboard - ${title_response == "NOTRESPONDED" ? widget.input : title_response}",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                              Text("Points", style: TextStyle(fontSize: 20)),
                              points_response != "NOTRESPONDED"
                                  ? Text(points_response)
                                  : LinearProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox.square(dimension: 8),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Standing",
                              style: TextStyle(fontSize: 30),
                            ),
                            MeterArea(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ChatArea(topic: widget.input, rawTopic: widget.rawInput),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
