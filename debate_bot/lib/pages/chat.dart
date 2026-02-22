import 'package:flutter/material.dart';

class ChatArea extends StatefulWidget {
  const ChatArea({super.key});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final inputController = TextEditingController();
  final inputFocus = FocusNode();

  final List<Widget> _messages = [];
  final ScrollController scrollController = ScrollController();

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

  void _processMessage() {
    setState(() {
      _messages.add(
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          
          ),
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text(inputController.text),
          ),
        ),
      );

      inputController.text = "";
      inputFocus.requestFocus();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(
        () =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent),
      );
    });
  }
}
