import 'package:flutter/material.dart';
import '../config/theme.dart';

const List<String> _years = [
  '1st Year', '2nd Year', '3rd Year', '4th Year',
];

/// Dropdown selector for academic year.
class YearSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool showAsterisk;

  const YearSelector({
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
            text: 'Year',
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
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
            ),
            hintText: 'Select Year',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          items: _years
              .map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Year is required' : null,
        ),
      ],
    );
  }
}
