import 'package:flutter/material.dart';
import '../config/theme.dart';

class VegBadge extends StatelessWidget {
  final String dietaryTag; // 'veg' or 'vegan'

  const VegBadge({super.key, required this.dietaryTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: dietaryTag == 'vegan' ? BoxShape.circle : BoxShape.rectangle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            dietaryTag == 'vegan' ? 'Vegan' : 'Veg',
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
