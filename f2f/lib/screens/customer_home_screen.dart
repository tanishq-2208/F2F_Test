import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../screens/farmer_selection_screen.dart';
import '../widgets/customer_bottom_navigation_bar.dart';
import 'reel_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // Add this variable with other state variables
  int _selectedIndex = 0;

  // Add this method
  // Fix the navigation method
  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigation logic
    switch (index) {
      case 0: // Home
        // Already on home screen
        break;
      case 1: // Reels
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReelScreen()),
        );
        break;
      case 2: // Orders
        Navigator.pushNamed(context, '/my_orders');
        break;
    }
  }

  final PageController _bannerController = PageController();
  String _selectedCategory = 'Fruits';
  List<Product> _products = [];
  bool _isLoading = true;

  // Sample banner data - replace with actual data from your backend
  final List<String> _bannerImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Replace with actual API call to fetch products
      final products = await ProductService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  List<Product> get _filteredProducts {
    return _products.where((product) => 
      product.category.toLowerCase() == _selectedCategory.toLowerCase()
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // In the AppBar section of the build method
      appBar: AppBar(
        title: const Text('Farm2Fresh'),
        backgroundColor: Colors.green,
        actions: [
        // Wallet icon with image
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/wallet');
            },
            child: Image.asset(
              'assets/images/wallet.png',
              width: 24,
              height: 24,
              // Remove the color property to show the image in its original colors
            ),
          ),
        ),
        // Other existing action buttons
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ad Banner Carousel
              _buildBannerCarousel(),
              
              const SizedBox(height: 20),
              
              // Category Selection
              _buildCategorySelector(),
              
              const SizedBox(height: 16),
              
              // Products Grid
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildProductsGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationItemSelected,
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController, // Fix: Changed from bannerController to _bannerController
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    _bannerImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image not available'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _bannerController,
          count: _bannerImages.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: Colors.green,
            dotColor: Colors.grey,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'Fruits';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCategory == 'Fruits' 
                        ? Colors.green 
                        : Colors.grey[300],
                    foregroundColor: _selectedCategory == 'Fruits' 
                        ? Colors.white 
                        : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Fruits'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'Vegetables';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCategory == 'Vegetables' 
                        ? Colors.green 
                        : Colors.grey[300],
                    foregroundColor: _selectedCategory == 'Vegetables' 
                        ? Colors.white 
                        : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Vegetables'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No ${_selectedCategory.toLowerCase()} available at the moment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FarmerSelectionScreen(
                        productName: product.name,
                        productCategory: product.category,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }
}