import 'package:flutter/material.dart';
import '../config/theme.dart';

const List<String> _sections = ['A', 'B', 'C', 'D'];

/// Chip-group selector for section (A/B/C/D).
class SectionSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool showAsterisk;

  const SectionSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.showAsterisk = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Section',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: showAsterisk
                ? const [TextSpan(text: ' *', style: TextStyle(color: AppTheme.primaryGreen))]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: _sections.map((section) {
            final selected = value == section;
            return GestureDetector(
              onTap: () => onChanged(section),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.primaryGreen : Colors.grey[300]!,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  section,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
