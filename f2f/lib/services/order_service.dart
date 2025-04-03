import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new order in Firebase
  // Make sure your createOrder method in OrderService accepts a non-nullable String for farmerId
  Future<String> createOrder({
    required String productName,
    required double productPrice,
    required int quantity,
    required String productImage,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    required String phone,
    required String farmerId, // This is expecting a non-nullable String
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final timestamp = Timestamp.now();
      final orderId = 'ORD-${timestamp.seconds}';
      
      final fullAddress = '$address, $city, $state - $zipCode';
      
      final orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'userEmail': user.email,
        'productName': productName,
        'productPrice': productPrice,
        'quantity': quantity,
        'totalAmount': productPrice * quantity + 40, // Including delivery fee
        'productImage': productImage,
        'deliveryAddress': fullAddress,
        'phoneNumber': phone,
        'status': 'Confirmed',
        'paymentStatus': 'Paid',
        'orderDate': timestamp,
        'estimatedDelivery': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
      };

      // Save to Firestore
      await _firestore.collection('orders').doc(orderId).set(orderData);
      
      // Also save to user's orders subcollection for better querying
      await _firestore
          .collection('customers')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId)
          .set(orderData);
      
      return orderId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get customer orders from Firebase
  // In your OrderService class, modify the getCustomerOrders method:
  
  // Update or add this method to get customer orders
  Future<List<Map<String, dynamic>>> getCustomerOrders(BuildContext context, {String status = 'all'}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
  
      // Create a query based on the user ID
      Query query = FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid);
      
      // If a specific status is requested (not 'all'), filter by that status
      if (status != 'all') {
        query = query.where('status', isEqualTo: status);
      }
      
      // Execute the query
      final querySnapshot = await query.get();
  
      // Convert the documents to a list of maps
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'orderId': data['orderId'] ?? doc.id,
          'docId': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error fetching customer orders: $e');
      rethrow;
    }
  }
  
  // Update order status in Firebase
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Update in main orders collection
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'lastUpdated': Timestamp.now(),
      });
      
      // Also update in user's orders subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
  
  // Get a single order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }
  
  void _showIndexErrorDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Index Required'),
        content: const Text(
          'This app requires a database index to be created. Please click "Create Index" and follow the instructions on the Firebase console.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              Navigator.pop(context);
            },
            child: const Text('Create Index'),
          ),
        ],
      ),
    );
  }
  
  // Add this method to your OrderService class
  
  Future<void> markOrderAsRated(String orderId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      await _firestore.collection('orders').doc(orderId).update({
        'isRated': true,
      });
    } catch (e) {
      print('Error marking order as rated: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOldDeliveredOrders(BuildContext context, {int limit = 2}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
  
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Delivered')
          .limit(limit)
          .get();
  
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'orderId': data['orderId'] ?? doc.id,
          'docId': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error fetching old delivered orders: $e');
      rethrow;
    }
  }

  // Add this method to your OrderService class
  // Add this method to your OrderService class if it doesn't exist already
  
  // Add this method to your OrderService class
  Future<List<Map<String, dynamic>>> getRandomDeliveredOrders(BuildContext context, {int limit = 2}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
  
      // Get all delivered orders
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Delivered')
          .get();
  
      // Convert to list and shuffle to get random orders
      final allOrders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'orderId': data['orderId'] ?? doc.id,
          'docId': doc.id,
        };
      }).toList();
      
      // Shuffle the list to randomize
      allOrders.shuffle();
      
      // Return up to the limit number of orders
      return allOrders.take(limit).toList();
    } catch (e) {
      print('Error fetching random delivered orders: $e');
      rethrow;
    }
  }
}