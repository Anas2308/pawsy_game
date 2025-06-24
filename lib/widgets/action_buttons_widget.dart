import 'package:flutter/material.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onToggleMultiSelect;
  final VoidCallback? onMultiSwap;
  final bool isMultiSelectMode;
  final int selectedCount;

  const ActionButtonsWidget({
    super.key,
    required this.onDiscard,
    required this.onToggleMultiSelect,
    this.onMultiSwap,
    required this.isMultiSelectMode,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onToggleMultiSelect,
              icon: Icon(
                isMultiSelectMode ? Icons.close : Icons.select_all,
                size: 16,
              ),
              label: Text(isMultiSelectMode ? 'Abbrechen' : 'Multi-Select'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isMultiSelectMode ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (isMultiSelectMode && selectedCount > 1) ...[
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onMultiSwap,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: Text('Duett/Triplett ($selectedCount)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}