import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';
import '../config/theme.dart';

class GtecBanner extends StatefulWidget {
  const GtecBanner({super.key});

  @override
  State<GtecBanner> createState() => _GtecBannerState();
}

class _GtecBannerState extends State<GtecBanner> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  // Official GTEC campus/department images
  static const List<String> _bannerImages = [
    'http://www.gtec.ac.in/images/dept/1.jpg',
    'http://www.gtec.ac.in/images/dept/2.jpg',
    'http://www.gtec.ac.in/images/dept/3.jpg',
  ];

  // Fallback images if official site is unreachable
  static const List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1562774053-701939374585?w=1200&h=400&fit=crop',
    'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=1200&h=400&fit=crop',
    'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=1200&h=400&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll every 3 seconds
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    final next = (_currentPage + 1) % _bannerImages.length;
    _pageCtrl.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchGallery() async {
    final Uri url = Uri.parse('http://www.gtec.ac.in/gallery.php');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ─── Sliding image carousel ────────────────────────────────────
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _bannerImages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _launchGallery,
                  child: CachedNetworkImage(
                    imageUrl: _bannerImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      // Fallback to Unsplash on HTTP error
                      return CachedNetworkImage(
                        imageUrl: _fallbackImages[index % _fallbackImages.length],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        placeholder: (_, __) => Container(color: Colors.grey[300]),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.primaryGreen.withOpacity(0.15),
                          child: const Center(
                            child: Icon(Icons.business, size: 48, color: AppTheme.primaryGreen),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // ─── Dark gradient overlay ─────────────────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Text overlay ──────────────────────────────────────────────
            Positioned(
              left: 16,
              right: 16,
              bottom: 36,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌿', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 4),
                        Text(
                          'Pure Veg Canteen',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppConstants.collegeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    AppConstants.address,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ─── Dot indicator ─────────────────────────────────────────────
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_bannerImages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
