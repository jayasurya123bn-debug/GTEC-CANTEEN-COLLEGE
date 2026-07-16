import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../config/theme.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  static const List<Map<String, String>> _staticCategories = [
    {'emoji': '⭐', 'label': 'All'},
    {'emoji': '🌅', 'label': 'Breakfast'},
    {'emoji': '🍱', 'label': 'Lunch'},
    {'emoji': '🍿', 'label': 'Snacks'},
    {'emoji': '🌙', 'label': 'Dinner'},
    {'emoji': '🥤', 'label': 'Beverages'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        final dynamicCats = menuProvider.categories;
        final String? selected = menuProvider.selectedCategory;

        // Build chip list: static emoji chips for known categories,
        // then any unknown categories from the API
        final List<Map<String, String>> chips = List.from(_staticCategories);
        for (final cat in dynamicCats) {
          final exists = _staticCategories.any(
            (c) => c['label']?.toLowerCase() == cat.toLowerCase(),
          );
          if (!exists) {
            chips.add({'emoji': '🍽️', 'label': cat});
          }
        }

        return SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final chip = chips[index];
              final label = chip['label'] ?? '';
              final emoji = chip['emoji'] ?? '';
              final isAll = label == 'All';
              final isSelected = isAll
                  ? (selected == null || selected == 'All')
                  : selected == label;

              return GestureDetector(
                onTap: () {
                  menuProvider.filterByCategory(isAll ? null : label);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen.withOpacity(0.15)
                            : AppTheme.card.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryGreen : AppTheme.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '$emoji $label',
                        style: GoogleFonts.poppins(
                          color: isSelected ? AppTheme.primaryGreen : AppTheme.bodyText,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
