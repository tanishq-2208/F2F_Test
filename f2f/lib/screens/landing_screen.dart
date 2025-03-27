import 'package:f2f/screens/login_screen.dart';
import 'package:f2f/screens/registration_screen.dart';
import 'package:flutter/material.dart';
// Remove unused import until multiselect_formfield package is added to pubspec.yaml

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm2Fersh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            tooltip: 'Existing User Login',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Join as:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _RoleCard(
              title: 'Farmer',
              icon: Icons.agriculture,
              color: Colors.green[800]!,
              description: 'Sell your fresh produce directly to consumers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrationScreen(role: 'Farmer'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _RoleCard(
              title: 'Customer',
              icon: Icons.shopping_basket,
              color: Theme.of(context).colorScheme.secondary,
              description: 'Buy fresh farm products directly from growers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrationScreen(role: 'Customer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Keep existing _RoleCard implementation from previous answer
  // ... (same code as previous _RoleCard implementation)
}