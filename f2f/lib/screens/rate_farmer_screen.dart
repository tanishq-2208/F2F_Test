import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateFarmerScreen extends StatefulWidget {
  final String farmerId;
  final String farmerName;
  final String orderId;
  final String productName;

  const RateFarmerScreen({
    super.key,
    required this.farmerId,
    required this.farmerName,
    required this.orderId,
    required this.productName,
  });

  @override
  State<RateFarmerScreen> createState() => _RateFarmerScreenState();
}

class _RateFarmerScreenState extends State<RateFarmerScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Add rating to Firestore
      await FirebaseFirestore.instance.collection('ratings').add({
        'farmerId': widget.farmerId,
        'orderId': widget.orderId,
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'rating': _rating.toDouble(),
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mark order as rated
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'isRated': true});

      // Update farmer's average rating
      await _updateFarmerRating();

      // Return success to previous screen
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting rating: $e')));
    }
  }

  Future<void> _updateFarmerRating() async {
    try {
      final ratingsSnapshot =
          await FirebaseFirestore.instance
              .collection('ratings')
              .where('farmerId', isEqualTo: widget.farmerId)
              .get();

      if (ratingsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      // Include the current rating
      totalRating += _rating;
      double averageRating = totalRating / (ratingsSnapshot.docs.length + 1);

      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.farmerId)
          .update({
            'averageRating': averageRating,
            'ratingCount': ratingsSnapshot.docs.length + 1,
          });
    } catch (e) {
      print('Error updating farmer rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A5336), // Dark green background
      appBar: AppBar(
        title: const Text('Rate Farmer'),
        backgroundColor: const Color(0xFF266241), // Matching app bar color
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isSubmitting
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farmer and product info card
                    Card(
                      elevation: 4,
                      color: const Color(0xFFECF6E5), // Light green background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rate your experience with',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.farmerName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Product: ${widget.productName}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Rating stars
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'How would you rate your experience?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color:
                                      index < _rating
                                          ? Colors.amber
                                          : Colors.grey,
                                  size: 40,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _rating > 0
                                ? [
                                  'Poor',
                                  'Fair',
                                  'Good',
                                  'Very Good',
                                  'Excellent',
                                ][_rating - 1]
                                : 'Tap to rate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _rating > 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Comment field
                    const Text(
                      'Share your experience (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Tell us about your experience with this farmer...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF266241,
                          ), // Matching app bar color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit Rating',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
