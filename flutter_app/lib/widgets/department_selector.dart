import 'package:flutter/material.dart';
import '../config/theme.dart';

const List<String> _departments = [
  'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT', 'AI&DS', 'BME', 'CHEM',
];

/// Dropdown selector for college department.
class DepartmentSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool showAsterisk;

  const DepartmentSelector({
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
            text: 'Department',
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
            hintText: 'Select Department',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          items: _departments
              .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Department is required' : null,
        ),
      ],
    );
  }
}
