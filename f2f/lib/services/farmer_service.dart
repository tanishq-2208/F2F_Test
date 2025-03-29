import '../models/farmer.dart';
import '../models/rating.dart';

class FarmerService {
  // Mock implementation - replace with actual API calls
  static Future<List<Farmer>> getFarmersByProduct(String productName, String category) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data
    return [
      Farmer(
        id: 'farmer1',
        name: 'Ramesh Kumar',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        rating: 4.8,
        reviewCount: 124,
        distance: 3.2,
        deliveryTime: 30,
        price: 120.0,
        unit: 'kg',
        quantity: 50.0,
        offerText: '10% off on orders above ₹500',
      ),
      Farmer(
        id: 'farmer2',
        name: 'Suresh Reddy',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
        rating: 4.5,
        reviewCount: 86,
        distance: 5.7,
        deliveryTime: 45,
        price: 110.0,
        unit: 'kg',
        quantity: 30.0,
      ),
      Farmer(
        id: 'farmer3',
        name: 'Lakshmi Devi',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/32.jpg',
        rating: 4.2,
        reviewCount: 52,
        distance: 7.1,
        deliveryTime: 60,
        price: 105.0,
        unit: 'kg',
        quantity: 25.0,
        offerText: 'Free delivery on orders above ₹300',
      ),
    ];
  }
  
  // Add a new method to submit ratings
  static Future<bool> submitRating(String farmerId, String orderId, Rating rating) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would send the rating to a backend service
    // and update the farmer's average rating
    
    print('Rating submitted for farmer $farmerId: ${rating.rating} stars');
    print('Comment: ${rating.comment}');
    
    // Return success (would be based on API response in a real app)
    return true;
  }
  
  // Get orders that can be rated (for demo purposes)
  static Future<List<Map<String, dynamic>>> getCompletedOrders() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock completed orders that can be rated
    return [
      {
        'orderId': 'order123',
        'farmerId': 'farmer1',
        'farmerName': 'Ramesh Kumar',
        'productName': 'Apple',
        'orderDate': DateTime.now().subtract(const Duration(days: 2)),
        'isRated': false,
      },
      {
        'orderId': 'order124',
        'farmerId': 'farmer2',
        'farmerName': 'Suresh Reddy',
        'productName': 'Tomato',
        'orderDate': DateTime.now().subtract(const Duration(days: 5)),
        'isRated': false,
      },
    ];
  }
}