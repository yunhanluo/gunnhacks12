import 'package:debate_bot/pages/chat.dart';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class Summary extends StatefulWidget {
  const Summary({super.key, required this.input});

  final String input;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  String response = "Please give us one second while we process your request...";

  @override
  void initState() {
    super.initState();
    _fetchResponse();
  }

  Future<void> _fetchResponse() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage: "You are to be a debate assistant. Please provide good debate points in the format -[debatept1] \n -[debatept2]\n...",
        userMessage: widget.input,
      );
      setState(() {
        response = result['choices'][0]['message']['content'] ?? "We weren't able to get a response.";
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
                            Text("Response", style: TextStyle(fontSize: 20)),
                            Text(response),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ChatArea(),
            ),
          ],
        ),
      ),
    );
  }
}
