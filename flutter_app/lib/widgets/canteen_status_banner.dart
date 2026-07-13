import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteen_status_provider.dart';

class CanteenStatusBanner extends StatelessWidget {
  const CanteenStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CanteenStatusProvider>(
      builder: (context, provider, child) {
        final status = provider.status;
        if (status == null) return const SizedBox.shrink();

        return Column(
          children: [
            // Open/Close status
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: status.isOpen ? Colors.green[50] : Colors.red[50],
              child: Row(
                children: [
                  Icon(
                    status.isOpen ? Icons.check_circle : Icons.cancel,
                    color: status.isOpen ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status.isOpen ? 'Canteen is Open' : 'Canteen is Closed',
                      style: TextStyle(
                        color: status.isOpen ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Traffic: ${status.busyness}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Broadcast message if any
            if (status.broadcastMessage != null && status.broadcastMessage!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.orange[50],
                child: Row(
                  children: [
                    const Icon(Icons.campaign, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status.broadcastMessage!,
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
