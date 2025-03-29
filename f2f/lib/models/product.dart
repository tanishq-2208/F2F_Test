class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final double quantity;
  final String imageUrl;
  final String farmerId;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.imageUrl,
    required this.farmerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      unit: json['unit'],
      quantity: json['quantity'].toDouble(),
      imageUrl: json['imageUrl'],
      farmerId: json['farmerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'farmerId': farmerId,
    };
  }
}