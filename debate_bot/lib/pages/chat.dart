import 'package:debate_bot/services/openai_service.dart';
import 'package:flutter/material.dart';

class ChatArea extends StatefulWidget {
  const ChatArea({super.key, required this.topic});

  final String topic;

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
                    hintText: "Elaborate on your prompt!",
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
          String response = "";

          try {
            final result = await OpenAIService.askAI(
              systemMessage:
                  "You are debating against a user about ${widget.topic}. You will be given the entire chat history, where the opponent is labeled \"opponent\" and you are labeled \"you\". Your task is to argue against the opponent, but try not to respond with multiple paragraphs. Instead, respond with at most one paragraph, and try to keep the conversation on track and always argue against the opponent.",
              userMessage: getChatHistory(),
            );

            response =
                result["choices"][0]["message"]["content"] ??
                "We weren't able to get a response.";

            if (response.startsWith("you: ")) {
              response = response.substring(5);
            }
          } catch (e) {
            response = "Error: $e";
          }

          _addMessage(response, _Sender.ai);
          // _addMessage(getChatHistory(), _Sender.other);

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
