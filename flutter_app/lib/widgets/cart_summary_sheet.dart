import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pre_order_provider.dart';
import '../config/theme.dart';
import '../utils/helpers.dart';
import 'quantity_stepper.dart';
import 'token_receipt_screen.dart';

class CartSummarySheet extends StatefulWidget {
  const CartSummarySheet({super.key});

  @override
  State<CartSummarySheet> createState() => _CartSummarySheetState();
}

class _CartSummarySheetState extends State<CartSummarySheet> {
  String? _selectedPickupTime;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select first pickup time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PreOrderProvider>(context, listen: false);
      final times = provider.availablePickupTimes;
      if (times.isNotEmpty && mounted) {
        setState(() => _selectedPickupTime = times.first);
      }
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(BuildContext context, PreOrderProvider provider) async {
    if (provider.cartHasSoldOutItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Some items are now sold out: ${provider.cartSoldOutItems.map((i) => i.name).join(', ')}. Remove them to continue.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    try {
      final receipt = await provider.placeOrder(
        pickupTime: _selectedPickupTime,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close bottom sheet

      // Navigate to receipt screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TokenReceiptScreen(receipt: receipt)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreOrderProvider>(
      builder: (context, provider, _) {
        final cartEntries = provider.cart.entries.toList();
        final items       = provider.availableItems;
        final slot        = provider.currentSlot;
        final pickupTimes = provider.availablePickupTimes;
        final (tokenStart, tokenEnd) = provider.projectedTokenRange;
        final hasSoldOut  = provider.cartHasSoldOutItems;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          '🛒  Your Pre-Order',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (cartEntries.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${provider.cartTotalItems} portions',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGreen,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Divider(),

                  // Sold-out warning banner
                  if (hasSoldOut)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Some items are now sold out. Remove them to place your order.',
                              style: TextStyle(fontSize: 12, color: Colors.red[800]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Cart items list
                  Expanded(
                    child: cartEntries.isEmpty
                        ? const Center(
                            child: Text(
                              'Your cart is empty.\nAdd items to place a pre-order.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: cartEntries.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final entry = cartEntries[index];
                              final cartItem = items.firstWhere(
                                (i) => i.id == entry.key,
                                orElse: () => items.first,
                              );
                              final isSoldOut = !cartItem.isPreOrderable;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    // Name
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartItem.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: isSoldOut ? Colors.red[400] : Colors.black87,
                                            ),
                                          ),
                                          if (isSoldOut)
                                            const Text(
                                              'Now sold out',
                                              style: TextStyle(fontSize: 11, color: Colors.red),
                                            )
                                          else
                                            Text(
                                              '₹${(cartItem.price * entry.value).toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.primaryGreen,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Stepper
                                    QuantityStepper(
                                      value: entry.value,
                                      enabled: !isSoldOut,
                                      onChanged: (qty) {
                                        if (qty == 0) {
                                          provider.removeFromCart(entry.key);
                                        } else {
                                          provider.updateQuantity(entry.key, qty);
                                        }
                                      },
                                    ),

                                    // Remove
                                    IconButton(
                                      onPressed: () => provider.removeFromCart(entry.key),
                                      icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom section: token range + pickup + notes + button
                  if (cartEntries.isNotEmpty) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Token range projection
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your token range',
                                      style: TextStyle(fontSize: 11, color: AppTheme.darkGreen),
                                    ),
                                    Text(
                                      '#$tokenStart – #$tokenEnd',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Est. wait',
                                      style: TextStyle(fontSize: 11, color: AppTheme.darkGreen),
                                    ),
                                    Text(
                                      '~${provider.estimatedWaitMinutes} min',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Pickup time picker
                          if (pickupTimes.isNotEmpty) ...[
                            const Text(
                              'Pickup Time',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedPickupTime,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                              items: pickupTimes
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedPickupTime = v),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Notes field
                          TextField(
                            controller: _notesCtrl,
                            maxLength: 200,
                            decoration: InputDecoration(
                              hintText: 'Special instructions (optional)',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Total + place order
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ₹${provider.cartTotalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: (hasSoldOut || provider.isPlacingOrder)
                                ? null
                                : () => _placeOrder(context, provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: provider.isPlacingOrder
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    '🌿  Place Pre-Order',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
