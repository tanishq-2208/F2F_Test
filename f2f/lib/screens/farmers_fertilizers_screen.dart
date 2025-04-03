import 'package:flutter/material.dart';
import '../widgets/customer_bottom_navigation_bar.dart';

class FarmersFertilizersScreen extends StatefulWidget {
  const FarmersFertilizersScreen({super.key});

  @override
  State<FarmersFertilizersScreen> createState() => _FarmersFertilizersScreenState();
}

class _FarmersFertilizersScreenState extends State<FarmersFertilizersScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All Products';
  final bool _isLoading = false;

  // List of fertilizer categories
  final List<String> _categories = [
    'All Products',
    'Seeds',
    'Fertilizers',
    'Soil Enhancers',
    'Pesticides'
  ];

  // List of farming fertilizers with their details
  final List<Map<String, dynamic>> _farmingFertilizers = [
    {
      'name': 'Cumin Seeds',
      'image': 'assets/images/cuminseeds_sf.png',
      'price': 499.99,
      'description': 'Premium quality cumin seeds for better yield and flavor.',
      'category': 'Seeds',
      'rating': 4.7,
      'reviews': 38,
    },
    {
      'name': 'Organic Fertilizer',
      'image': 'assets/images/organicFert_sf.png',
      'price': 799.99,
      'description': 'Natural organic fertilizer for healthier crops and soil.',
      'category': 'Fertilizers',
      'rating': 4.9,
      'reviews': 52,
    },
    {
      'name': 'Soil Enhancer',
      'image': 'assets/images/soilEnha_sf.webp',
      'price': 649.99,
      'description': 'Advanced soil enhancer to improve soil structure and fertility.',
      'category': 'Soil Enhancers',
      'rating': 4.5,
      'reviews': 29,
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
      case 1: // Fertilizers (current screen)
        // Already on fertilizers screen
        break;
      case 2: // Orders
        Navigator.pushReplacementNamed(context, '/my_orders');
        break;
    }
  }

  // Get filtered fertilizers based on selected category
  List<Map<String, dynamic>> get _filteredFertilizers {
    if (_selectedCategory == 'All Products') {
      return _farmingFertilizers;
    }
    return _farmingFertilizers.where((fertilizer) => 
      fertilizer['category'] == _selectedCategory
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seeds, Fertilizers & Soil Enhancers'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category selector
          _buildCategorySelector(),
          
          // Fertilizers list
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildFertilizersList(),
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

  Widget _buildFertilizersList() {
    if (_filteredFertilizers.isEmpty) {
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
      itemCount: _filteredFertilizers.length,
      itemBuilder: (context, index) {
        final fertilizer = _filteredFertilizers[index];
        return _buildFertilizerCard(fertilizer);
      },
    );
  }

  Widget _buildFertilizerCard(Map<String, dynamic> fertilizer) {
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
                // Fertilizer image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    fertilizer['image'],
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
                // Fertilizer details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fertilizer['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${fertilizer['price'].toStringAsFixed(2)}',
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
                            ' ${fertilizer['rating']} (${fertilizer['reviews']})',
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
                      'productName': fertilizer['name'],
                      'productPrice': fertilizer['price'],
                      'productImage': fertilizer['image'],
                      'availableQuantity': 20,
                      'farmerId': 'fertilizer_supplier_001',
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