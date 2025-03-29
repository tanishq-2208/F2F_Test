class Rating {
  final String farmerId;
  final String orderId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Rating({
    required this.farmerId,
    required this.orderId,
    required this.rating,
    this.comment = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'farmerId': farmerId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}