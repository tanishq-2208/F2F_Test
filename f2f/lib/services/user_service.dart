import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user address
  Future<Map<String, dynamic>?> getUserAddress(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data();
        return userData?['address'] as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      print('Error getting user address: $e');
      return null;
    }
  }

  // Save user address
  Future<void> saveUserAddress(
    String userId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'address': addressData,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user address: $e');
      rethrow;
    }
  }
}
