import 'package:f2f/screens/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/customer_bottom_navigation_bar.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({super.key});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late List<VideoPlayerController> _controllers;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, bool> _likedStates = {};
  
  // Define the reels data
  final List<Map<String, dynamic>> _reels = [
    {
      'videoUrl': 'assets/videos/farming1.mp4',
      'title': 'Modern Greenhouse Farming',
      'farmerName': 'Raj Kumar',
      'likes': '15.2K',
      'description': 'Growing organic vegetables in greenhouse 🌱',
    },
    {
      'videoUrl': 'assets/videos/farming2.mp4',
      'title': 'Fresh Harvest Season',
      'farmerName': 'Priya Patel',
      'likes': '12.8K',
      'description': 'Harvesting fresh tomatoes from our farm! 🍅',
    },
    {
      'videoUrl': 'assets/videos/farming3.mp4',
      'title': 'Organic Lettuce Farm',
      'farmerName': 'Amit Singh',
      'likes': '9.5K',
      'description': 'Quality organic lettuce farming 🥬',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    _controllers = _reels.map((reel) {
      final controller = VideoPlayerController.asset(reel['videoUrl']);
      controller.initialize().then((_) {
        controller.setLooping(true);
        if (_reels.indexOf(reel) == _currentPage) {
          controller.play();
        }
      });
      return controller;
    }).toList();
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int index) {
    setState(() {
      _controllers[_currentPage].pause();
      _currentPage = index;
      if (_controllers[index].value.isInitialized) {
        _controllers[index].play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _reels.length,
            itemBuilder: (context, index) {
              return _buildReelItem(_reels[index], index);
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomerBottomNavigationBar(
        selectedIndex: 1, // Set to 1 for Reels tab
        onItemSelected: (index) {
          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
              );
              break;
            case 2: // Orders
              Navigator.pushNamed(context, '/my_orders');
              break;
          }
        },
      ),
    );
  }

  Widget _buildReelItem(Map<String, dynamic> reel, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _controllers[index].value.isInitialized
            ? VideoPlayer(_controllers[index])
            : const Center(child: CircularProgressIndicator()),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reel['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reel['description'],
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        reel['farmerName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          _likedStates[index] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _likedStates[index] == true
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _likedStates[index] = !(_likedStates[index] ?? false);
                          });
                        },
                      ),
                      Text(
                        reel['likes'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}