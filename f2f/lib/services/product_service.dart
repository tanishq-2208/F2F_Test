import '../models/product.dart';

class ProductService {
  // This is a mock implementation - replace with actual API calls
  static Future<List<Product>> getProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data
    return [
      Product(
        id: '1',
        name: 'Apple',
        category: 'Fruits',
        price: 120.0,
        unit: 'kg',
        quantity: 50.0,
        imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6',
        farmerId: 'farmer1',
      ),
      Product(
        id: '2',
        name: 'Banana',
        category: 'Fruits',
        price: 60.0,
        unit: 'dozen',
        quantity: 30.0,
        imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e',
        farmerId: 'farmer2',
      ),
      Product(
        id: '3',
        name: 'Tomato',
        category: 'Vegetables',
        price: 40.0,
        unit: 'kg',
        quantity: 100.0,
        imageUrl: 'https://images.unsplash.com/photo-1561136594-7f68413baa99',
        farmerId: 'farmer1',
      ),
      Product(
        id: '4',
        name: 'Potato',
        category: 'Vegetables',
        price: 30.0,
        unit: 'kg',
        quantity: 200.0,
        imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655',
        farmerId: 'farmer3',
      ),
    ];
  }
}