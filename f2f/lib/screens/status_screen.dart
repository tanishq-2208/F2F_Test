import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:f2f/services/language_service.dart';
import 'package:intl/intl.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _sales = [];

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('No user logged in');
      setState(() => _isLoading = false);
      return;
    }

    try {
      print('Fetching sales data for farmer: ${user.uid}');
      
      // First try the composite index query
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('sales')
            .where('farmerId', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .get();
      } catch (e) {
        // Fallback to simple query if index isn't ready
        print('Composite index query failed, falling back to simple query: $e');
        querySnapshot = await _firestore
            .collection('sales')
            .where('farmerId', isEqualTo: user.uid)
            .get();
      }

      print('Found ${querySnapshot.docs.length} sales documents');
      List<Map<String, dynamic>> sales = [];
      
      for (var doc in querySnapshot.docs) {
        final saleData = doc.data() as Map<String, dynamic>;
        print('Processing sale ID: ${doc.id}');
        
        // Parse timestamp if it exists
        final timestamp = saleData['timestamp'] as Timestamp?;
        final formattedDate = timestamp != null 
            ? DateFormat('MMM dd, yyyy hh:mm a').format(timestamp.toDate())
            : saleData['date'] ?? 'N/A';

        sales.add({
          ...saleData,
          'id': doc.id,
          'formattedDate': formattedDate,
          // Items are already in the document according to your Firestore structure
          'products': (saleData['items'] as List<dynamic>?)?.map((item) {
            return {
              'name': item['name'],
              'quantity': item['quantity'],
              'unit': item['unit'],
              'price': item['price'],
              'total': item['total'],
            };
          }).toList() ?? [],
        });
      }

      // Sort by date if we used the fallback query
      if (!querySnapshot.metadata.isFromCache) {
        sales.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
      }

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
      print('Sales data loaded successfully');
    } catch (e) {
      print('Error fetching sales data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching sales: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, BuildContext context) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final currentLanguage = languageService.currentLocale.languageCode;
    
    switch (status.toLowerCase()) {
      case 'pending':
        return currentLanguage == 'en' ? 'Pending' : 'పెండింగ్‌లో ఉంది';
      case 'completed':
        return currentLanguage == 'en' ? 'Completed' : 'పూర్తయింది';
      case 'cancelled':
        return currentLanguage == 'en' ? 'Cancelled' : 'రద్దు చేయబడింది';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLanguage == 'en' ? 'Sales Status' : 'అమ్మకాల స్థితి'),
        backgroundColor: Colors.green.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSalesData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        currentLanguage == 'en' 
                            ? 'No sales records found' 
                            : 'అమ్మకాల రికార్డులు లేవు',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchSalesData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sales.length,
                    itemBuilder: (context, index) {
                      final sale = _sales[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sale header
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(sale['status'] ?? ''),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getStatusText(sale['status'] ?? '', context),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${(sale['totalAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${currentLanguage == 'en' ? 'Date' : 'తేదీ'}: ${sale['formattedDate']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              
                              // Products list
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                currentLanguage == 'en' ? 'Products' : 'ఉత్పత్తులు',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(sale['products'] as List<dynamic>).map<Widget>((product) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${product['name']} (${product['quantity']} ${product['unit']})',
                                        ),
                                      ),
                                      Text(
                                        '₹${(product['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}