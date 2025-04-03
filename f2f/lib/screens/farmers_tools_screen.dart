import 'package:flutter/material.dart';
import '../widgets/customer_bottom_navigation_bar.dart';

class FarmersToolsScreen extends StatefulWidget {
  const FarmersToolsScreen({super.key});

  @override
  State<FarmersToolsScreen> createState() => _FarmersToolsScreenState();
}

class _FarmersToolsScreenState extends State<FarmersToolsScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All Tools';
  final bool _isLoading = false;

  // List of tool categories
  final List<String> _categories = [
    'All Tools',
    'Hand Tools',
    'Power Tools',
    'Irrigation',
    'Harvesting'
  ];

  // List of farming tools with their details
  final List<Map<String, dynamic>> _farmingTools = [
    {
      'name': 'Garden Shovel',
      'image': 'assets/images/shovel_ht.png',
      'price': 299.99,
      'description': 'Heavy-duty garden shovel with ergonomic handle for comfortable digging.',
      'category': 'Hand Tools',
      'rating': 4.5,
      'reviews': 24,
    },
    {
      'name': 'Garden Sprayer',
      'image': 'assets/images/sprayer_ht.png',
      'price': 499.99,
      'description': 'Adjustable garden sprayer for efficient watering and plant care.',
      'category': 'Irrigation',
      'rating': 4.2,
      'reviews': 18,
    },
    {
      'name': 'Hand Cultivator',
      'image': 'assets/images/cultivator_ht.jpg',
      'price': 199.99,
      'description': 'Durable hand cultivator for soil preparation and weed removal.',
      'category': 'Hand Tools',
      'rating': 4.7,
      'reviews': 32,
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
      case 1: // Tools (current screen)
        // Already on tools screen
        break;
      case 2: // Orders
        Navigator.pushReplacementNamed(context, '/my_orders');
        break;
    }
  }

  // Get filtered tools based on selected category
  List<Map<String, dynamic>> get _filteredTools {
    if (_selectedCategory == 'All Tools') {
      return _farmingTools;
    }
    return _farmingTools.where((tool) => 
      tool['category'] == _selectedCategory
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farming Tools & Equipment'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category selector
          _buildCategorySelector(),
          
          // Tools grid
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildToolsGrid(),
          ),
        ],
      ),
      bottomNavigationBar: CustomerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationItemSelected,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                backgroundColor: isSelected ? Colors.green[700] : Colors.grey[200],
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

  Widget _buildToolsGrid() {
    if (_filteredTools.isEmpty) {
      return Center(
        child: Text(
          'No $_selectedCategory available at the moment',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Using ListView instead of GridView for a cleaner list layout
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTools.length,
      itemBuilder: (context, index) {
        final tool = _filteredTools[index];
        return _buildToolCard(tool);
      },
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tool image - increased size
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    tool['image'],
                    height: 150,  // Increased from 100 to 150
                    width: 150,   // Increased from 100 to 150
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,  // Matching the increased height
                        width: 150,   // Matching the increased width
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,  // Increased icon size
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Tool details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${tool['price'].toStringAsFixed(2)}',
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
                            ' ${tool['rating']} (${tool['reviews']})',
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
                'DELIVERY AVAILABLE IN 2-3 DAYS',
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
                      'productName': tool['name'],
                      'productPrice': tool['price'],
                      'productImage': tool['image'],
                      'availableQuantity': 10,
                      'farmerId': 'tool_supplier_001',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}