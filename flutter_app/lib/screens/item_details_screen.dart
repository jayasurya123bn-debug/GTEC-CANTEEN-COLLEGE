import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/menu_item_model.dart';
import '../models/review_model.dart';
import '../providers/favourite_provider.dart';
import '../services/review_service.dart';
import '../widgets/veg_badge.dart';
import '../widgets/availability_badge.dart';
import '../widgets/review_card.dart';
import '../config/theme.dart';
import '../utils/helpers.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews     = true;
  double _newRating          = 5.0;
  final _reviewCtrl          = TextEditingController();
  bool _isSubmitting         = false;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews() async {
    try {
      final raw = await ReviewService.getReviewsForMenu(widget.item.id);
      setState(() {
        _reviews = raw.map((r) => ReviewModel.fromJson(Map<String, dynamic>.from(r))).toList();
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview() async {
    final comment = _reviewCtrl.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ReviewService.submitReview(widget.item.id, _newRating, comment);
      _reviewCtrl.clear();
      _fetchReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Review submitted!'),
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppTheme.soldOut,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 18),
          ),
        ),
        actions: [
          Consumer<FavouriteProvider>(
            builder: (context, favProvider, _) {
              final isFav = favProvider.isFavourite(item.id);
              return GestureDetector(
                onTap: () => favProvider.toggleFavourite(item.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.red : AppTheme.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReviews,
        color: AppTheme.primaryGreen,
        backgroundColor: AppTheme.card,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ──────────────────────────────────────────────────
            Stack(
              children: [
                Hero(
                  tag: 'menu_item_${item.id}',
                  child: SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl ??
                          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&fit=crop',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.elevated),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.elevated,
                        child: const Center(
                          child: Text('🍽️', style: TextStyle(fontSize: 60)),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppTheme.background],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Content Card ─────────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Veg Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        VegBadge(dietaryTag: item.dietaryTag),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price + Availability
                    Row(
                      children: [
                        Text(
                          Helpers.formatPrice(item.price),
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        AvailabilityBadge(availability: item.availability, large: true),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Dietary tag
                    Text(
                      item.dietaryTag[0].toUpperCase() + item.dietaryTag.substring(1),
                      style: const TextStyle(color: AppTheme.bodyText, fontSize: 13),
                    ),

                    const Divider(color: AppTheme.border, height: 32),

                    // Description
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      Text(
                        'About this dish',
                        style: GoogleFonts.poppins(
                          color: AppTheme.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: const TextStyle(
                          color: AppTheme.bodyText,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const Divider(color: AppTheme.border, height: 32),
                    ],

                    // Rating Summary
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.avgRating > 0
                              ? item.avgRating.toStringAsFixed(1)
                              : '—',
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < item.avgRating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppTheme.amber,
                                  size: 22,
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.ratingCount} reviews',
                              style: const TextStyle(
                                color: AppTheme.bodyText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(color: AppTheme.border, height: 32),

                    // Reviews heading
                    Text(
                      'Reviews',
                      style: GoogleFonts.poppins(
                        color: AppTheme.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Review list
                    if (_isLoadingReviews)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                          strokeWidth: 2,
                        ),
                      )
                    else if (_reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No reviews yet. Be the first! 🌿',
                          style: TextStyle(color: AppTheme.bodyText, fontSize: 14),
                        ),
                      )
                    else
                      ...List.generate(_reviews.length, (i) => ReviewCard(review: _reviews[i])),

                    const SizedBox(height: 8),

                    // Submit review section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Write a Review',
                            style: GoogleFonts.poppins(
                              color: AppTheme.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: RatingBar.builder(
                              initialRating: _newRating,
                              minRating: 1,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 32,
                              unratedColor: AppTheme.muted,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                              itemBuilder: (_, __) =>
                                  const Icon(Icons.star, color: AppTheme.amber),
                              onRatingUpdate: (r) => _newRating = r,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _reviewCtrl,
                                  style: const TextStyle(color: AppTheme.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Write a review...',
                                    filled: true,
                                    fillColor: AppTheme.inputFill,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppTheme.primaryGreen, width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _isSubmitting ? null : _submitReview,
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryGreen.withOpacity(0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _isSubmitting
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                            color: AppTheme.background,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          color: AppTheme.background,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
