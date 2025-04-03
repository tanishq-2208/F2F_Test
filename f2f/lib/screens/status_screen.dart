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
  List<Map<String, dynamic>> _orders = [];
  String? _farmerId;

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
    _fetchOrdersData();
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

  // In the _fetchOrdersData method, ensure we're querying by the correct farmerId field
  // Your _fetchOrdersData method is already correctly querying by farmerId
  // But let's add some debugging to verify the data structure

  Future<void> _fetchOrdersData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('No user logged in');
      setState(() => _isLoading = false);
      return;
    }
  
    try {
      // Check if the user is a farmer
      final farmerDoc = await _firestore
          .collection('farmers')
          .where('userId', isEqualTo: user.uid)
          .get();
  
      if (farmerDoc.docs.isEmpty) {
        print('User is not a farmer');
        setState(() => _isLoading = false);
        return;
      }
  
      _farmerId = farmerDoc.docs.first.id;
      print('Fetching orders for farmer ID: $_farmerId');
  
      // Get all orders for this farmer's products
      final querySnapshot = await _firestore
          .collection('orders')
          .where('farmerId', isEqualTo: _farmerId)
          .orderBy('orderDate', descending: true)
          .get();
  
      print('Found ${querySnapshot.docs.length} orders for this farmer');
      
      // Debug the first order if available
      if (querySnapshot.docs.isNotEmpty) {
        print('Sample order data: ${querySnapshot.docs.first.data()}');
      }
      
      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'orderId': data['orderId'] ?? doc.id,
          'docId': doc.id,
        };
      }).toList();
  
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
      print('Orders data loaded successfully');
    } catch (e) {
      print('Error fetching orders data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderDate = (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy').format(orderDate);
    final status = order['status'] ?? 'Processing';
    final customerName = order['customerName'] ?? 'Customer';
    final customerPhone = order['customerPhone'] ?? 'N/A';
    final deliveryAddress = order['deliveryAddress'] ?? 'N/A';
    
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['orderId'] ?? ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Delivered' ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Delivered' ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Date: $formattedDate',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            // Customer information section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer: $customerName',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (customerPhone != 'N/A')
                    Text('Phone: $customerPhone'),
                  if (deliveryAddress != 'N/A')
                    Text('Address: $deliveryAddress'),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(order['productImage'] ?? 'https://via.placeholder.com/150'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${order['quantity'] ?? 0}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ₹${(order['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Add a deliver button if order is not delivered yet
            if (status != 'Delivered' && _farmerId != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => _markAsDelivered(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark as Delivered'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Update the _markAsDelivered method to handle both sales and orders
  Future<void> _markAsDelivered(Map<String, dynamic> item) async {
    try {
      // Check if this is a sale or an order based on available fields
      if (item.containsKey('docId')) {
        // This is an order
        await _firestore
            .collection('orders')
            .doc(item['docId'])
            .update({
          'status': 'Delivered',
          'deliveryDate': FieldValue.serverTimestamp(),
          'isRated': false, // Initialize as not rated yet
        });
        
        // Refresh the orders list
        _fetchOrdersData();
      } else if (item.containsKey('id')) {
        // This is a sale
        await _firestore
            .collection('sales')
            .doc(item['id'])
            .update({
          'status': 'completed',
          'deliveryDate': FieldValue.serverTimestamp(),
          'isRated': false, // Initialize as not rated yet
        });
        
        // Refresh the sales list
        _fetchSalesData();
      } else {
        throw Exception('Unknown item type - cannot update');
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order marked as delivered!'),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      print('Error updating order/sale: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.currentLocale.languageCode;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A5336), // Updated background color
        appBar: AppBar(
          title: Text(
            currentLanguage == 'en' ? 'Order Status' : 'ఆర్డర్ స్థితి',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF266241), // Updated app bar color
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: currentLanguage == 'en' ? 'Sales' : 'అమ్మకాలు',
              ),
              Tab(
                text: currentLanguage == 'en' ? 'Orders' : 'ఆర్డర్లు',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Sales tab
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sales.isEmpty
                    ? Center(
                        child: Text(
                          currentLanguage == 'en'
                              ? 'No sales found'
                              : 'అమ్మకాలు కనుగొనబడలేదు',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Updated text color
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: _sales.length,
                        itemBuilder: (context, index) {
                          return _buildSaleCard(_sales[index]);
                        },
                      ),
            
            // Orders tab
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? Center(
                        child: Text(
                          currentLanguage == 'en'
                              ? 'No orders found'
                              : 'ఆర్డర్లు కనుగొనబడలేదు',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Updated text color
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(_orders[index]);
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: const Color(0xFFECF6E5), // Updated card color
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
                    color: _getStatusColor(sale['status'] ?? 'pending'),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(sale['status'] ?? 'pending', context),
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
            const SizedBox(height: 8),
            Text(
              'Date: ${sale['formattedDate'] ?? 'N/A'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Products list
            if ((sale['products'] as List<dynamic>?)?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...((sale['products'] as List<dynamic>?) ?? []).map((product) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              product['name'] ?? 'Unknown Product',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${product['quantity']} ${product['unit'] ?? ''}',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${(product['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Customer info
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Customer: ${sale['customerName'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Delivery address
            if (sale['deliveryAddress'] != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Address: ${sale['deliveryAddress']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            
            // Mark as delivered button if status is pending
            if ((sale['status'] ?? '').toLowerCase() == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () => _markAsDelivered(sale),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF266241),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    Provider.of<LanguageService>(context).currentLocale.languageCode == 'en'
                        ? 'Mark as Delivered'
                        : 'డెలివరీ అయినట్లు గుర్తించండి',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCardView(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: const Color(0xFFECF6E5), // Updated card color
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer information section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer: ${order['customerName'] ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (order['customerPhone'] != 'N/A')
                    Text('Phone: ${order['customerPhone']}'),
                  if (order['deliveryAddress'] != 'N/A')
                    Text('Address: ${order['deliveryAddress']}'),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(order['productImage'] ?? 'https://via.placeholder.com/150'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${order['quantity'] ?? 0}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ₹${(order['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Add a deliver button if order is not delivered yet
            if (order['status'] != 'Delivered' && _farmerId != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => _markAsDelivered(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark as Delivered'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}