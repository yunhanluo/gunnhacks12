import 'dart:convert';

import 'package:debate_bot/services/openai_service.dart';
import 'package:flutter/material.dart';

class ChatArea extends StatefulWidget {
  const ChatArea({super.key, required this.topic, required this.rawTopic});

  final String topic;
  final String rawTopic;

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final inputController = TextEditingController();
  final inputFocus = FocusNode();

  final List<Message> _messages = [];
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
                    hintText:
                        "Ask a follow-up question here! Or, take a try at debating and type in your points.",
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
        Text("Remember, Debate Bot isn't always accurate!"),
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
                  """You are debating against a user about ${widget.topic}.
                  They are taking the stance of ${widget.topic.replaceFirst(widget.rawTopic, "").contains("Affirm") ? "yes" : "no"}.
                  Your task is to argue against the opponent, but try not to respond with multiple paragraphs.
                  Instead, respond with at most one paragraph, and always argue against the opponent.
                  Sometimes the user may ask you a question of the topic. In that case, please answer.
                  When the user is ready to debate, just smoothly transition into debate mode.
                  An example of rating would be giving a user who is making very strong points a higher rating, or giving a user straying off-track or giving weak points a lower rating.
                  Format your response as a JSON strnig with "response" containing your response to the user's debate argument and "successPercentage" containing a 0-100 number detailing how well you think the user is doing in the debate.""".replaceAll('\n', ' '),
              // userMessage: getChatHistory(),
              userMessages: _messages,
              penalty: 1,
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
                'type': 'json_object'
              }
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
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
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
