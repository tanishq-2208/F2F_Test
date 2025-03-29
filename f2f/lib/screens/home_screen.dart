import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/farmer_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _mainPageController = PageController();
  final PageController _bannerController = PageController();
  late AnimationController _bounceController;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> bannerContent = [
    {'image': 'assets/images/banner1.png', 'title': '50% OFF', 'subtitle': 'On All Farming Tools'},
    {'image': 'assets/images/banner2.png', 'title': 'New Arrivals', 'subtitle': 'Latest Machinery Collection'},
    {'image': 'assets/images/banner3.png', 'title': 'Special Deal', 'subtitle': 'Premium Quality Seeds'},
  ];

  final List<Map<String, dynamic>> categories = [
    {'title': 'Hand Tools & Gardening Equipment', 'icon': Icons.agriculture, 'color': Colors.green[100] ?? Colors.green},
    {'title': 'Machinery & Equipment', 'icon': Icons.precision_manufacturing, 'color': Colors.blue[100] ?? Colors.blue},
    {'title': 'Seeds, Fertilizers & Soil Enhancers', 'icon': Icons.eco, 'color': Colors.orange[100] ?? Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _bounceController.forward().then((_) => _bounceController.reverse());
      _mainPageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer's Marketplace"),
        backgroundColor: Colors.green,
      ),
      body: PageView(
        controller: _mainPageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          _buildHomeContent(),
          const Center(child: Text('AI Page')),
          const Center(child: Text('Sell Page')),
          const Center(child: Text('Profile Page')),
        ],
      ),
      bottomNavigationBar: FarmerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: bannerContent.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: AssetImage(bannerContent[index]['image']),
                              fit: BoxFit.cover,
                              // In the banner image decoration
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.2), // Decreased from 0.3
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 40,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bannerContent[index]['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bannerContent[index]['subtitle'],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SmoothPageIndicator(
                  controller: _bannerController,
                  count: bannerContent.length,
                  effect: const WormEffect(
                    dotColor: Colors.white54,
                    activeDotColor: Colors.white,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                ...categories.map((category) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: category['color'],
                        child: Icon(category['icon'], color: Colors.green[700]),
                      ),
                      title: Text(
                        category['title'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _mainPageController.dispose();
    _bannerController.dispose();
    super.dispose();
  }
}
