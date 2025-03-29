import 'package:flutter/material.dart';
import '../models/farmer.dart';
import '../services/farmer_service.dart';
import '../widgets/rating_stars.dart';
import 'checkout_screen.dart';

class FarmerSelectionScreen extends StatefulWidget {
  final String productName;
  final String productCategory;

  const FarmerSelectionScreen({
    Key? key,
    required this.productName,
    required this.productCategory,
  }) : super(key: key);

  @override
  State<FarmerSelectionScreen> createState() => _FarmerSelectionScreenState();
}

class _FarmerSelectionScreenState extends State<FarmerSelectionScreen> {
  List<Farmer> _farmers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch farmers selling this product
      final farmers = await FarmerService.getFarmersByProduct(
        widget.productName,
        widget.productCategory,
      );
      
      // Sort by rating (highest first)
      farmers.sort((a, b) => b.rating.compareTo(a.rating));
      
      setState(() {
        _farmers = farmers;
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
        title: Text('Select Farmer for ${widget.productName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _farmers.isEmpty
              ? _buildEmptyState()
              : _buildFarmersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No farmers available for ${widget.productName}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmers.length,
      itemBuilder: (context, index) {
        final farmer = _farmers[index];
        final isTopRated = index == 0;
        
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isTopRated
                ? BorderSide(color: Colors.green[700]!, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutScreen(
                    productName: widget.productName,
                    farmer: farmer,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(farmer.profileImageUrl),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  farmer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                if (isTopRated) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          size: 14,
                                          color: Colors.green[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Top Rated',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingStars(rating: farmer.rating),
                                const SizedBox(width: 8),
                                Text(
                                  '(${farmer.reviewCount})',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.location_on,
                        '${farmer.distance.toStringAsFixed(1)} km',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.access_time,
                        '${farmer.deliveryTime} min',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.monetization_on,
                        '₹${farmer.price}/${farmer.unit}',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available: ${farmer.quantity} ${farmer.unit}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  if (farmer.offerText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 16,
                            color: Colors.orange[800],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              farmer.offerText!,
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              productName: widget.productName,
                              farmer: farmer,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green[700],
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlighted ? Colors.green[700] : Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.green[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}