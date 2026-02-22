import 'package:debate_bot/pages/chat.dart';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class Summary extends StatefulWidget {
  const Summary({super.key, required this.input, required this.rawInput});

  final String input;
  final String rawInput;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
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
                              Text(
                                "Topic - ${title_response == "NOTRESPONDED" ? "" : title_response}",
                                style: TextStyle(fontSize: 20),
                              ),
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
                              Text(
                                "Speech Outline",
                                style: TextStyle(fontSize: 20),
                              ),
                              outline_response != "NOTRESPONDED"
                                  ? Text(outline_response)
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
                                style: TextStyle(fontSize: 20),
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
