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

  void _navigateToSummary() {
    if (inputcontroller.text.trim().isEmpty) return;

    MeterDataHolder().setUserRating(50);
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
  }

  Widget _buildSegmentedButton() {
    return SegmentedButton<Side>(
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
          label: Text('Affirmative', style: TextStyle(fontSize: 16)),
          icon: Icon(Icons.thumb_up_outlined),
        ),
        ButtonSegment<Side>(
          value: Side.neg,
          label: Text('Negative', style: TextStyle(fontSize: 16)),
          icon: Icon(Icons.thumb_down_outlined),
        ),
      ],
      selected: <Side>{sideView},
      onSelectionChanged: (Set<Side> newSelection) {
        setState(() {
          sideView = newSelection.first;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Debate Bot - Home"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;
          return Center(
            child: Column(
              children: [
                SizedBox(height: 24),
                Image.asset(
                  'assets/images/robot-bot-black-icon.png',
                  height: isNarrow ? 150 : 350,
                  fit: BoxFit.contain,
                ),
                Text(
                  "Welcome to Debate Bot",
                  style: TextStyle(
                    fontSize: isNarrow ? 22 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Get Talking Points\nPractice Debating\nMake Better Arguments\nWin",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                Spacer(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _topicChip("School uniforms should be mandatory"),
                      _topicChip("Social media should be banned"),
                      _topicChip("College education should be free"),
                      _topicChip("Space exploration is worth the cost"),
                      _topicChip("Homework should be abolished"),
                      _topicChip("AI should be banned"),
                      _topicChip("Phones should be banned for students"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: isNarrow
                      ? Column(
                          children: [
                            _buildSegmentedButton(),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: inputcontroller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Type your topic here.",
                                    ),
                                    onSubmitted: (_) => _navigateToSummary(),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: _navigateToSummary,
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            _buildSegmentedButton(),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: inputcontroller,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Type your topic here to get started.",
                                ),
                                onSubmitted: (_) => _navigateToSummary(),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _navigateToSummary,
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Debate Bot isn't always accurate! Make sure you check before you do anything serious!",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        },
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
            _navigateToSummary();
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
