import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  // Singleton pattern
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get wallet reference for current user
  DocumentReference get _walletRef => 
      _firestore.collection('wallets').doc(currentUserId);

  // Get transaction collection reference for current user
  CollectionReference get _transactionsRef => 
      _walletRef.collection('transactions');

  // Get wallet balance
  Future<double> getBalance() async {
    if (currentUserId == null) return 0.0;
    
    try {
      final walletDoc = await _walletRef.get();
      if (!walletDoc.exists) {
        // Create wallet if it doesn't exist
        await _walletRef.set({'balance': 0.0});
        return 0.0;
      }
      
      final data = walletDoc.data() as Map<String, dynamic>;
      return (data['balance'] ?? 0.0).toDouble();
    } catch (e) {
      print('Error getting wallet balance: $e');
      return 0.0;
    }
  }

  // Check if user has enough balance
  Future<bool> hasEnoughBalance(double amount) async {
    final balance = await getBalance();
    return balance >= amount;
  }

  // Add amount to wallet
  Future<bool> addAmount(double amount, String description) async {
    if (currentUserId == null) return false;
    if (amount <= 0) return false;
    
    try {
      // Use transaction to ensure data consistency
      return await _firestore.runTransaction<bool>((transaction) async {
        final walletDoc = await transaction.get(_walletRef);
        
        double currentBalance = 0.0;
        if (walletDoc.exists) {
          final data = walletDoc.data() as Map<String, dynamic>;
          currentBalance = (data['balance'] ?? 0.0).toDouble();
        }
        
        final newBalance = currentBalance + amount;
        
        // Update wallet balance
        transaction.set(_walletRef, {'balance': newBalance}, SetOptions(merge: true));
        
        // Add transaction record
        final transactionData = {
          'amount': amount,
          'type': 'credit',
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        };
        
        transaction.set(_transactionsRef.doc(), transactionData);
        
        return true;
      });
    } catch (e) {
      print('Error adding amount to wallet: $e');
      return false;
    }
  }

  // Deduct amount from wallet
  Future<bool> deductAmount(double amount, String description) async {
    if (currentUserId == null) return false;
    if (amount <= 0) return false;
    
    try {
      // Use transaction to ensure data consistency
      return await _firestore.runTransaction<bool>((transaction) async {
        final walletDoc = await transaction.get(_walletRef);
        
        if (!walletDoc.exists) {
          return false;
        }
        
        final data = walletDoc.data() as Map<String, dynamic>;
        final currentBalance = (data['balance'] ?? 0.0).toDouble();
        
        if (currentBalance < amount) {
          return false;
        }
        
        final newBalance = currentBalance - amount;
        
        // Update wallet balance
        transaction.update(_walletRef, {'balance': newBalance});
        
        // Add transaction record
        final transactionData = {
          'amount': amount,
          'type': 'debit',
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        };
        
        transaction.set(_transactionsRef.doc(), transactionData);
        
        return true;
      });
    } catch (e) {
      print('Error deducting amount from wallet: $e');
      return false;
    }
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>> getTransactions() async {
    if (currentUserId == null) return [];
    
    try {
      final querySnapshot = await _transactionsRef
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as Timestamp?;
        
        return {
          'id': doc.id,
          'amount': data['amount'] ?? 0.0,
          'type': data['type'] ?? '',
          'description': data['description'] ?? '',
          'date': timestamp?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }
}