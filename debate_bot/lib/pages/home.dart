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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Debate Bot"),
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
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
                        hintText:
                            "Let's get started! Type your topic here to continue.",
                      ),
                      onSubmitted: (_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Summary(
                              input: sideView == Side.aff ? "Affirmative on '${inputcontroller.text}'" : "Negative on '${inputcontroller.text}'",
                              rawInput: inputcontroller.text,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      Navigator.push(
                        context,
                          MaterialPageRoute(
                            builder: (context) => Summary(
                              input: sideView == Side.aff ? "Affirmative on '${inputcontroller.text}'" : "Negative on '${inputcontroller.text}'",
                              rawInput: inputcontroller.text,
                            ),
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
}
