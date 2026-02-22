import 'package:debate_bot/pages/chat.dart';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';

const String defaultInstructions = '''
You are a debate bot that encourages critical thinking through debates.

You will be given a topic, a difficulty level, and a side in the next user message.

Your task is to formulate exactly seven arguments.
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
(Default difficulty: "Advanced")
(Default side: "Affirmative").
You use these inputs for your output. Go through the logic. Please do not simply return the inputs.
Use these defaults only if the corresponding value is not provided. But if they are not provided, you must use the defaults.
For example, if the topic and the sides are provided but not the difficulty, the difficulty must be set to advanced.
Please do not include any starting information like "Given these inputs,." There is no need to restate the topic, difficulty, or side.
Do not say: "Topic: <topic>, Difficulty: <difficulty>, Side: <side>". These things should be fairly obvious to the user.
''';

class Summary extends StatefulWidget {
  const Summary({super.key, required this.input, required this.rawInput});

  final String input;
  final String rawInput;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  String titleResponse = "NOTRESPONDED";
  String pointsResponse = "NOTRESPONDED";
  String outlineResponse = "NOTRESPONDED";
  String rebuttalResponse = "NOTRESPONDED";
  int _mobileTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _fetchPointsResponse();
    _fetchTitleResponse();
    _fetchOutlineResponse();
    _fetchRebuttalResponse();
  }

  Future<void> _fetchPointsResponse() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage: defaultInstructions,
        userMessage: widget.input,
      );
      setState(() {
        pointsResponse =
            result["choices"][0]["message"]["content"] ?? "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        pointsResponse = "Error: $e";
      });
    }
  }

  Future<void> _fetchTitleResponse() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage:
            "Please provide a very, very short summary of the debate topic. Include the aff/neg stance by adding it at the beginning (either 'Affirmative', or 'Negative'), followed by a colon, then the rest of the summary. Make sure to be precise, around 5 words max. Don't say anything like 'arguing for/against... topic', just say the topic. Please make it title format, and do NOT add a period. Make sure to capitalize the letters in strict title case.",
        userMessage: widget.input,
      );
      setState(() {
        titleResponse =
            result["choices"][0]["message"]["content"] ?? "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        titleResponse = "Error: $e";
      });
    }
  }

  Future<void> _fetchOutlineResponse() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage:
            "Please create a thorough speech outline for the given input and side of the debate. The side of the debate is important.It should have enough points to be 7 minutes. Please make it classic style (intro -> body (x paragraphs) -> conclusion) and do not, I repeat, do not be vague or ambiguous.",
        userMessage: widget.input,
      );
      //print(result["choices"][0]["message"]["content"]);
      setState(() {
        outlineResponse =
            result["choices"][0]["message"]["content"] ?? "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        outlineResponse = "Error: $e";
      });
    }
  }

  Future<void> _fetchRebuttalResponse() async {
    try {
      final result = await OpenAIService.askAI(
        systemMessage:
            "You are a debate assistant. You will be given a debate topic and stance in the user's message. Identify the strongest arguments the opposing side is likely to make. (If the side is affirmative, search through your training to find POTENTIAL arguments for negative, and vice versa). It's helpful for the user if you state what side you are rebutting at the very beginning. List them as concise points the user should be prepared to rebut, with newlines in between each point. Sort by strength/likelihood, with the most urgent ones at the beginning. Next, provide rebuttal points for the given arguments in a 'rebuttal' label under each argument , labeled 'R: [rebuttal for point above]' in the exact same order (so that each rebuttal clearly corresponds to a point made by the opposing side). In the end, it should look like #. [Arg] \n R. [Rebuttal] \n #. Arg2 \n R. Rebuttal2",
        userMessage: widget.input,
      );
      setState(() {
        rebuttalResponse =
            result["choices"][0]["message"]["content"] ?? "NOTRESPONDED";
      });
    } catch (e) {
      setState(() {
        rebuttalResponse = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "Dashboard - ${titleResponse == "NOTRESPONDED" ? widget.input : titleResponse}",
        ),
      ),
      // Only show bottom nav on narrow screens; avoid SizedBox.shrink() to prevent
      // "Cannot hit test a render box with no size" when the bar is hidden.
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 500
          ? BottomNavigationBar(
              currentIndex: _mobileTabIndex,
              onTap: (index) => setState(() => _mobileTabIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              ],
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;
          final infoCards = [
            _buildCard(
              context,
              "Title",
              titleResponse != "NOTRESPONDED"
                  ? Text("$titleResponse\nOriginal Statement: ${widget.input}")
                  : LinearProgressIndicator(),
            ),
            _buildCard(
              context,
              "Points",
              pointsResponse != "NOTRESPONDED"
                  ? Text(pointsResponse)
                  : LinearProgressIndicator(),
            ),
            _buildCard(
              context,
              "Speech Outline",
              outlineResponse != "NOTRESPONDED"
                  ? Text(outlineResponse)
                  : LinearProgressIndicator(),
            ),
            _buildCard(
              context,
              "Opposing Points and Their Rebuttals",
              rebuttalResponse != "NOTRESPONDED"
                  ? Text(rebuttalResponse)
                  : LinearProgressIndicator(),
            ),
          ]; // Every Single Dashboard Card

          if (isNarrow) {
            // This is the mobile UI
            return Column(
              children: [
                Expanded(
                  child:
                      _mobileTabIndex ==
                          0 //Tab management
                      ? SingleChildScrollView(
                          padding: EdgeInsets.all(8),
                          child: Column(children: infoCards),
                        )
                      : Padding(
                          padding: EdgeInsets.all(8),
                          child: ChatArea(
                            topic: widget.input,
                            rawTopic: widget.rawInput,
                          ),
                        ),
                ),
              ],
            );
          }

          return Padding(
            // This returns the desktop UI
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: infoCards),
                  ),
                ),
                Expanded(
                  child: ChatArea(
                    topic: widget.input,
                    rawTopic: widget.rawInput,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, Widget content) {
    //Helps you make every dashboard card
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 20)),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
