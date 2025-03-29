import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/rating.dart';
import '../services/farmer_service.dart';
import 'rate_farmer_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _completedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompletedOrders();
  }

  Future<void> _loadCompletedOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await FarmerService.getCompletedOrders();
      setState(() {
        _completedOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Completed')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active orders tab
          const Center(child: Text('No active orders')),

          // Completed orders tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCompletedOrdersList(),
        ],
      ),
    );
  }

  Widget _buildCompletedOrdersList() {
    if (_completedOrders.isEmpty) {
      return const Center(child: Text('No completed orders'));
    }

    return RefreshIndicator(
      onRefresh: _loadCompletedOrders,
      child: ListView.builder(
        itemCount: _completedOrders.length,
        itemBuilder: (context, index) {
          final order = _completedOrders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order['orderId']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(DateTime.parse(order['orderDate'].toString())),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Product: ${order['productName']}'),
                  Text('Farmer: ${order['farmerName']}'),
                  const SizedBox(height: 16),
                  if (!order['isRated'])
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RateFarmerScreen(
                                    farmerId: order['farmerId'],
                                    farmerName: order['farmerName'],
                                    orderId: order['orderId'],
                                    productName: order['productName'],
                                  ),
                            ),
                          );

                          if (result == true) {
                            // Refresh the list after rating
                            _loadCompletedOrders();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                        child: const Text('Rate this order'),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Rated',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
