import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pre_order_provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import '../widgets/now_serving_banner.dart';
import '../widgets/pre_order_item_card.dart';
import '../widgets/cart_summary_sheet.dart';
import '../screens/profile_completion_screen.dart';

class PreOrderScreen extends StatefulWidget {
  const PreOrderScreen({super.key});

  @override
  State<PreOrderScreen> createState() => _PreOrderScreenState();
}

class _PreOrderScreenState extends State<PreOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileAndLoad();
    });
  }

  Future<void> _checkProfileAndLoad() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Block pre-order if profile fields missing
    if (user != null) {
      final hasDept    = (user.department?.isNotEmpty ?? false);
      final hasYear    = (user.year?.isNotEmpty ?? false);
      final hasSection = (user.section?.isNotEmpty ?? false);

      if (!hasDept || !hasYear || !hasSection) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => ProfileCompletionScreen(
              onCompleted: () => _loadItems(),
            ),
          ),
        );
        return;
      }
    }

    _loadItems();
  }

  void _loadItems() {
    Provider.of<PreOrderProvider>(context, listen: false).fetchAvailableItems();
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartSummarySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🌿  Pre-Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGreen,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Consumer<PreOrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _buildShimmer();
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAvailableItems(),
            color: AppTheme.primaryGreen,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Now Serving banner
                const SliverToBoxAdapter(child: NowServingBanner()),

                // Slot info card
                SliverToBoxAdapter(child: _buildSlotInfoCard(provider)),

                // Error state
                if (provider.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          provider.error!,
                          style: TextStyle(color: Colors.red[700], fontSize: 13),
                        ),
                      ),
                    ),
                  ),

                // Items list
                if (provider.availableItems.isEmpty && provider.error == null)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.no_food, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No pre-order items available right now.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = provider.availableItems[index];
                          return PreOrderItemCard(item: item);
                        },
                        childCount: provider.availableItems.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      // Floating cart button
      floatingActionButton: Consumer<PreOrderProvider>(
        builder: (context, provider, _) {
          final count = provider.cartTotalItems;
          if (count == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _openCart,
            backgroundColor: AppTheme.primaryGreen,
            label: Text(
              'View Cart • $count items',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildSlotInfoCard(PreOrderProvider provider) {
    final slot = provider.currentSlot;
    if (slot == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: const Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No active meal slot right now.\nPre-ordering opens during meal times.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    final (tStart, tEnd) = provider.projectedTokenRange;
    final cartQty = provider.cartTotalItems;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.slotName[0].toUpperCase()}${slot.slotName.substring(1)}  '
                  '${slot.startTime.substring(0, 5)}–${slot.endTime.substring(0, 5)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.darkGreen,
                  ),
                ),
                Text(
                  'Current Token: #${slot.currentTokenNumber}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),
          if (cartQty > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Your range: #$tStart–#$tEnd',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
