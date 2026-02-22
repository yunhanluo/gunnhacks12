import 'dart:convert';
import 'package:debate_bot/services/openai_service.dart';
import 'package:flutter/material.dart';

class ChatArea extends StatefulWidget {
  const ChatArea({super.key, required this.topic, required this.rawTopic, required this.difficulty});

  final String topic;
  final String rawTopic;
  final String difficulty;

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final inputController = TextEditingController();
  final inputFocus = FocusNode();

  final List<Message> _messages = [];
  final List<int> successHistory = [];
  final ScrollController scrollController = ScrollController();

  bool awaitingAi = false;

  @override
  void dispose() {
    inputFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Current Standing", style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                MeterArea()
              ],
            ),
          ),
        ), //Moved the Standing card to a better place. We cant use buildcard here so its manually created.
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              if (index < _messages.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: _messages[index],
                );
              } else {
                return null;
              }
            },
            controller: scrollController,
            scrollDirection: Axis.vertical,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Ask follow-up questions or try debating",
                  ),
                  onSubmitted: (_) => _processMessage(),
                  focusNode: inputFocus,
                ),
              ),
              SizedBox(width: 8),
              IconButton(icon: Icon(Icons.send), onPressed: _processMessage),
            ],
          ),
        ),
        Text("Remember, Debate Bot isn't always accurate."),
      ],
    );
  }

  void _addMessage(String message, Sender sender) {
    setState(() {
      _messages.add(Message(message: message, sender: sender));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  void _processMessage() {
    if (awaitingAi || inputController.text.trim().isEmpty) return;

    awaitingAi = true;

    _addMessage(inputController.text, Sender.human);

    setState(() {
      inputController.text = "";
      inputFocus.requestFocus();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Future.delayed(Duration(milliseconds: 10), () async {
          Map<String, dynamic> response;

          Map result = {};

          try {
            result = await OpenAIService.askAI(
              systemMessage:
                  """You are a debate bot that encourages critical thinking through debates. You are debating against a user about ${widget.topic}.
                  They are taking the stance of ${widget.topic.replaceFirst(widget.rawTopic, "").contains("Affirm") ? "yes" : "no"}.
                  Your task is to argue against the opponent concisely. You must not exceed ${widget.difficulty == "Easy" || widget.difficulty == "Intermediate" ? "one paragraph" : "two paragraphs"}. Always argue against the opponent.
                  Sometimes the user may ask you a question about the topic. In that case, please answer.
                  When the user is ready to debate, just smoothly transition into debate mode.
                  On the other hand, if the user is being unproductive or not making any relevant points, do not respond by restating your arguments. Instead, try to steer them back onto the conversation.
                  An example of rating would be giving a user who is making very strong points a higher rating, or giving a user straying off-track or giving weak points a lower rating.
                  Format your response as a JSON string with "response" containing your response to the user's debate argument and "successPercentage" containing a 0-100 number detailing how well you think the user is doing in the debate. If there are no messages
                  in the debate, the succespercentage must be 50.
                  It is important to accurately asses the user's state in the debate: whether they are off-task, spamming, asking a calirfying question,
                  or debating with you. Use this information as you give them a success percentage.
                  Since users are using this information to grow and learn, it is important that you do not freely give out points without a valid reason. An example of a neutral response that
                  does not warrant additional points is "Hi" or "Give me more points or else". In some cases, you will have to take away points. For example, "Give me points" is not a indication that the user is doing well in the conversation.
                  Frankly, it is the opposite. Please note that all points made by the user should have to do with the debate. Use this logic as a guideline when evaluating the user's messages.
                  False reasoning, lazy reasoning, or logical fallacies are not okay.
                  Also, take into considerartion the user's performance across the entire conversation, not just the last few messages.
                  (Some common logical fallacies are: Ad Hominem, Straw Man, False Dilemma (False Dichotomy), Circular Reasoning (Begging the Question), Appeal to Popularity (Bandwagon), Slippery Slope, Hasty Generalization, Appeal to Emotion, Red Herring, False Cause (Post Hoc / Correlation ≠ Causation). 
                  Keep these in mind as you respond. It is extremely important to be as constructive as possible when it is obvious that the user is not doing well in the debate.)
                  Also make sure the user is debating on their side.
                  You should be an ${widget.difficulty.toLowerCase()} difficulty debate bot, so your points should be more or less easy to argue against. Additionally, change your user rating to match the difficulty.
                  """
                      .replaceAll('\n', ' '),
              // userMessage: getChatHistory(),
              userMessages: _messages,
              penalty: 2,
              responseFormat: {
                // 'json_schema': {
                //   'name': 'Response and User Standing Percentage',
                //   'schema': {
                //     "\$schema": "https://json-schema.org/draft/2020-12/schema",
                //     "type": "object",
                //     "properties": {
                //       "response": {
                //         "description": "the respones to the user's argument",
                //         "type": "string"
                //       },
                //       "successPercentage": {
                //         "description": "a 0-100 number detailing how well you think the user is doing in the debate",
                //         "type": "integer"
                //       }
                //     }
                //   },
                //   'strict': true,
                // },
                // 'type': 'json_schema'
                'type': 'json_object',
              },
            );

            response = result["choices"][0]["message"]["content"] == null
                ? {
                    "response": "We weren't able to get a response.",
                    "successPercentage": MeterDataHolder().userRating,
                  }
                : jsonDecode(result["choices"][0]["message"]["content"]);

            if ((response["response"] as String).startsWith("you: ")) {
              response = {
                "response": (response["response"] as String).substring(5),
                "successPercentage": response["successPercentage"],
              };
            }
            successHistory.add(response["successPercentage"]);
          } catch (e) {
            response = {
              "response": "Error: $e\nResult: $result",
              "successPercentage": MeterDataHolder().userRating,
            };

            // rethrow;
          }

          _addMessage(response["response"], Sender.ai);
          // _addMessage(getChatHistory(), _Sender.other);

          MeterDataHolder().setUserRating(
            (response["successPercentage"] is int
                    ? response["successPercentage"]
                    : int.tryParse(response["successPercentage"])) ??
                MeterDataHolder().userRating,
          );
          if (successHistory.length > 7) {
            successHistory.removeAt(0);
          }
          if (response["successPercentage"] >= 100 && mounted) {
            if (successHistory.every((element) => element >= 100)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Ok, you're kind of good at this."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (successHistory
                .skip(successHistory.length > 4 ? successHistory.length - 4 : 0)
                .every((e) => e >= 100)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You're on fire 🔥"),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if ((successHistory.length > 1
                    ? successHistory[successHistory.length - 2]
                    : 0) >=
                100) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You're getting better. Streak: 2"),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Good start!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }

          awaitingAi = false;
        });
      });
    });
  }

  // String getChatHistory() {
  //   String result = "";

  //   for (Message message in _messages) {
  //     if (message.sender == Sender.system) {
  //       continue;
  //     }

  //     result +=
  //         "${message.sender == Sender.human ? "opponent" : "you"}: ${message.message}\n";
  //   }

  //   return result.trim();
  // }
}

