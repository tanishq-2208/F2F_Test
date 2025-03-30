import 'package:flutter/material.dart';
import 'package:f2f/widgets/language_toggle.dart';
import 'package:f2f/utils/string_extensions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login'.tr(context)),
        backgroundColor: Colors.green.shade800,
        actions: const [
          LanguageToggle(isCompact: true),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'email'.tr(context),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'password'.tr(context),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Login logic
              },
              child: Text('login'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }
}