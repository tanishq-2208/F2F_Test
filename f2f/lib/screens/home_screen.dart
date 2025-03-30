import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/farmer_bottom_navigation_bar.dart';
import 'package:f2f/utils/string_extensions.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _mainPageController = PageController();
  final PageController _bannerController = PageController();
  late AnimationController _bounceController;
  int _selectedIndex = 0;

  late List<Map<String, dynamic>> bannerContent;
  late List<Map<String, dynamic>> categories;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _initializeContent(BuildContext context) {
    bannerContent = [
      {
        'image': 'assets/images/banner1.png',
        'title': '50% OFF'.tr(context),
        'subtitle': 'On All Farming Tools'.tr(context),
      },
      {
        'image': 'assets/images/banner2.png',
        'title': 'New Arrivals'.tr(context),
        'subtitle': 'Latest Machinery Collection'.tr(context),
      },
      {
        'image': 'assets/images/banner3.png',
        'title': 'Special Deal'.tr(context),
        'subtitle': 'Premium Quality Seeds'.tr(context),
      },
    ];

    categories = [
      {
        'title': 'Hand Tools & Gardening Equipment'.tr(context),
        'icon': Icons.agriculture,
        'color': Colors.green[100] ?? Colors.green,
      },
      {
        'title': 'Machinery & Equipment'.tr(context),
        'icon': Icons.precision_manufacturing,
        'color': Colors.blue[100] ?? Colors.blue,
      },
      {
        'title': 'Seeds, Fertilizers & Soil Enhancers'.tr(context),
        'icon': Icons.eco,
        'color': Colors.orange[100] ?? Colors.orange,
      },
    ];
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
    // Initialize content with translations
    _initializeContent(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer's Marketplace".tr(context)),
        backgroundColor: Colors.green,
      ),
      body: PageView(
        controller: _mainPageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          _buildHomeContent(),
          Center(child: Text('AI Page'.tr(context))),
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
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.2),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
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
                Text(
                  'Categories'.tr(context),
                  style: const TextStyle(
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                  );
                }),
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
