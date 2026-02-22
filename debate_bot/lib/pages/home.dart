import 'package:debate_bot/pages/chat.dart';
import 'package:flutter/material.dart';
import 'summary.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

enum Side { aff, neg }

class _HomeState extends State<Home> {
  final inputcontroller = TextEditingController();
  Side sideView = Side.aff;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Debate Bot"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              "Welcome to Debate Bot",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Practice debating, get talking points, and sharpen your arguments.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),

            SizedBox(height: 8),
            Image.asset(
              'assets/images/robot-bot-black-icon.png',
              height: 350,
              fit: BoxFit.contain,
            ),
            Spacer(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    "Need inspiration? Try one of these!",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 16),
                  _topicChip("School uniforms should be mandatory"),
                  _topicChip("Social media should be banned"),
                  _topicChip("College education should be free"),
                  _topicChip("Space exploration is worth the cost"),
                  _topicChip("Homework should be abolished"),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SegmentedButton<Side>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    segments: const <ButtonSegment<Side>>[
                      ButtonSegment<Side>(
                        value: Side.aff,
                        label: Text('Affirmative'),
                        icon: Icon(Icons.thumb_up_outlined),
                      ),
                      ButtonSegment<Side>(
                        value: Side.neg,
                        label: Text('Negative'),
                        icon: Icon(Icons.thumb_down_outlined),
                      ),
                    ],
                    selected: <Side>{sideView},
                    onSelectionChanged: (Set<Side> newSelection) {
                      setState(() {
                        sideView = newSelection.first;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: inputcontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Type your topic here to get started.",
                      ),
                      onSubmitted: (_) {
                        if (inputcontroller.text.trim().isEmpty) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              MeterDataHolder().setUserRating(50);
                              return Summary(
                                input: sideView == Side.aff
                                    ? "Affirmative on '${inputcontroller.text}'"
                                    : "Negative on '${inputcontroller.text}'",
                                rawInput: inputcontroller.text,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (inputcontroller.text.trim().isEmpty) return;
                        
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            MeterDataHolder().setUserRating(50);
                            return Summary(
                              input: sideView == Side.aff
                                  ? "Affirmative on '${inputcontroller.text}'"
                                  : "Negative on '${inputcontroller.text}'",
                              rawInput: inputcontroller.text,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
            Text(
              "Debate Bot isn't always accurate! Make sure you check before you do anything serious!",
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _topicChip(String topic) {
    return Row(
      children: [
        ActionChip(
          label: Text(topic),
          onPressed: () {
            inputcontroller.text = topic;
            sideView = Side.aff;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Summary(
                  input: sideView == Side.aff
                      ? "Affirmative on '${inputcontroller.text}'"
                      : "Negative on '${inputcontroller.text}'",
                  rawInput: inputcontroller.text,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
