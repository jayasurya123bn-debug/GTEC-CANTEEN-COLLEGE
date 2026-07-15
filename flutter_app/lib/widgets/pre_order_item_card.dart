import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/pre_order_item_model.dart';
import '../providers/pre_order_provider.dart';
import '../config/theme.dart';
import '../utils/helpers.dart';
import 'veg_badge.dart';
import 'quantity_stepper.dart';

class PreOrderItemCard extends StatelessWidget {
  final PreOrderItemModel item;

  const PreOrderItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreOrderProvider>(
      builder: (context, provider, _) {
        final qtyInCart    = provider.cart[item.id] ?? 0;
        final inCart       = qtyInCart > 0;
        final isSoldOut    = item.preOrderStatus == 'sold_out';
        final isLimited    = item.preOrderStatus == 'limited';
        final isAvailable  = item.preOrderStatus == 'available';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSoldOut ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: inCart && !isSoldOut
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade200,
              width: inCart && !isSoldOut ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ─── Card content ──────────────────────────────────────────────
              Opacity(
                opacity: isSoldOut ? 0.5 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl ??
                                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: Colors.grey[200]),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.restaurant, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + Veg badge row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isSoldOut ? Colors.grey[500] : Colors.black87,
                                    ),
                                  ),
                                ),
                                VegBadge(dietaryTag: item.dietaryTag),
                              ],
                            ),

                            if (item.description != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                item.description!,
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            const SizedBox(height: 8),

                            // Capacity bar
                            _buildCapacityBar(),

                            // Limited warning
                            if (isLimited && item.limitedWarning != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '⚠️  ${item.limitedWarning}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),

                            // Price + stepper / sold-out
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Helpers.formatPrice(item.price),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSoldOut
                                        ? Colors.grey[400]
                                        : AppTheme.primaryGreen,
                                  ),
                                ),
                                if (!isSoldOut)
                                  inCart
                                      ? QuantityStepper(
                                          value: qtyInCart,
                                          onChanged: (qty) =>
                                              provider.updateQuantity(item.id, qty),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            final added = provider.addToCart(item.id);
                                            if (!added) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('This item is sold out for pre-order'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryGreen,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 7,
                                            ),
                                            child: const Text(
                                              'Add',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Sold Out overlay ──────────────────────────────────────────
              if (isSoldOut)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🚫  Sold Out for Pre-Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Thin progress bar: green → amber → red.
  Widget _buildCapacityBar() {
    final pct = item.preOrderLimit > 0
        ? (item.bookedQuantity / item.preOrderLimit).clamp(0.0, 1.0)
        : 1.0;

    Color barColor;
    if (pct >= 1.0)  barColor = Colors.red[400]!;
    else if (pct >= 0.8) barColor = Colors.orange[400]!;
    else barColor = AppTheme.accentGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${item.remainingPreOrderCapacity} of ${item.preOrderLimit} portions left',
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
