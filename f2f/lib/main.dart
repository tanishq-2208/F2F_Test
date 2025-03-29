import 'package:f2f/screens/customer_home_screen.dart';
import 'package:f2f/screens/home_screen.dart';
import 'package:f2f/screens/my_orders_screen.dart';
import 'package:f2f/screens/upload_items_screen.dart';
import 'package:f2f/screens/welcome_screen.dart';
import 'package:f2f/screens/customer_registration_screen.dart';
import 'package:f2f/screens/home_screen.dart';
import 'package:f2f/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/products_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      routes: {
        '/my_orders': (context) => const MyOrdersScreen(),
        '/home': (context) => const HomeScreen(),
        '/customer_home': (context) => const CustomerHomeScreen(),
        '/products': (context) => const ProductsPage(),
        '/upload_items': (context) => const UploadItemsScreen(),
      },
      home: const WelcomeScreen(),
    );
  }
}
