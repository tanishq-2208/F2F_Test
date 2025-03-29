class Farmer {
  final String id;
  final String name;
  final String profileImageUrl;
  final double rating;
  final int reviewCount;
  final double distance;
  final int deliveryTime;
  final double price;
  final String unit;
  final double quantity;
  final String? offerText;

  Farmer({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.deliveryTime,
    required this.price,
    required this.unit,
    required this.quantity,
    this.offerText,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      distance: json['distance'].toDouble(),
      deliveryTime: json['deliveryTime'],
      price: json['price'].toDouble(),
      unit: json['unit'],
      quantity: json['quantity'].toDouble(),
      offerText: json['offerText'],
    );
  }
}