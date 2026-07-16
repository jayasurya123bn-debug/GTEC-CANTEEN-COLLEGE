import 'package:flutter/material.dart';
import '../config/theme.dart';

class AvailabilityBadge extends StatelessWidget {
  final String availability;
  final bool large;

  const AvailabilityBadge({
    super.key,
    required this.availability,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    String label;
    IconData icon;

    switch (availability) {
      case 'limited':
        textColor = AppTheme.limited;
        bgColor   = AppTheme.limited.withOpacity(0.12);
        label     = 'Limited';
        icon      = Icons.timer_outlined;
        break;
      case 'sold_out':
        textColor = AppTheme.soldOut;
        bgColor   = AppTheme.soldOut.withOpacity(0.12);
        label     = 'Sold Out';
        icon      = Icons.remove_circle_outline;
        break;
      default:
        textColor = AppTheme.primaryGreen;
        bgColor   = AppTheme.primaryGreen.withOpacity(0.10);
        label     = 'Available';
        icon      = Icons.check_circle_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical:  large ? 6  : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: large ? 14 : 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: large ? 13 : 10,
            ),
          ),
        ],
      ),
    );
  }
}
