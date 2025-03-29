import 'package:flutter/material.dart';
import '../widgets/farmer_bottom_navigation_bar.dart';

class UploadItemsScreen extends StatefulWidget {
  const UploadItemsScreen({Key? key}) : super(key: key);

  @override
  State<UploadItemsScreen> createState() => _UploadItemsScreenState();
}

class _UploadItemsScreenState extends State<UploadItemsScreen> {
  String? selectedItem;
  int _selectedIndex = 2; // Set to 2 for the "Sell" tab

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.apple),
                title: const Text('Fruits'),
                onTap: () {
                  setState(() {
                    selectedItem = 'Fruits';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.eco),
                title: const Text('Vegetables'),
                onTap: () {
                  setState(() {
                    selectedItem = 'Vegetables';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      
      // Navigate to the appropriate screen based on the index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/ai');
          break;
        case 2:
          // Already on the sell page
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Items')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _showOptionsBottomSheet,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Items'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (selectedItem != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Selected: $selectedItem',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: FarmerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
