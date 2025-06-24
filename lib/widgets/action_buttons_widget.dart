import 'package:flutter/material.dart';
import '../logic/action_card_controller.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback? onSwap;
  final VoidCallback? onUseActionCard;
  final int selectedCount;
  final bool hasActionCardAvailable;
  final ActionCardType actionCardType;

  const ActionButtonsWidget({
    super.key,
    required this.onDiscard,
    this.onSwap,
    this.onUseActionCard,
    required this.selectedCount,
    this.hasActionCardAvailable = false,
    this.actionCardType = ActionCardType.none,
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
            if (selectedCount >= 1) ...[
              const SizedBox(width: 8),
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
        ),
        if (hasActionCardAvailable) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActionCardColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getActionCardColor(), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getActionIcon(),
                      color: _getActionCardColor(),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Aktionskarte verfügbar!',
                      style: TextStyle(
                        color: _getActionCardColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: onUseActionCard,
                  icon: Icon(_getActionIcon(), size: 16),
                  label: Text(_getActionButtonText()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getActionCardColor(),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getActionCardColor() {
    switch (actionCardType) {
      case ActionCardType.look:
        return Colors.orange;
      case ActionCardType.spy:
        return Colors.red;
      case ActionCardType.trade:
        return Colors.purple;
      case ActionCardType.none:
        return Colors.grey;
    }
  }

  IconData _getActionIcon() {
    switch (actionCardType) {
      case ActionCardType.look:
        return Icons.visibility;
      case ActionCardType.spy:
        return Icons.search;
      case ActionCardType.trade:
        return Icons.swap_horiz;
      case ActionCardType.none:
        return Icons.help;
    }
  }

  String _getActionButtonText() {
    switch (actionCardType) {
      case ActionCardType.look:
        return 'LOOK verwenden';
      case ActionCardType.spy:
        return 'SPY verwenden';
      case ActionCardType.trade:
        return 'TRADE verwenden';
      case ActionCardType.none:
        return 'Aktion';
    }
  }
}