import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debate Bot (GunnHaXII)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
<<<<<<< HEAD
          seedColor: Color.fromARGB(255, 0, 0, 0),
          brightness: Brightness.dark,
=======
          seedColor: Colors.black,
          primary: Colors.black,
          onPrimary: Colors.white,
          inversePrimary: Colors.white,
>>>>>>> refs/remotes/origin/main
        ),
        //scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/',
      routes: {'/': (context) => const Home(title: 'Debate Bot')},
    );
  }
}
