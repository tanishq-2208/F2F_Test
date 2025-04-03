import 'package:f2f/widgets/farmer_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:f2f/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add the isFarmer method as a class method, not inside the build method
  Future<bool> _isFarmer() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      // Check if the user exists in the farmers collection
      final farmerDoc = await FirebaseFirestore.instance
          .collection('farmers')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      return farmerDoc.docs.isNotEmpty;
    } catch (e) {
      print('Error checking farmer status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';
    int selectedIndex = 3;

    void onItemTapped(int index) {
      if (index != selectedIndex) {
        setState(() {
          selectedIndex = index;
        });

        // Handle navigation based on the selected index
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/plant_analysis');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/upload_items');
            break;
          case 3:
            // Already on profile page
            break;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A5336), // Updated background color
      appBar: AppBar(
        title: Text(
          isTeluguSelected ? 'ప్రొఫైల్' : 'Profile',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF266241), // Updated app bar color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              color: const Color(0xFF266241), // Updated color
              child: Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/farmer.png'),
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
              isTeluguSelected ? 'ఖాతా సెట్టింగ్‌లు' : 'Account Settings',
            ),
            _buildProfileOption(
              icon: Icons.person_outline,
              title:
                  isTeluguSelected ? 'ప్రొఫైల్‌ని సవరించండి' : 'Edit Profile',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.circle,
              title: isTeluguSelected ? 'స్థితి' : 'Status',
              subtitle: isTeluguSelected ? 'అందుబాటులో ఉంది' : 'Available',
              onTap: () async {
                // Check if the user is a farmer
                final isFarmer = await _isFarmer();
                
                // Navigate to the appropriate screen based on user role
                if (isFarmer) {
                  Navigator.pushNamed(context, '/farmer_orders');
                } else {
                  Navigator.pushNamed(context, '/status');
                }
              },
            ),
            _buildProfileOption(
              icon: Icons.location_on_outlined,
              title:
                  isTeluguSelected
                      ? 'సేవ్ చేసిన చిరునామాలు'
                      : 'Saved Addresses',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title:
                  isTeluguSelected ? 'చెల్లింపు పద్ధతులు' : 'Payment Methods',
              onTap: () {
                // Navigate to payment methods
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader(
              isTeluguSelected ? 'ప్రాధాన్యతలు' : 'Preferences',
            ),
            _buildLanguageOption(context, languageProvider, isTeluguSelected),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: isTeluguSelected ? 'నోటిఫికేషన్లు' : 'Notifications',
              onTap: () {
                // Navigate to notifications
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader(
              isTeluguSelected
                  ? 'ఆర్డర్లు & లావాదేవీలు'
                  : 'Orders & Transactions',
            ),
            _buildProfileOption(
              icon: Icons.shopping_bag_outlined,
              title: isTeluguSelected ? 'నా ఆర్డర్లు' : 'My Orders',
              onTap: () {
                Navigator.pushNamed(context, '/my_orders');
              },
            ),
            _buildProfileOption(
              icon: Icons.history,
              title:
                  isTeluguSelected ? 'లావాదేవీ చరిత్ర' : 'Transaction History',
              onTap: () {
                // Navigate to transaction history
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader(
              isTeluguSelected ? 'సహాయం & మద్దతు' : 'Help & Support',
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: isTeluguSelected ? 'సహాయ కేంద్రం' : 'Help Center',
              onTap: () {
                // Navigate to help center
              },
            ),
            _buildProfileOption(
              icon: Icons.info_outline,
              title: isTeluguSelected ? 'మా గురించి' : 'About Us',
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
                  isTeluguSelected ? 'లాగ్అవుట్' : 'Logout',
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
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        height: 70, // Increased height
        decoration: BoxDecoration(
          color: const Color(0xFFD8E6C9), // Updated color
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color(0xFFD8E6C9),
            ),
            child: FarmerBottomNavigationBar(
              selectedIndex: selectedIndex,
              onItemTapped: onItemTapped,
            ),
          ),
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
    LanguageProvider languageProvider,
    bool isTeluguSelected,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.language, color: Colors.green.shade800),
        title: Text(
          isTeluguSelected ? 'భాష' : 'Language',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(isTeluguSelected ? 'తెలుగు' : 'English'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showLanguageBottomSheet(context, languageProvider, isTeluguSelected);
        },
      ),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    LanguageProvider languageProvider,
    bool isTeluguSelected,
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
                      isTeluguSelected ? 'భాషను ఎంచుకోండి' : 'Select Language',
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
                isSelected: !isTeluguSelected,
                onTap: () {
                  languageProvider.setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              _buildLanguageItem(
                context: context,
                title: 'తెలుగు (Telugu)',
                isSelected: isTeluguSelected,
                onTap: () {
                  languageProvider.setLanguage('te');
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
