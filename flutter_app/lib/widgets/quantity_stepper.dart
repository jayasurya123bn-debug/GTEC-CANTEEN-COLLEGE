import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Reusable [-] [quantity] [+] stepper widget.
/// 
/// [value] — current quantity (must be >= [min]).
/// [onChanged] — called with new value; caller must clamp to min/max if needed.
/// [min] — minimum allowed value (default 1).
/// [max] — maximum allowed value (default 20).
/// [enabled] — if false, both buttons are greyed out.
class QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool enabled;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = enabled && value > min;
    final canIncrement = enabled && value < max;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: enabled ? AppTheme.primaryGreen : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          _StepperButton(
            icon: Icons.remove,
            enabled: canDecrement,
            onTap: () => onChanged((value - 1).clamp(min, max)),
          ),

          // Quantity display
          Container(
            width: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: enabled ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ),

          // Plus button
          _StepperButton(
            icon: Icons.add,
            enabled: canIncrement,
            onTap: () => onChanged((value + 1).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppTheme.primaryGreen : Colors.grey[300],
        ),
      ),
    );
  }
}
