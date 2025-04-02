import 'package:f2f/screens/plant_analysis_screen.dart';
import 'package:f2f/screens/upload_items_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:f2f/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:f2f/providers/language_provider.dart';

class FarmerBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const FarmerBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Use LanguageProvider instead of string extensions
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            // Handle profile navigation separately
            if (index == 3) {
              // Profile index
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadItemsScreen(),
                ),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlantAnalysisScreen(),
                ),
              );
            }
            // Still call the original callback for all items
            onItemTapped(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          items: [
            _buildNavItem(
              Icons.home_rounded,
              isTeluguSelected ? 'హోమ్' : 'Home',
            ),
            _buildNavItem(Icons.psychology_rounded, 'AI'),
            _buildNavItem(
              Icons.add_business_rounded,
              isTeluguSelected ? 'అమ్మకం' : 'Sell',
            ),
            _buildNavItem(
              Icons.person_rounded,
              isTeluguSelected ? 'ప్రొఫైల్' : 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(icon: Icon(icon), label: label);
  }
}
