import 'package:flutter/material.dart';
import '../widgets/customer_bottom_navigation_bar.dart';

class FarmersMachineryScreen extends StatefulWidget {
  const FarmersMachineryScreen({super.key});

  @override
  State<FarmersMachineryScreen> createState() => _FarmersMachineryScreenState();
}

class _FarmersMachineryScreenState extends State<FarmersMachineryScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All Machinery';
  final bool _isLoading = false;

  // List of machinery categories
  final List<String> _categories = [
    'All Machinery',
    'Plows',
    'Harrows',
    'Rotavators',
    'Tractors',
  ];

  // List of farming machinery with their details
  final List<Map<String, dynamic>> _farmingMachinery = [
    {
      'name': 'Disc Harrow',
      'image': 'assets/images/discHarrow_me.webp',
      'price': 25999.99,
      'description':
          'Heavy-duty disc harrow for efficient soil preparation and weed control.',
      'category': 'Harrows',
      'rating': 4.6,
      'reviews': 32,
    },
    {
      'name': 'Dual Plow',
      'image': 'assets/images/dualplow_me.png',
      'price': 18499.99,
      'description':
          'Dual-purpose plow for versatile field preparation and cultivation.',
      'category': 'Plows',
      'rating': 4.3,
      'reviews': 27,
    },
    {
      'name': 'Rotavator',
      'image': 'assets/images/rotavator_me.jpg',
      'price': 32999.99,
      'description':
          'Professional rotavator for thorough soil mixing and seedbed preparation.',
      'category': 'Rotavators',
      'rating': 4.8,
      'reviews': 45,
    },
  ];

  // Navigation method
  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/customer_home');
        break;
      case 1: // Machinery (current screen)
        // Already on machinery screen
        break;
      case 2: // Orders
        Navigator.pushReplacementNamed(context, '/my_orders');
        break;
    }
  }

  // Get filtered machinery based on selected category
  List<Map<String, dynamic>> get _filteredMachinery {
    if (_selectedCategory == 'All Machinery') {
      return _farmingMachinery;
    }
    return _farmingMachinery
        .where((machinery) => machinery['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A5336), // Updated background color
      appBar: AppBar(
        title: const Text('Farming Machinery & Equipment'),
        backgroundColor: const Color(0xFF266241), // Updated app bar color
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category selector
          _buildCategorySelector(),

          // Machinery list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMachineryList(),
          ),
        ],
      ),
      // Bottom navigation bar removed
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF1A5336), // Match background color
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? const Color(0xFF266241) : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                elevation: isSelected ? 2 : 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMachineryList() {
    if (_filteredMachinery.isEmpty) {
      return Center(
        child: Text(
          'No $_selectedCategory available at the moment',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    // Using ListView instead of GridView for a cleaner list layout
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMachinery.length,
      itemBuilder: (context, index) {
        final machinery = _filteredMachinery[index];
        return _buildMachineryCard(machinery);
      },
    );
  }

  Widget _buildMachineryCard(Map<String, dynamic> machinery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: const Color(0xFFECF6E5), // Updated card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Machinery image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    machinery['image'],
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Machinery details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machinery['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${machinery['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${machinery['rating']} (${machinery['reviews']})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Delivery info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'DELIVERY AVAILABLE IN 7-10 DAYS',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Buy now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/payment',
                    arguments: {
                      'productName': machinery['name'],
                      'productPrice': machinery['price'],
                      'productImage': machinery['image'],
                      'availableQuantity': 5,
                      'farmerId': 'machinery_supplier_001',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF266241,
                  ), // Updated button color
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
