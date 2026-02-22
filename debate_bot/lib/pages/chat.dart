import 'package:flutter/material.dart';

class Summary extends StatefulWidget {
  const Summary({super.key, required this.input});

  final String input;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Debate Bot"),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height - 148,
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return ListTile(title: _messages[index]);
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
                      hintText: "...",
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
          Text(
            "Debate Bot isn't always accurate! Make sure you check before you do!",
          ),
          Padding(padding: EdgeInsets.all(4)),
        ],
      ),
    );
  }

  void _processMessage() {
    setState(() {
      _messages.add(Text(inputController.text));

      inputController.text = "";
      inputFocus.requestFocus();
    });

    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
}
