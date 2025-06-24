import 'package:flutter/material.dart';
import 'action_buttons_widget.dart';
import '../logic/action_card_controller.dart';

class DrawnCardWidget extends StatelessWidget {
  final String drawnCard;
  final VoidCallback onDiscard;
  final VoidCallback? onSwap;
  final VoidCallback? onUseActionCard;
  final int selectedCount;
  final bool hasActionCardAvailable;
  final ActionCardType actionCardType;

  const DrawnCardWidget({
    super.key,
    required this.drawnCard,
    required this.onDiscard,
    this.onSwap,
    this.onUseActionCard,
    required this.selectedCount,
    this.hasActionCardAvailable = false,
    this.actionCardType = ActionCardType.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Column(
        children: [
          _buildCardDisplay(),
          const SizedBox(height: 12),
          ActionButtonsWidget(
            onDiscard: onDiscard,
            onSwap: onSwap,
            onUseActionCard: onUseActionCard,
            selectedCount: selectedCount,
            hasActionCardAvailable: hasActionCardAvailable,
            actionCardType: actionCardType,
          ),
        ],
      ),
    );
  }

  Widget _buildCardDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Gezogen: ', style: TextStyle(color: Colors.white, fontSize: 16)),
        Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            color: ActionCardController.isActionCard(drawnCard)
                ? _getActionCardColor()
                : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black),
          ),
          child: _buildCardContent(),
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    if (ActionCardController.isActionCard(drawnCard)) {
      final actionType = ActionCardController.getActionType(drawnCard);
      final actionName = _getShortActionName(actionType);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            drawnCard,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              actionName,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Text(
          drawnCard,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }
  }

  Color _getActionCardColor() {
    final actionType = ActionCardController.getActionType(drawnCard);

    switch (actionType) {
      case ActionCardType.look:
        return Colors.orange[600]!;
      case ActionCardType.spy:
        return Colors.red[600]!;
      case ActionCardType.trade:
        return Colors.purple[600]!;
      case ActionCardType.none:
        return Colors.white;
    }
  }

  String _getShortActionName(ActionCardType type) {
    switch (type) {
      case ActionCardType.look:
        return 'LOOK';
      case ActionCardType.spy:
        return 'SPY';
      case ActionCardType.trade:
        return 'TRADE';
      case ActionCardType.none:
        return '';
    }
  }
}