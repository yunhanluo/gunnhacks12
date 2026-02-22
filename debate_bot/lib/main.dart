import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.grey[800]!,
          onPrimary: Colors.white,
          secondary: Colors.grey[600]!,
          onSecondary: Colors.white,
          tertiary: Colors.grey[400]!,
          onTertiary: Colors.black,
          surface: Colors.grey[50]!,
          onSurface: Colors.grey[900]!,
          error: Colors.red[700]!,
          onError: Colors.white,
          inversePrimary: Colors.grey[300]!,
          primaryContainer: Colors.grey[200]!,
          onPrimaryContainer: Colors.grey[900]!,
          secondaryContainer: Colors.grey[200]!,
          onSecondaryContainer: Colors.grey[800]!,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => const Home(title: 'Debate Bot')},
    );
  }
}
