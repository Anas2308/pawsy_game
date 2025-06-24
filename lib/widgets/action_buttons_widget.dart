import 'package:flutter/material.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback? onSwap;
  final int selectedCount;

  const ActionButtonsWidget({
    super.key,
    required this.onDiscard,
    this.onSwap,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: onDiscard,
          icon: const Icon(Icons.delete, size: 16),
          label: const Text('Ablegen'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        if (selectedCount >= 1) ...[
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onSwap,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: Text('Tausch ($selectedCount)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}