import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import '../config/theme.dart';
import '../utils/helpers.dart';
import '../providers/favourite_provider.dart';
import '../providers/pre_order_provider.dart';
import 'veg_badge.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onTap;

  const MenuItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: 100,
              height: 100,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        VegBadge(dietaryTag: item.dietaryTag),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          item.avgRating > 0 ? item.avgRating.toStringAsFixed(1) : 'New',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${item.ratingCount} Reviews)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Helpers.formatPrice(item.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        _buildAvailabilityBadge(),
                      ],
                    ),
                    // Pre-Order shortcut button — shown when a meal slot is active
                    Consumer<PreOrderProvider>(
                      builder: (context, preOrderProvider, _) {
                        final slotActive = preOrderProvider.currentSlot != null;
                        if (!slotActive) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/pre-order'),
                            icon: const Icon(Icons.shopping_bag_outlined, size: 13),
                            label: const Text('Pre-Order', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(color: AppTheme.primaryGreen),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (item.availability) {
      case 'available':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'Available';
        break;
      case 'limited':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'Limited';
        break;
      case 'sold_out':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        text = 'Sold Out';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
