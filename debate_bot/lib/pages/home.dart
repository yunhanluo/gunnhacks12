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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputcontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Let's get started!",
                      ),
                    ),
                  ),
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
            Text("Debate Bot"),
            Padding(padding: EdgeInsets.all(4)),
          ],
        ),
      ),
    );
  }
}
