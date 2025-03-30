import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:f2f/services/language_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          currentLanguage == 'en' ? 'Profile' : 'ప్రొఫైల్',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.green.shade800,
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'Farmer User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'farmer@example.com',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Profile options
            const SizedBox(height: 16),
            _buildSectionHeader(
              currentLanguage == 'en'
                  ? 'Account Settings'
                  : 'ఖాతా సెట్టింగ్‌లు',
            ),
            _buildProfileOption(
              icon: Icons.person_outline,
              title:
                  currentLanguage == 'en'
                      ? 'Edit Profile'
                      : 'ప్రొఫైల్‌ని సవరించండి',
              onTap: () {
                // Navigate to edit profile
              },
            ),
            _buildProfileOption(
              icon: Icons.location_on_outlined,
              title:
                  currentLanguage == 'en'
                      ? 'Saved Addresses'
                      : 'సేవ్ చేసిన చిరునామాలు',
              onTap: () {
                // Navigate to addresses
              },
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title:
                  currentLanguage == 'en'
                      ? 'Payment Methods'
                      : 'చెల్లింపు పద్ధతులు',
              onTap: () {
                // Navigate to payment methods
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader(
              currentLanguage == 'en' ? 'Preferences' : 'ప్రాధాన్యతలు',
            ),
            _buildLanguageOption(context, languageService, currentLanguage),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title:
                  currentLanguage == 'en' ? 'Notifications' : 'నోటిఫికేషన్లు',
              onTap: () {
                // Navigate to notifications
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader(
              currentLanguage == 'en'
                  ? 'Orders & Transactions'
                  : 'ఆర్డర్లు & లావాదేవీలు',
            ),
            _buildProfileOption(
              icon: Icons.shopping_bag_outlined,
              title: currentLanguage == 'en' ? 'My Orders' : 'నా ఆర్డర్లు',
              onTap: () {
                Navigator.pushNamed(context, '/my_orders');
              },
            ),
            _buildProfileOption(
              icon: Icons.history,
              title:
                  currentLanguage == 'en'
                      ? 'Transaction History'
                      : 'లావాదేవీ చరిత్ర',
              onTap: () {
                // Navigate to transaction history
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader(
              currentLanguage == 'en' ? 'Help & Support' : 'సహాయం & మద్దతు',
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: currentLanguage == 'en' ? 'Help Center' : 'సహాయ కేంద్రం',
              onTap: () {
                // Navigate to help center
              },
            ),
            _buildProfileOption(
              icon: Icons.info_outline,
              title: currentLanguage == 'en' ? 'About Us' : 'మా గురించి',
              onTap: () {
                // Navigate to about us
              },
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  currentLanguage == 'en' ? 'Logout' : 'లాగ్అవుట్',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green.shade800),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageService languageService,
    String currentLanguage,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.language, color: Colors.green.shade800),
        title: Text(
          currentLanguage == 'en' ? 'Language' : 'భాష',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(currentLanguage == 'en' ? 'English' : 'తెలుగు'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showLanguageBottomSheet(context, languageService, currentLanguage);
        },
      ),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    LanguageService languageService,
    String currentLanguage,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      currentLanguage == 'en'
                          ? 'Select Language'
                          : 'భాషను ఎంచుకోండి',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              _buildLanguageItem(
                context: context,
                title: 'English',
                isSelected: currentLanguage == 'en',
                onTap: () {
                  languageService.changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
              _buildLanguageItem(
                context: context,
                title: 'తెలుగు (Telugu)',
                isSelected: currentLanguage == 'te',
                onTap: () {
                  languageService.changeLanguage('te');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green.shade800),
          ],
        ),
      ),
    );
  }
}
