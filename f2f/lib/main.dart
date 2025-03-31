import 'package:f2f/screens/customer_home_screen.dart';
import 'package:f2f/screens/farmer_login_screen.dart';
import 'package:f2f/screens/home_screen.dart';
import 'package:f2f/screens/my_orders_screen.dart';
import 'package:f2f/screens/products_screen.dart';
import 'package:f2f/screens/registration_screen.dart';
import 'package:f2f/screens/status_screen.dart';
import 'package:f2f/screens/upload_items_screen.dart';
import 'package:f2f/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'screens/products_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:f2f/services/language_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create a single instance of LanguageService to be used throughout the app
  final languageService = LanguageService();
  await languageService
      .initialize(); // Add an initialize method to ensure translations are loaded

  runApp(
    ChangeNotifierProvider.value(value: languageService, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to language changes
    final languageService = Provider.of<LanguageService>(context);

    return MaterialApp(
      title: 'Farm2Fork Connect',
      locale: languageService.currentLocale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('te', ''), // Telugu
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
        '/status': (context) => const StatusScreen(),  // Add this line
        '/home': (context) => const HomeScreen(),
        '/customer_home': (context) => const CustomerHomeScreen(),
        '/products': (context) => const ProductsPage(),
        '/upload_items': (context) => const UploadItemsScreen(),
        '/farmer_register':
            (context) => const RegistrationScreen(role: 'farmer'),
        '/farmer_login': (context) => const FarmerLoginScreen(),
      },
      home: const StatusScreen(),
    );
  }
}
