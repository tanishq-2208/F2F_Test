import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:f2f/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:f2f/widgets/customer_bottom_navigation_bar.dart';
import 'package:f2f/screens/rate_farmer_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _oldDeliveredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cleanupCancelledOrders().then((_) => _loadOrders());
    _loadRandomDeliveredOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final orders = await _orderService.getCustomerOrders(
        context,
        status: 'all',
      );

      // Process each order
      for (var order in orders) {
        if (order['docId'] == null) {
          order['docId'] = order['orderId'];
        }

        // If order is marked as cancelled, delete it from Firestore
        if (order['status'] == 'Cancelled') {
          String? documentId = order['docId'] ?? order['orderId'];
          if (documentId != null) {
            try {
              await FirebaseFirestore.instance
                  .collection('orders')
                  .doc(documentId)
                  .delete();
              print('Deleted cancelled order: $documentId');
            } catch (e) {
              print('Error deleting cancelled order: $e');
            }
          }
        }
      }

      // Filter out cancelled orders from UI
      final filteredOrders =
          orders.where((order) => order['status'] != 'Cancelled').toList();

      setState(() {
        _orders = filteredOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading orders: $e';
        _isLoading = false;
      });
      print('Error loading orders: $e');
    }
  }

  Future<void> _cancelOrder(Map<String, dynamic> order) async {
    try {
      bool confirmCancel =
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Cancel Order'),
                  content: const Text(
                    'Are you sure you want to cancel this order? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Yes, Cancel',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
          ) ??
          false;

      if (!confirmCancel) return;

      String? documentId = order['docId'] ?? order['orderId'];

      if (documentId == null) {
        throw Exception('Cannot find document ID for this order');
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled and removed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cancelling order: $e')));
      print('Error cancelling order: $e');
    }
  }

  Future<void> _loadRandomDeliveredOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: user.uid)
              .where('status', isEqualTo: 'Delivered')
              .where('isRated', isEqualTo: false)
              .get();

      final deliveredOrders =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'orderId': data['orderId'] ?? doc.id,
              'docId': doc.id,
            };
          }).toList();

      setState(() {
        _oldDeliveredOrders = deliveredOrders;
      });
    } catch (e) {
      print('Error loading delivered orders: $e');
    }
  }

  void _onNavigationItemSelected(int index) {
    if (index == 2) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/customer_home');
        break;
      case 1:
        // Navigate to Reels page when implemented
        break;
    }
  }

  Widget _buildRatingsList() {
    if (_oldDeliveredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No orders to rate',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see orders here once they\'re delivered',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _oldDeliveredOrders.length,
      itemBuilder: (context, index) {
        final order = _oldDeliveredOrders[index];
        return _buildSwiggyStyleRatingCard(order);
      },
    );
  }

  Widget _buildSwiggyStyleRatingCard(Map<String, dynamic> order) {
    final orderDate =
        (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM, yyyy').format(orderDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Delivered Successfully',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[800],
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order['productImage'] ?? 'https://via.placeholder.com/150',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From: ${order['farmerName'] ?? 'Unknown Farmer'}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${order['quantity'] ?? 1} • ₹${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey[200]),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How was your experience?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return InkWell(
                      onTap: () => _rateFarmer(order, rating: index + 1),
                      child: Column(
                        children: [
                          Icon(Icons.star, color: Colors.grey[300], size: 36),
                          const SizedBox(height: 4),
                          Text(
                            [
                              'Poor',
                              'Average',
                              'Good',
                              'Very Good',
                              'Excellent',
                            ][index],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rateFarmer(Map<String, dynamic> order, {int rating = 0}) async {
    if (order['status'] != 'Delivered') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only rate after delivery is complete'),
        ),
      );
      return;
    }

    if (rating > 0) {
      try {
        await FirebaseFirestore.instance.collection('ratings').add({
          'farmerId': order['farmerId'] ?? '',
          'orderId': order['docId'] ?? order['orderId'] ?? '',
          'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
          'rating': rating.toDouble(),
          'comment': '',
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(order['docId'])
            .update({'isRated': true});

        await _updateFarmerRating(order['farmerId'] ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for rating ${rating.toString()} stars!'),
            backgroundColor: Colors.green[700],
          ),
        );

        _loadOrders();
        _loadRandomDeliveredOrders();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting rating: $e')));
      }
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RateFarmerScreen(
              farmerId: order['farmerId'] ?? '',
              farmerName: order['farmerName'] ?? 'Unknown Farmer',
              orderId: order['orderId'] ?? '',
              productName: order['productName'] ?? '',
            ),
      ),
    );

    if (result == true) {
      _loadOrders();
      _loadRandomDeliveredOrders();
    }
  }

  Future<void> _updateFarmerRating(String farmerId) async {
    try {
      final ratingsSnapshot =
          await FirebaseFirestore.instance
              .collection('ratings')
              .where('farmerId', isEqualTo: farmerId)
              .get();

      if (ratingsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }
      double averageRating = totalRating / ratingsSnapshot.docs.length;

      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(farmerId)
          .update({
            'averageRating': averageRating,
            'ratingCount': ratingsSnapshot.docs.length,
          });
    } catch (e) {
      print('Error updating farmer rating: $e');
    }
  }

  Widget _buildAllOrdersList() {
    if (_orders.isEmpty) {
      return _buildEmptyOrdersView();
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyOrdersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/customer_home',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderDate =
        (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy').format(orderDate);
    final orderStatus = order['status'] ?? 'Processing';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    color:
                        orderStatus == 'Cancelled'
                            ? Colors.red[100]
                            : Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    orderStatus,
                    style: TextStyle(
                      color:
                          orderStatus == 'Cancelled'
                              ? Colors.red[700]
                              : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        order['productImage'] ??
                            'https://via.placeholder.com/150',
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Qty: ${order['quantity'] ?? 0}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ₹${(order['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ordered on $formattedDate',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Row(
                  children: [
                    if (orderStatus != 'Cancelled' &&
                        orderStatus != 'Delivered')
                      TextButton.icon(
                        onPressed: () => _cancelOrder(order),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Cancel Order',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (orderStatus == 'Delivered' &&
                        !(order['isRated'] ?? false))
                      TextButton.icon(
                        onPressed: () => _rateFarmer(order),
                        icon: const Icon(Icons.star, color: Colors.orange),
                        label: const Text(
                          'Rate Order',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.green[800],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'All Orders'), Tab(text: 'Rate Farmers')],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildAllOrdersList(),
          _buildRatingsList(),
        ],
      ),
      bottomNavigationBar: CustomerBottomNavigationBar(
        selectedIndex: 2,
        onItemSelected: _onNavigationItemSelected,
      ),
    );
  }
}

// Add this method to clean up cancelled orders
Future<void> _cleanupCancelledOrders() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'Cancelled')
            .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
      print('Cleaned up cancelled order: ${doc.id}');
    }
  } catch (e) {
    print('Error cleaning up cancelled orders: $e');
  }
}//hi