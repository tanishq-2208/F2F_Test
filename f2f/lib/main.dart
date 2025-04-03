import 'package:f2f/screens/customer_home_screen.dart';
import 'package:f2f/screens/customer_login_screen.dart';
import 'package:f2f/screens/customer_registration_screen.dart';
import 'package:f2f/screens/farmer_login_screen.dart';
import 'package:f2f/screens/farmer_orders_screen.dart';
import 'package:f2f/screens/farmers_fertilizers_screen.dart';
import 'package:f2f/screens/farmers_tools_screen.dart';
import 'package:f2f/screens/farmers_machinery_screen.dart'; // Add this import

import 'package:f2f/screens/home_screen.dart';
import 'package:f2f/screens/my_orders_screen.dart';
import 'package:f2f/screens/payment_screen.dart';
import 'package:f2f/screens/payment_success_screen.dart';
import 'package:f2f/screens/products_screen.dart';
import 'package:f2f/screens/plant_analysis_screen.dart';
import 'package:f2f/screens/registration_screen.dart';
import 'package:f2f/screens/status_screen.dart';
import 'package:f2f/screens/upload_items_screen.dart';
import 'package:f2f/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:f2f/services/language_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:f2f/providers/language_provider.dart';
import 'package:f2f/screens/profile_screen.dart';
import 'package:f2f/screens/ai_search_screen.dart';
import 'package:f2f/screens/farmers_tools_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create a single instance of LanguageService to be used throughout the app
  final languageService = LanguageService();
  await languageService.initialize(); // Ensure translations are loaded

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to language changes using Consumer for better performance
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
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
            '/home': (context) => const HomeScreen(),
            '/farmer_orders': (context) => const FarmerOrdersScreen(),
            '/status': (context) => const StatusScreen(),
            '/customer_home': (context) => const CustomerHomeScreen(),
            // Remove the static route for products since it needs a dynamic parameter
            '/upload_items': (context) => const UploadItemsScreen(),
            '/farmer_register': (context) => const RegistrationScreen(role: 'farmer'),
            '/farmer_login': (context) => const FarmerLoginScreen(),
            '/plant_analysis': (context) => const PlantAnalysisScreen(),
            '/farmer_tools': (context) => const FarmersToolsScreen(),
            '/farmer_machinery': (context) => const FarmersMachineryScreen(), // Add this route
            '/farmer_fertilizers': (context) => const FarmersFertilizersScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/ai':
                (context) => const AISearchScreen(
                  diseaseName: 'General',
                  searchType: 'information',
                ),
              '/payment': (context) {
              // Get arguments passed during navigation
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              
              // Use arguments if provided, otherwise use defaults
              return PaymentScreen(
                productName: args?['productName'] ?? 'Sample Product',
                productPrice: args?['productPrice'] ?? 100.0,
                productImage: args?['productImage'] ?? 'https://via.placeholder.com/150',
                availableQuantity: args?['availableQuantity'] ?? 10,
                farmerId: args?['farmerId'], // Add farmerId parameter
                quantity: args?['quantity'] ?? 1, // Add quantity parameter
              );
          },},

          home: const WelcomeScreen(),
        );
      },
    );
  }
}