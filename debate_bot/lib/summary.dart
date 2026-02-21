import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  const Summary({super.key, required this.input});

  final String input;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Summary"),
      ),
      body: Center(
        child: Text(input),
      ),
    );
  }
}