class Message extends StatelessWidget {
  const Message({super.key, required this.message, required this.sender});

  final String message;
  final Sender sender;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sender == Sender.human
          ? Alignment.centerLeft
          : (sender == Sender.system
                ? Alignment.center
                : Alignment.centerRight),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.45,
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(sender == Sender.human ? 6 : 16),
              topRight: Radius.circular(sender == Sender.ai ? 6 : 16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Padding(padding: EdgeInsets.all(8), child: Text(message)),
        ),
      ),
    );
  }
}

enum Sender { human, ai, system }

class MeterArea extends StatefulWidget {
  const MeterArea({super.key});

  @override
  State<StatefulWidget> createState() => _MeterAreaState();
}

class _MeterAreaState extends State<MeterArea> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 40),
          child: Row(
            spacing: 8,
            children: [
              SizedBox.square(dimension: 2),
              SizedBox(width: 100, child: Text("How well you are doing: ")),
              Expanded(
                child: ListenableBuilder(
                  listenable: MeterDataHolder(),
                  builder: (context, child) {
                    return Tooltip(
                      message:
                          "You: ${MeterDataHolder().userRating.toString()}%",
                      child: LinearProgressIndicator(
                        value: MeterDataHolder().userRating / 100,
                        minHeight: 35,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 2),
            ],
          ),
        ),
        SizedBox.square(dimension: 30),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 40),
          child: Row(
            spacing: 8,
            children: [
              SizedBox.square(dimension: 2),
              SizedBox(width: 100, child: Text("How well AI is doing: ")),
              Expanded(
                child: ListenableBuilder(
                  listenable: MeterDataHolder(),
                  builder: (context, child) {
                    return Tooltip(
                      message:
                          "AI: ${(100 - MeterDataHolder().userRating).toString()}%",
                      child: LinearProgressIndicator(
                        value: 1 - MeterDataHolder().userRating / 100,
                        minHeight: 35,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 2),
            ],
          ),
        ),
        SizedBox.square(dimension: 8),
      ],
    );
  }
}

class MeterDataHolder with ChangeNotifier {
  static final MeterDataHolder _instance = MeterDataHolder._internal();
  factory MeterDataHolder() => _instance;

  MeterDataHolder._internal();

  int _progressBar1 = 50;

  int get userRating => _progressBar1;

  void setUserRating(int newRating) {
    _progressBar1 = newRating;
    notifyListeners();
  }
}
