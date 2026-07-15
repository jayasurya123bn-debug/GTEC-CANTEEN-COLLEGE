import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pre_order_provider.dart';
import '../services/pre_order_service.dart';
import '../models/token_receipt_model.dart';
import '../config/theme.dart';
import '../widgets/token_receipt_screen.dart';

class MyTokensScreen extends StatefulWidget {
  const MyTokensScreen({super.key});

  @override
  State<MyTokensScreen> createState() => _MyTokensScreenState();
}

class _MyTokensScreenState extends State<MyTokensScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _tokens = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadTokens();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTokens() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await PreOrderService.getMyTokens();
      setState(() { _tokens = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> _filterByTab(int tab) {
    return _tokens.where((t) {
      final status = t['status'] as String;
      if (tab == 0) return ['pending', 'confirmed', 'preparing', 'ready'].contains(status);
      if (tab == 1) return status == 'completed';
      if (tab == 2) return status == 'cancelled';
      return false;
    }).toList();
  }

  Future<void> _cancelToken(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Pre-Order?'),
        content: const Text(
          'This will cancel your pre-order and restore the item capacity. '
          'Your token number will NOT be reused.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await PreOrderService.cancelPreOrder(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pre-order cancelled.'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      _loadTokens();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🌿  My Tokens',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGreen,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadTokens, child: const Text('Retry')),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildTokenList(0),
                    _buildTokenList(1),
                    _buildTokenList(2),
                  ],
                ),
    );
  }

  Widget _buildTokenList(int tab) {
    final filtered = _filterByTab(tab);
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              tab == 0 ? 'No active pre-orders'
              : tab == 1 ? 'No completed orders yet'
              : 'No cancelled orders',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTokens,
      color: AppTheme.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final token = filtered[index];
          return _TokenCard(
            token: token,
            onCancel: () => _cancelToken(token['id'] as String),
            onTap: () async {
              final receipt = await PreOrderService.getTokenReceipt(token['id'] as String);
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TokenReceiptScreen(receipt: receipt)),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Token card ─────────────────────────────────────────────────────────────
class _TokenCard extends StatelessWidget {
  final Map<String, dynamic> token;
  final VoidCallback onCancel;
  final VoidCallback onTap;

  const _TokenCard({required this.token, required this.onCancel, required this.onTap});

  static const Map<String, Color> _deptColors = {
    'CSE':   Color(0xFF1565C0),
    'ECE':   Color(0xFF6A1B9A),
    'EEE':   Color(0xFFF57F17),
    'MECH':  Color(0xFFE65100),
    'CIVIL': Color(0xFF4E342E),
    'IT':    Color(0xFF00695C),
    'AI&DS': Color(0xFFAD1457),
    'BME':   Color(0xFFC62828),
    'CHEM':  Color(0xFF00838F),
  };

  Color _deptColor(String dept) => _deptColors[dept] ?? Colors.blueGrey[700]!;

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':   return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.amber[700]!;
      case 'ready':     return AppTheme.primaryGreen;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status      = token['status'] as String;
    final tokenNumber = token['token_number'] as int;
    final tokenStart  = token['token_start'] as int;
    final tokenEnd    = token['token_end'] as int;
    final dept        = token['department'] as String? ?? '—';
    final year        = token['year'] as String? ?? '—';
    final section     = token['section'] as String? ?? '—';
    final slotName    = (token['meal_slot'] as Map?)?.cast<String,dynamic>()['name']
                        ?? token['time_slot'] as String? ?? '—';
    final totalAmount = (token['total_amount'] as num?)?.toDouble() ?? 0.0;
    final isPending   = status == 'pending';
    final isReady     = status == 'ready';

    // Build items summary
    final rawItems = token['items'];
    String itemsSummary = '—';
    if (rawItems is List) {
      itemsSummary = rawItems.take(3).map((i) {
        final name = i['name'] ?? '';
        final qty  = i['quantity'] ?? 1;
        return '${qty}× $name';
      }).join(', ');
      if (rawItems.length > 3) itemsSummary += '…';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReady ? AppTheme.primaryGreen : Colors.grey.shade200,
            width: isReady ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // Top row: token number + status
            Container(
              decoration: BoxDecoration(
                color: isReady ? AppTheme.lightGreen : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Large token number
                  Text(
                    '#$tokenNumber',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isReady ? AppTheme.primaryGreen : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Range: #$tokenStart–#$tokenEnd',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          slotName[0].toUpperCase() + slotName.substring(1),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(status, isReady),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dept / year / section chips
                  Row(
                    children: [
                      _DeptBadge(dept: dept, color: _deptColor(dept)),
                      const SizedBox(width: 6),
                      _InfoChip(year),
                      const SizedBox(width: 6),
                      _InfoChip('Sec $section'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Items summary
                  Text(
                    itemsSummary,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Total + cancel button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      if (isPending)
                        OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isReady) {
    final color = _statusColor(status);
    if (isReady) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '✅ Ready!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}

class _DeptBadge extends StatelessWidget {
  final String dept;
  final Color color;
  const _DeptBadge({required this.dept, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(dept, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
  );
}
