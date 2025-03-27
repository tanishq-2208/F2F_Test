import 'package:flutter/material.dart';
//import 'screens/landing_screen.dart';
import 'screens/upload_items_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm2Fork Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          secondary: const Color(0xFFF9A825),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      // Remove these lines
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const LandingPage(),
      //   '/login': (context) => const LoginScreen(),
      //   '/register': (context) => RegistrationScreen(
      //         role: ModalRoute.of(context)!.settings.arguments as String,
      //       ),
      // },
      home: const UploadItemsScreen(),
    );
  }
}
