import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 16,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(Icons.star, size: size, color: color);
        } else if (index == rating.floor() && rating % 1 > 0) {
          // Half star
          return Icon(Icons.star_half, size: size, color: color);
        } else {
          // Empty star
          return Icon(Icons.star_border, size: size, color: color);
        }
      }),
    );
  }
}