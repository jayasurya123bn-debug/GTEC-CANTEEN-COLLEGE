import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteen_status_provider.dart';
import '../config/theme.dart';

class CanteenStatusBar extends StatefulWidget {
  const CanteenStatusBar({super.key});

  @override
  State<CanteenStatusBar> createState() => _CanteenStatusBarState();
}

class _CanteenStatusBarState extends State<CanteenStatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _busynessLabel(String busyness) {
    switch (busyness.toLowerCase()) {
      case 'high':   return '🔴 Traffic: High';
      case 'moderate': return '🟡 Traffic: Moderate';
      default:       return '🟢 Traffic: Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CanteenStatusProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) => Opacity(
                  opacity: provider.isOpen ? _pulseAnim.value : 1.0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isOpen ? AppTheme.primaryGreen : AppTheme.soldOut,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                provider.isOpen ? 'Open Now' : 'Closed',
                style: TextStyle(
                  color: provider.isOpen ? AppTheme.primaryGreen : AppTheme.soldOut,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                _busynessLabel(provider.busyness),
                style: const TextStyle(color: AppTheme.bodyText, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
