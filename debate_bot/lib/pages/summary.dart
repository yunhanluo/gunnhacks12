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

  @override
  void initState() {
    super.initState();
    _fetchpoints_response();
    _fetchtitle_response();
  }

  Future<void> _fetchpoints_response() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage: "You are to be a debate assistant. Please provide good debate points in the format - [point 1 goes here. just put the point directly in here, no prefixing or anything of that sort] \n - [point 2 goes here]\n... Please make the points concise but easily understandable. Aim for quantity, but please sort by quality as well.",
        userMessage: widget.input,
      );
      setState(() {
        points_response =
            result["choices"][0]["message"]["content"] ??
            "NOTRESPONDED";
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
        systemMessage: "Please provide a very, very short summary of the debate topic. Include the aff/neg stance by adding it at the beginning, followed by a colon, then the rest of the summary. Make sure to be precise, around 5 words max. Don't say anything like 'arguing for/against... topic', just say the topic. Please make it title format, and do NOT add a period.",
        userMessage: widget.input,
      );
      setState(() {
        title_response =
            result["choices"][0]["message"]["content"] ??
            "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        title_response = "Error: $e";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Dashboard - ${title_response == "NOTRESPONDED" ? widget.input : title_response}"),
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
                            Text("Topic - ${title_response == "NOTRESPONDED" ? "" : title_response}", style: TextStyle(fontSize: 20)),
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
                            points_response != "NOTRESPONDED" ? Text(points_response) : LinearProgressIndicator(),
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
                child: ChatArea(topic: widget.input, rawTopic: widget.rawInput),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
