import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/farmer_bottom_navigation_bar.dart';
import 'package:f2f/utils/string_extensions.dart';
import 'package:provider/provider.dart';
import 'package:f2f/providers/language_provider.dart'; // Add this import

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
    // Get the language provider
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    bannerContent = [
      {
        'image': 'assets/images/banner1.png',
        'title': isTeluguSelected ? '50% తగ్గింపు' : '50% OFF',
        'subtitle':
            isTeluguSelected
                ? 'అన్ని వ్యవసాయ పనిముట్లపై'
                : 'On All Farming Tools',
      },
      {
        'image': 'assets/images/banner2.png',
        'title': isTeluguSelected ? 'కొత్త రాకలు' : 'New Arrivals',
        'subtitle':
            isTeluguSelected
                ? 'తాజా యంత్రాల సేకరణ'
                : 'Latest Machinery Collection',
      },
      {
        'image': 'assets/images/banner3.png',
        'title': isTeluguSelected ? 'ప్రత్యేక ఆఫర్' : 'Special Deal',
        'subtitle':
            isTeluguSelected
                ? 'ప్రీమియం నాణ్యత విత్తనాలు'
                : 'Premium Quality Seeds',
      },
    ];

    categories = [
      {
        'title':
            isTeluguSelected
                ? 'చేతి పనిముట్లు & తోటపని పరికరాలు'
                : 'Hand Tools & Gardening Equipment',
        'icon': Icons.agriculture,
        'color': Colors.green[100] ?? Colors.green,
      },
      {
        'title':
            isTeluguSelected ? 'యంత్రాలు & పరికరాలు' : 'Machinery & Equipment',
        'icon': Icons.precision_manufacturing,
        'color': Colors.blue[100] ?? Colors.blue,
      },
      {
        'title':
            isTeluguSelected
                ? 'విత్తనాలు, ఎరువులు & నేల మెరుగుదలలు'
                : 'Seeds, Fertilizers & Soil Enhancers',
        'icon': Icons.eco,
        'color': Colors.orange[100] ?? Colors.orange,
      },
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _bounceController.forward().then((_) => _bounceController.reverse());

      // Handle navigation based on the selected index
      switch (index) {
        case 0:
          // Already on home page
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/upload_items');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/plant_analysis');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to language changes
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    // Initialize content with translations
    _initializeContent(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A5336), // Lighter dark green background
      appBar: AppBar(
        title: Text(
          isTeluguSelected ? "రైతు మార్కెట్‌ప్లేస్" : "Farmer's Marketplace",
          style: const TextStyle(
            color: Colors.white, // Changed text color to white
          ),
        ),
        backgroundColor: const Color(0xFF266241), // Lighter green for app bar
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language,
              color: Colors.white, // Ensuring icon is also white
            ),
            onPressed: () {
              // Toggle language between English and Telugu
              languageProvider.setLanguage(isTeluguSelected ? 'en' : 'te');
            },
          ),
        ],
      ),
      body: PageView(
        controller: _mainPageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          _buildHomeContent(isTeluguSelected),
        ], // Pass the language flag here
      ),
      bottomNavigationBar: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            height: 70, // Increased height
            decoration: BoxDecoration(
              color: const Color(0xFFD8E6C9), // Using solid color
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
                data: Theme.of(context).copyWith(
                  canvasColor: const Color(0xFFD8E6C9),
                ),
                child: FarmerBottomNavigationBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildHomeContent(bool isTeluguSelected) {
    // Accept the parameter here
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
                  isTeluguSelected ? 'వర్గాలు' : 'Categories',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Changed to white for better contrast
                  ),
                ),
                const SizedBox(height: 16),
                ...categories.map((category) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color(0xFFECF6E5), // Updated to specified color code
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: category['color'],
                        child: Icon(category['icon'], color: Colors.green[700]),
                      ),
                      title: Text(
                        category['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800], // Darker text for contrast with light background
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[800]),
                      onTap: () {
                        // Navigate based on category title
                        if (category['title'] == 'Hand Tools & Gardening Equipment' || 
                            category['title'] == 'చేతి పనిముట్లు & తోటపని పరికరాలు') {
                          Navigator.pushNamed(context, '/farmer_tools');
                        } else if (category['title'] == 'Machinery & Equipment' || 
                                category['title'] == 'యంత్రాలు & పరికరాలు') {
                          Navigator.pushNamed(context, '/farmer_machinery');
                        } else if (category['title'] == 'Seeds, Fertilizers & Soil Enhancers' || 
                                category['title'] == 'విత్తనాలు, ఎరువులు & నేల మెరుగుదలలు') {
                          Navigator.pushNamed(context, '/farmer_fertilizers');
                        }
                        // Add other category navigations here as needed
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // "Start your green journey" button removed
          
          const SizedBox(height: 20),
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
