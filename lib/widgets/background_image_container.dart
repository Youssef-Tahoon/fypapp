import 'package:flutter/material.dart';
import '../assets.dart'; // Assuming AppImagePath is here

class BackgroundImageContainer extends StatelessWidget {
  final Widget child;
  const BackgroundImageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImagePath.kRectangleBackgound), // Make sure kRectangleBackgound is valid
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Error loading background image: $exception');
            // You might want to show a solid color as fallback
          },
        ),
        // Fallback color in case image fails to load
        color: Colors.grey[200],
      ),
      child: child,
    );
  }
} 