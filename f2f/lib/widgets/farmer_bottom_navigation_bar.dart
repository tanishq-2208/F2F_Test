import 'package:f2f/screens/upload_items_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:f2f/screens/profile_screen.dart';
import 'package:f2f/utils/string_extensions.dart'; // Add this import

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
            }
            // Still call the original callback for all items
            onItemTapped(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          items: [
            _buildNavItem(Icons.home_rounded, 'home'.tr(context)),
            _buildNavItem(Icons.psychology_rounded, 'AI'),
            _buildNavItem(Icons.add_business_rounded, 'sell'.tr(context)),
            _buildNavItem(Icons.person_rounded, 'profile'.tr(context)),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(icon: Icon(icon), label: label);
  }
}
