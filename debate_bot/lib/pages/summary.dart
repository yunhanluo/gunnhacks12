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
  String response = "NOTRESPONDED";

  @override
  void initState() {
    super.initState();
    _fetchResponse();
  }

  Future<void> _fetchResponse() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage:
            "You are to be a debate assistant. Please provide good debate points in the format - [point 1 goes here. just put the point directly in here, no prefixing or anything of that sort] \n - [point 2 goes here]\n... Please make the points concise but easily understandable. Aim for quantity, but please sort by quality as well.",
        userMessage: widget.input,
      );
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
                            response != "NOTRESPONDED"
                                ? Text(response)
                                : LinearProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox.square(dimension: 12),
                  Expanded(child: MeterArea()),
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
