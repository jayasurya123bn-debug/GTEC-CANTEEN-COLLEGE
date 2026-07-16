import 'package:flutter/material.dart';
import '../config/theme.dart';

class VegBadge extends StatelessWidget {
  final String dietaryTag; // 'veg' or 'vegan'

  const VegBadge({super.key, required this.dietaryTag});

  @override
  Widget build(BuildContext context) {
    final bool isVegan = dietaryTag.toLowerCase() == 'vegan';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4), width: 1),
      ),
      child: Text(
        isVegan ? '🌱 Vegan' : '🌿 Veg',
        style: const TextStyle(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
