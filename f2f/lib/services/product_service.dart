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
        imageUrl: 'assets/images/apple.png',
        farmerId: 'farmer1',
      ),
      Product(
        id: '2',
        name: 'Banana',
        category: 'Fruits',
        price: 60.0,
        unit: 'dozen',
        quantity: 30.0,
        imageUrl: 'assets/images/banana.png',
        farmerId: 'farmer2',
      ),
      Product(
        id: '3',
        name: 'Tomato',
        category: 'Vegetables',
        price: 40.0,
        unit: 'kg',
        quantity: 100.0,
        imageUrl: 'assets/images/tomato.png',
        farmerId: 'farmer1',
      ),
      Product(
        id: '4',
        name: 'Potato',
        category: 'Vegetables',
        price: 30.0,
        unit: 'kg',
        quantity: 200.0,
        imageUrl: 'assets/images/potato.png',
        farmerId: 'farmer3',
      ),
      // Added new fruits
      Product(
        id: '5',
        name: 'Orange',
        category: 'Fruits',
        price: 80.0,
        unit: 'kg',
        quantity: 75.0,
        imageUrl: 'assets/images/orange.png',
        farmerId: 'farmer2',
      ),
      Product(
        id: '6',
        name: 'Grapes',
        category: 'Fruits',
        price: 120.0,
        unit: 'kg',
        quantity: 40.0,
        imageUrl: 'assets/images/grapes.png',
        farmerId: 'farmer1',
      ),
      Product(
        id: '7',
        name: 'Watermelon',
        category: 'Fruits',
        price: 50.0,
        unit: 'kg',
        quantity: 25.0,
        imageUrl: 'assets/images/watermelon.png',
        farmerId: 'farmer3',
      ),
      // Added new vegetables
      Product(
        id: '8',
        name: 'Cucumber',
        category: 'Vegetables',
        price: 40.0,
        unit: 'kg',
        quantity: 90.0,
        imageUrl: 'assets/images/cucumber.png',
        farmerId: 'farmer2',
      ),
      Product(
        id: '9',
        name: 'Carrot',
        category: 'Vegetables',
        price: 35.0,
        unit: 'kg',
        quantity: 120.0,
        imageUrl: 'assets/images/carrot.png',
        farmerId: 'farmer1',
      ),
    ];
  }
}
