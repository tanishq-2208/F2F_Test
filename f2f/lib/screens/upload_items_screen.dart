import 'package:flutter/material.dart';
import '../widgets/farmer_bottom_navigation_bar.dart';
import 'package:f2f/utils/string_extensions.dart';
import 'package:f2f/screens/products_screen.dart';

class UploadItemsScreen extends StatefulWidget {
  const UploadItemsScreen({super.key});

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
              Text(
                'Select Category'.tr(context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.apple),
                title: Text('Fruits'.tr(context)),
                onTap: () {
                  setState(() {
                    selectedItem = 'Fruits';
                  });
                  Navigator.pop(context);
                  // Navigate to ProductsScreen with Fruits category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsScreen(category: 'Fruits'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.eco),
                title: Text('Vegetables'.tr(context)),
                onTap: () {
                  setState(() {
                    selectedItem = 'Vegetables';
                  });
                  Navigator.pop(context);
                  // Navigate to ProductsScreen with Vegetables category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductsScreen(category: 'Vegetables'),
                    ),
                  );
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
      appBar: AppBar(
        title: Text('Upload Items'.tr(context)),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width * 0.9,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Select Category'.tr(context),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryCard(
                          context,
                          'Fruits',
                          icon: Image.asset(
                            'assets/images/fruits.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          backgroundColor: Colors.red.shade100,
                        ),
                        _buildCategoryCard(
                          context,
                          'Vegetables',
                          icon: Image.asset(
                            'assets/images/vegetables.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          backgroundColor: Colors.green.shade100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _showOptionsBottomSheet,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Add Items'.tr(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    /*if (selectedItem != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          'Selected: ${selectedItem!.tr(context)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FarmerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category, {
    required Widget icon,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedItem = category;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsScreen(category: category),
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 10),
            Text(
              category.tr(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
