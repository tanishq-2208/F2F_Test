import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../screens/farmer_selection_screen.dart';  // Note: singular 'farmer', not 'farmers'
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
  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        // Navigate to reels
        Navigator.pushNamed(context, '/reels_screen');
        break;
      case 2:
        // Navigate to orders
        Navigator.pushNamed(context, '/my_orders');
        break;
      case 3:
        // Navigate to ratings
        Navigator.pushNamed(context, '/ratings');
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
    return _products
        .where(
          (product) =>
              product.category.toLowerCase() == _selectedCategory.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1A5336,
      ), // Dark green background matching home_screen
      appBar: AppBar(
        title: const Text('Farm2Fresh'),
        backgroundColor: const Color(0xFF266241), // Matching green for app bar
        foregroundColor: Colors.white,
        elevation: 0,
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
                color: Colors.white, // Making icon white to match theme
              ),
            ),
          ),
          // Other existing action buttons
        ],
      ),
      body: RefreshIndicator(
        color: Colors.white, // White color for refresh indicator
        backgroundColor: const Color(0xFF266241), // Green background
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
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : _buildProductsGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        height: 70, // Increased height
        decoration: BoxDecoration(
          color: const Color(0xFFD8E6C9), // Matching color from home_screen
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
            data: Theme.of(
              context,
            ).copyWith(canvasColor: const Color(0xFFD8E6C9)),
            child: CustomerBottomNavigationBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            ),
          ),
        ),
      ),
    );
  }

  // Update the banner images with promotional content
  // Update the banner data to use internet images
  final List<Map<String, dynamic>> _bannerData = [
    {
      'image':
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=1170&auto=format&fit=crop',
      'title': '50% OFF',
      'subtitle': 'Fresh Seasonal Fruits',
      'color': Colors.orange,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?q=80&w=1169&auto=format&fit=crop',
      'title': 'SPECIAL OFFER',
      'subtitle': 'Organic Vegetables at 30% OFF',
      'color': Colors.green[700],
    },
    {
      'image':
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?q=80&w=1170&auto=format&fit=crop',
      'title': 'FARM FRESH',
      'subtitle': 'Buy Direct from Farmers',
      'color': Colors.blue[700],
    },
  ];

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerData.length,
            itemBuilder: (context, index) {
              final banner = _bannerData[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // Banner image - changed from Image.asset to Image.network
                      Image.network(
                        banner['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green[700]!,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Image not available'),
                            ),
                          );
                        },
                      ),
                      // Rest of the stack remains the same
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: banner['color'],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                banner['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['subtitle'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _bannerController,
          count: _bannerData.length,
          effect: const WormEffect(
            dotColor: Colors.white54,
            activeDotColor: Colors.white,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 8,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark background
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
                    backgroundColor:
                        _selectedCategory == 'Fruits'
                            ? const Color(
                              0xFFECF6E5,
                            ) // Light green from home_screen
                            : Colors.white.withOpacity(0.2),
                    foregroundColor:
                        _selectedCategory == 'Fruits'
                            ? Colors.green[800]
                            : Colors.white,
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
                    backgroundColor:
                        _selectedCategory == 'Vegetables'
                            ? const Color(
                              0xFFECF6E5,
                            ) // Light green from home_screen
                            : Colors.white.withOpacity(0.2),
                    foregroundColor:
                        _selectedCategory == 'Vegetables'
                            ? Colors.green[800]
                            : Colors.white,
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
            style: const TextStyle(fontSize: 16, color: Colors.white70),
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
      elevation: 4,
      color: const Color(0xFFECF6E5), // Light green background from home_screen
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
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
                  backgroundColor: const Color(
                    0xFF266241,
                  ), // Matching app bar color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
