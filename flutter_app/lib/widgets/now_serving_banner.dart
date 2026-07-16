import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteen_status_provider.dart';
import '../config/theme.dart';

class NowServingBanner extends StatelessWidget {
  const NowServingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CanteenStatusProvider>(
      builder: (context, provider, _) {
        final msg = provider.broadcast;
        if (msg == null || msg.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.elevated,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: const BorderSide(color: AppTheme.primaryGreen, width: 4),
              top:    BorderSide(color: AppTheme.border, width: 1),
              right:  BorderSide(color: AppTheme.border, width: 1),
              bottom: BorderSide(color: AppTheme.border, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.campaign_rounded, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
