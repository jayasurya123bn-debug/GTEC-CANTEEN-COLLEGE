import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import '../config/theme.dart';
import '../utils/helpers.dart';
import '../providers/favourite_provider.dart';
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
