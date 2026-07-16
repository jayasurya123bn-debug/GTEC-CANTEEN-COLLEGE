import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import '../providers/favourite_provider.dart';
import '../config/theme.dart';
import '../utils/routes.dart';
import 'veg_badge.dart';
import 'availability_badge.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItemModel item;
  final int animationIndex;

  const MenuItemCard({
    super.key,
    required this.item,
    this.animationIndex = 0,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _opacity;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger: each card starts 40ms later
    Future.delayed(
      Duration(milliseconds: widget.animationIndex * 40),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.itemDetails,
              arguments: widget.item,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image Stack ─────────────────────────────────────────────
                SizedBox(
                  height: 180,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Food image
                      CachedNetworkImage(
                        imageUrl: widget.item.imageUrl ??
                            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop',
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppTheme.elevated,
                          child: const Center(
                            child: Text('🍽️', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.elevated,
                          child: const Center(
                            child: Text('🍽️', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                      ),
                      // Bottom-fade gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xFF0D1117)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Veg badge (top-left)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: VegBadge(dietaryTag: widget.item.dietaryTag),
                      ),
                      // Favourite heart button (top-right)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<FavouriteProvider>(
                          builder: (context, favProvider, _) {
                            final isFav = favProvider.isFavourite(widget.item.id);
                            return GestureDetector(
                              onTap: () => favProvider.toggleFavourite(widget.item.id),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : AppTheme.white,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Name + Price + Rating (bottom of image)
                      Positioned(
                        bottom: 8,
                        left: 10,
                        right: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.item.name,
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${widget.item.price.toStringAsFixed(widget.item.price % 1 == 0 ? 0 : 2)}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: AppTheme.amber, size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.item.avgRating > 0
                                          ? widget.item.avgRating.toStringAsFixed(1)
                                          : 'New',
                                      style: const TextStyle(
                                        color: AppTheme.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Bottom row: Availability + Dietary tag ───────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AvailabilityBadge(availability: widget.item.availability),
                      Text(
                        widget.item.dietaryTag[0].toUpperCase() +
                            widget.item.dietaryTag.substring(1),
                        style: const TextStyle(
                          color: AppTheme.bodyText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
