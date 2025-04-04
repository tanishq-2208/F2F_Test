import 'package:flutter/material.dart';
import 'package:f2f/screens/farmer_login_screen.dart';
import 'package:f2f/screens/customer_login_screen.dart';
import 'package:f2f/widgets/language_toggle.dart';
import 'package:provider/provider.dart';
import 'package:f2f/services/language_service.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: false);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/leafy.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xB30A3818),
                  BlendMode.srcOver,
                ),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A3818), Color(0xFF1A5336)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title text
                    const Text(
                      'Farm2Fresh',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Fresh from Farm to Home',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Removed decorative elements row
                    const Spacer(),

                    // Green button at the bottom
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showRoleSelectionDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7ED957),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Start your green journey!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Animated flying leaves
          ...List.generate(
            5,
            (index) => AnimatedLeaf(
              animation: _animation,
              index: index,
              screenSize: screenSize,
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose your role',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF266241),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ED957),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                // Farmer option
                _buildRoleOption(
                  context: context,
                  icon: Icons.agriculture,
                  title: 'Farmer',
                  description: 'Sell your produce directly to customers',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FarmerLoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Customer option
                _buildRoleOption(
                  context: context,
                  icon: Icons.shopping_basket,
                  title: 'Customer',
                  description: 'Buy fresh produce directly from farmers',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerLoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF266241).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF266241), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF266241),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF7ED957),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedLeaf extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Size screenSize;

  const AnimatedLeaf({
    super.key,
    required this.animation,
    required this.index,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    // Different starting positions and speeds for each leaf
    final double delay = index * 0.2;
    final double size = 20.0 + index * 5.0;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate position based on animation value
        final double value = (animation.value + delay) % 1.0;

        // Start from top right, end at bottom left
        final double startX = screenSize.width * 0.8 - index * 20;
        final double startY = screenSize.height * 0.1 + index * 10;
        final double endX = screenSize.width * 0.2 - index * 15;
        final double endY = screenSize.height * 0.8 + index * 5;

        // Current position with a curved path
        final double currentX = startX + (endX - startX) * value;
        final double currentY = startY + (endY - startY) * value;

        // Add some wave motion
        final double waveOffset = math.sin(value * math.pi * 2) * 30;

        return Positioned(
          left: currentX + waveOffset,
          top: currentY,
          child: Transform.rotate(
            angle: value * math.pi * 4,
            child: Opacity(
              opacity: 0.7,
              child: Icon(Icons.eco, color: Colors.white, size: size),
            ),
          ),
        );
      },
    );
  }
}
