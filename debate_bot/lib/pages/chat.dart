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

  final List<_Message> _messages = [];
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
                    hintText: "Ask a follow-up question here!",
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

  void _addMessage(String message, _Sender sender) {
    setState(() {
      _messages.add(_Message(message: message, sender: sender));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  void _processMessage() {
    if (awaitingAi || inputController.text.trim().isEmpty) return;

    awaitingAi = true;

    _addMessage(inputController.text, _Sender.human);

    setState(() {
      inputController.text = "";
      inputFocus.requestFocus();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Future.delayed(Duration(milliseconds: 10), () async {
          Map<String, dynamic> response;

          try {
            final result = await OpenAIService.askAI(
              systemMessage:
                  "You are debating against a user about ${widget.topic}. They are taking the stance of ${widget.topic.replaceFirst(widget.rawTopic, "").contains("Affirm") ? "yes" : "no"}. You will be given the entire chat history, where the opponent is labeled \"opponent\" and you are labeled \"you\". Your task is to argue against the opponent, but try not to respond with multiple paragraphs. Instead, respond with at most one paragraph, and try to keep the conversation on track and always argue against the opponent. Format your response in a JSON with the key \"response\" containing your response and the key \"successPercentage\" containing a number from 0-100 detailing how well you think your opponent is doing in the debate.",
              userMessage: getChatHistory(),
            );

            response = result["choices"][0]["message"]["content"] == null
                ? {
                    "response": "We weren't able to get a response.",
                    "successPercentage": _MeterDataHolder().userRating,
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
              "response": "Error: $e",
              "successPercentage": _MeterDataHolder().userRating,
            };
          }

          _addMessage(response["response"], _Sender.ai);
          // _addMessage(getChatHistory(), _Sender.other);

          _MeterDataHolder().setUserRating(
            (response["successPercentage"] is int ? response["successPercentage"] : int.tryParse(response["successPercentage"])) ??
                _MeterDataHolder().userRating,
          );

          awaitingAi = false;
        });
      });
    });
  }

  String getChatHistory() {
    String result = "";

    for (_Message message in _messages) {
      if (message.sender == _Sender.system) {
        continue;
      }

      result +=
          "${message.sender == _Sender.human ? "opponent" : "you"}: ${message.message}\n";
    }

    return result.trim();
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.sender});

  final String message;
  final _Sender sender;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sender == _Sender.human
          ? Alignment.centerLeft
          : (sender == _Sender.system
                ? Alignment.center
                : Alignment.centerRight),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width - 700,
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Padding(padding: EdgeInsets.all(8), child: Text(message)),
        ),
      ),
    );
  }
}

enum _Sender { human, ai, system }

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
      spacing: 30,
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
                  listenable: _MeterDataHolder(),
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _MeterDataHolder().userRating / 100,
                      minHeight: 35,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 40),
          child: Row(
            spacing: 8,
            children: [
              SizedBox.square(dimension: 2),
              SizedBox(width: 100, child: Text("How well AI is doing: ")),
              Expanded(
                child: ListenableBuilder(
                  listenable: _MeterDataHolder(),
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: 1 - _MeterDataHolder().userRating / 100,
                      minHeight: 35,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeterDataHolder with ChangeNotifier {
  static final _MeterDataHolder _instance = _MeterDataHolder._internal();
  factory _MeterDataHolder() => _instance;

  _MeterDataHolder._internal();

  int _progressBar1 = 50;

  int get userRating => _progressBar1;

  void setUserRating(int newRating) {
    _progressBar1 = newRating;
    notifyListeners();
  }
}
