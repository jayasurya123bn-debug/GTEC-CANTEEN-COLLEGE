import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/token_receipt_model.dart';
import '../config/theme.dart';

/// Full-screen receipt screen shown after a successful pre-order.
/// Can be used as both a route destination and pushed directly.
class TokenReceiptScreen extends StatelessWidget {
  final TokenReceiptModel receipt;

  const TokenReceiptScreen({super.key, required this.receipt});

  // Department badge color map
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(receipt.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text(
          '🌿  Pre-Order Token',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () => _shareReceipt(context),
            tooltip: 'Share Token',
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Token number card ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Token Number',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#${receipt.tokenNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Portions: ${receipt.tokenRangeLabel}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Text(
                      receipt.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Estimated wait ──────────────────────────────────────────────
            if (receipt.estimatedWaitMinutes > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Estimated wait: ~${receipt.estimatedWaitMinutes} minutes',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // ─── Receipt card ────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Student info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receipt.studentName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _DeptBadge(dept: receipt.department, color: _deptColor(receipt.department)),
                            const SizedBox(width: 8),
                            _InfoChip(receipt.year),
                            const SizedBox(width: 8),
                            _InfoChip('Sec ${receipt.section}'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _dashedDivider(),

                  // Slot + pickup info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Column(
                      children: [
                        _receiptRow('Meal Slot', receipt.slotDisplayLabel),
                        if (receipt.pickupTime != null)
                          _receiptRow('Pickup Time', receipt.pickupTime!),
                        _receiptRow('Order Date',
                          '${receipt.orderDate.day}/${receipt.orderDate.month}/${receipt.orderDate.year}'),
                      ],
                    ),
                  ),

                  _dashedDivider(),

                  // Items list
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Column(
                      children: [
                        for (final item in receipt.items) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}×  ${item.name}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                              Text(
                                '₹${item.subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),

                  _dashedDivider(),

                  // Total
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${receipt.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.black,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notes (if any)
                  if (receipt.notes != null && receipt.notes!.isNotEmpty) ...[
                    _dashedDivider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              receipt.notes!,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Done button ─────────────────────────────────────────────────
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _dashedDivider() {
    return Row(
      children: List.generate(
        40,
        (i) => Expanded(
          child: Container(
            color: i.isEven ? Colors.grey[200] : Colors.transparent,
            height: 1,
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':   return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.amber;
      case 'ready':     return AppTheme.primaryGreen;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  void _shareReceipt(BuildContext context) {
    Clipboard.setData(ClipboardData(text: receipt.shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token details copied to clipboard!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}

// ─── Helper sub-widgets ─────────────────────────────────────────────────────
class _DeptBadge extends StatelessWidget {
  final String dept;
  final Color color;
  const _DeptBadge({required this.dept, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        dept,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }
}
