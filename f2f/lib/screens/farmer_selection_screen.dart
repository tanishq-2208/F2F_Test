import 'package:f2f/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class FarmerSelectionScreen extends StatefulWidget {
  final String productName;

  const FarmerSelectionScreen({
    super.key,
    required this.productName, required String productCategory,
  });

  @override
  State<FarmerSelectionScreen> createState() => _FarmerSelectionScreenState();
}

class _FarmerSelectionScreenState extends State<FarmerSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _farmers = [];

  @override
  void initState() {
    super.initState();
    _fetchFarmersWithProduct();
  }

  Future<void> _fetchFarmersWithProduct() async {
    try {
      final querySnapshot = await _firestore
          .collection('sales')
          .orderBy('date', descending: true)
          .get();

      final Map<String, Map<String, dynamic>> farmersMap = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final farmerId = data['farmerId']?.toString() ?? '';
        final farmerName = data['farmerName']?.toString() ?? 'Unknown Farmer';

        if (farmerId.isEmpty) continue;

        if (data['items'] is List) {
          for (var item in data['items']) {
            if (item is Map) {
              final itemName = item['name']?.toString().trim() ?? '';
              
              // Only process items matching the product we're looking for
              if (itemName.toLowerCase() == widget.productName.toLowerCase()) {
                if (!farmersMap.containsKey(farmerId)) {
                  farmersMap[farmerId] = {
                    'farmerId': farmerId,
                    'farmerName': farmerName,
                    'totalQuantity': 0.0,
                    'pricePerUnit': 0.0,
                    'unit': 'kg',
                  };
                }

                // Update the farmer's total quantity and price
                final quantity = (item['quantity'] is num)
                    ? (item['quantity'] as num).toDouble()
                    : double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
                
                final price = (item['price'] is num)
                    ? (item['price'] as num).toDouble()
                    : double.tryParse(item['price']?.toString() ?? '0') ?? 0;
                
                final unit = item['unit']?.toString().toLowerCase() ?? 'kg';

                farmersMap[farmerId]!['totalQuantity'] += quantity;
                farmersMap[farmerId]!['pricePerUnit'] = price; // Use the latest price
                farmersMap[farmerId]!['unit'] = unit;
              }
            }
          }
        }
      }

      setState(() {
        _farmers = farmersMap.values.toList();
        _isLoading = false;
      });

    } catch (e) {
      print('Error fetching farmers data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLanguage == 'en' 
              ? 'Select Farmer for ${widget.productName}'
              : '${widget.productName} కోసం రైతును ఎంచుకోండి',
        ),
        backgroundColor: Colors.green.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _farmers.isEmpty
              ? Center(
                  child: Text(
                    currentLanguage == 'en'
                        ? 'No farmers available for ${widget.productName}'
                        : '${widget.productName} కోసం రైతులు అందుబాటులో లేరు',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _farmers.length,
                  itemBuilder: (context, index) {
                    final farmer = _farmers[index];
                    final quantity = farmer['totalQuantity'] ?? 0;
                    final price = farmer['pricePerUnit'] ?? 0;
                    final unit = farmer['unit'] ?? 'kg';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer['farmerName'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star_border, color: Colors.amber, size: 18),
                                Icon(Icons.star_border, color: Colors.amber, size: 18),
                                Icon(Icons.star_border, color: Colors.amber, size: 18),
                                Icon(Icons.star_border, color: Colors.amber, size: 18),
                                Icon(Icons.star_border, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                const Text('(0)'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${currentLanguage == 'en' ? 'Available' : 'అందుబాటులో'}: $quantity $unit',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '₹${price.toStringAsFixed(0)}/$unit',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: // In your product detail screen where the "Buy Now" button is located
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                              productImage: '', // Added required productImage parameter
                                              productPrice: farmer['pricePerUnit'],
                                              productName: widget.productName, availableQuantity: _farmers[index]['totalQuantity'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Buy Now'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}