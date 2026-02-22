import 'package:flutter/material.dart';
import 'summary.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final inputcontroller = TextEditingController();

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
            Text("Welcome to our Debate Bot for GunnHaXII!"),
            
            Spacer(),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputcontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Let's get started! Type your topic here to continue.",
                      ),
                      onSubmitted: (_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Summary(input: inputcontroller.text),
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
                          builder: (context) =>
                              Summary(input: inputcontroller.text),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Text("Debate Bot isn't always accurate! Make sure you check before you do!"),
            Padding(padding: EdgeInsets.all(4)),
          ],
        ),
      ),
    );
  }
}
