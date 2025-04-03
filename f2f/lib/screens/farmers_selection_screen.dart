import 'package:f2f/screens/products_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmersSelectionScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final double productPrice;
  final String productImage;
  final int availableQuantity;
  final String unit;

  const FarmersSelectionScreen({
    Key? key,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.availableQuantity,
    required this.unit,
  }) : super(key: key);

  @override
  State<FarmersSelectionScreen> createState() => _FarmersSelectionScreenState();
}

class _FarmersSelectionScreenState extends State<FarmersSelectionScreen> {
  int quantity = 1;
  String? quantityError;
  String? farmerId; // Add this variable to store the farmer ID
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchFarmerId(); // Call method to fetch farmer ID when screen initializes
  }

  // Add this method to fetch the farmer ID
  Future<void> _fetchFarmerId() async {
    try {
      // Get the product document to find the associated farmer
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      
      if (productDoc.exists) {
        setState(() {
          farmerId = productDoc.data()?['farmerId'];
          isLoading = false;
        });
        print('Fetched farmerId: $farmerId');
      } else {
        print('Product document not found');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching farmerId: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.productPrice * quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.productImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Product name and price
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '₹${widget.productPrice.toStringAsFixed(2)}/${widget.unit}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Available: ${widget.availableQuantity} ${widget.unit}',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.availableQuantity < 5 ? Colors.red[700] : Colors.grey[700],
                    fontWeight: widget.availableQuantity < 5 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Quantity selector
            Row(
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                        quantityError = null;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.green[700],
                  iconSize: 32,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (quantity < widget.availableQuantity) {
                      setState(() {
                        quantity++;
                        quantityError = null;
                      });
                    } else {
                      setState(() {
                        quantityError = 'Cannot exceed available quantity';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot exceed available quantity'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: quantity < widget.availableQuantity 
                      ? Colors.green[700] 
                      : Colors.grey[400],
                  iconSize: 32,
                ),
              ],
            ),
            
            if (quantityError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  quantityError!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Total price
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buy now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (widget.availableQuantity > 0 && farmerId != null) ? () {
                  Navigator.pushNamed(
                    context,
                    '/payment',
                    arguments: {
                      'productName': widget.productName,
                      'productPrice': widget.productPrice,
                      'productImage': widget.productImage,
                      'quantity': quantity,
                      'availableQuantity': widget.availableQuantity,
                      'unit': widget.unit,
                      'farmerId': farmerId
                    },
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(
                    fontSize: 18,
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