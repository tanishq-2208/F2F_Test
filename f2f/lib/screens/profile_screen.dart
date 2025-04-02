import 'package:f2f/widgets/farmer_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:f2f/providers/language_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Handle navigation based on the selected index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/plant_analysis');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/upload_items');
          break;
        case 3:
          // Already on profile page
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get language provider
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeluguSelected ? 'ప్రొఫైల్' : 'Profile'),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/farmer.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isTeluguSelected ? 'రాజు రెడ్డి' : 'Usham Reddy',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTeluguSelected ? 'రైతు' : 'Farmer',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTeluguSelected
                            ? 'వ్యక్తిగత సమాచారం'
                            : 'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.phone,
                        isTeluguSelected ? 'ఫోన్' : 'Phone',
                        '+91 9876543210',
                      ),
                      _buildInfoRow(
                        Icons.location_on,
                        isTeluguSelected ? 'చిరునామా' : 'Address',
                        isTeluguSelected
                            ? 'గ్రామం: రాజుపాలెం, మండలం: కొత్తపల్లి,\nజిల్లా: గుంటూరు, ఆంధ్రప్రదేశ్'
                            : 'Village: Rajupalem, Mandal: Kottapalli,\nDistrict: Guntur, Andhra Pradesh',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTeluguSelected ? 'వ్యవసాయ వివరాలు' : 'Farm Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.landscape,
                        isTeluguSelected ? 'భూమి పరిమాణం' : 'Land Size',
                        isTeluguSelected ? '5 ఎకరాలు' : '5 Acres',
                      ),
                      _buildInfoRow(
                        Icons.water_drop,
                        isTeluguSelected
                            ? 'నీటిపారుదల వనరులు'
                            : 'Irrigation Sources',
                        isTeluguSelected
                            ? 'బోరు బావి, చెరువు'
                            : 'Bore Well, Pond',
                      ),
                      _buildInfoRow(
                        Icons.eco,
                        isTeluguSelected ? 'ప్రధాన పంటలు' : 'Main Crops',
                        isTeluguSelected
                            ? 'వరి, పత్తి, కూరగాయలు'
                            : 'Rice, Cotton, Vegetables',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTeluguSelected ? 'అమ్మకాల చరిత్ర' : 'Sales History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const Divider(),
                      _buildSaleItem(
                        isTeluguSelected ? 'టమాటా' : 'Tomatoes',
                        isTeluguSelected ? '50 కిలోలు' : '50 kg',
                        '₹2,500',
                        isTeluguSelected ? '15 రోజుల క్రితం' : '15 days ago',
                      ),
                      _buildSaleItem(
                        isTeluguSelected ? 'వంగ' : 'Eggplant',
                        isTeluguSelected ? '30 కిలోలు' : '30 kg',
                        '₹1,800',
                        isTeluguSelected ? '20 రోజుల క్రితం' : '20 days ago',
                      ),
                      _buildSaleItem(
                        isTeluguSelected ? 'బంగాళాదుంప' : 'Potatoes',
                        isTeluguSelected ? '100 కిలోలు' : '100 kg',
                        '₹3,000',
                        isTeluguSelected ? '1 నెల క్రితం' : '1 month ago',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Logout functionality
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isTeluguSelected ? 'లాగ్ అవుట్' : 'Logout',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FarmerBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItem(
    String crop,
    String quantity,
    String amount,
    String date,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.eco, color: Colors.green.shade800, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  quantity,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
