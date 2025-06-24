import 'package:flutter/material.dart';
import '../logic/action_card_controller.dart';

class CardWidget extends StatelessWidget {
  final String cardValue;
  final bool isVisible;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.cardValue,
    required this.isVisible,
    this.isSelectable = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // LEER-Karten haben spezielle Darstellung
    if (cardValue == 'LEER') {
      return _buildEmptyCard();
    }

    Color borderColor = Colors.black;
    double borderWidth = 1;
    List<BoxShadow>? shadows;
    Color cardColor = isVisible ? Colors.white : Colors.blue[900]!;

    // Aktionskarten haben spezielle Farben
    if (isVisible && ActionCardController.isActionCard(cardValue)) {
      cardColor = _getActionCardColor();
    }

    if (isSelected) {
      borderColor = Colors.purple;
      borderWidth = 4;
      shadows = [
        BoxShadow(
          color: Colors.purple.withValues(alpha: 0.6),
          blurRadius: 12,
          spreadRadius: 3,
        ),
      ];
    } else if (isSelectable) {
      borderColor = Colors.yellow;
      borderWidth = 3;
      shadows = [
        BoxShadow(
          color: Colors.yellow.withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ];
    }

    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: shadows,
        ),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    if (!isVisible) {
      return const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    final isActionCard = ActionCardController.isActionCard(cardValue);

    if (isActionCard) {
      return _buildActionCardContent();
    } else {
      return _buildNormalCardContent();
    }
  }

  Widget _buildActionCardContent() {
    final actionType = ActionCardController.getActionType(cardValue);
    final actionName = _getShortActionName(actionType);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          cardValue,
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
  }

  Widget _buildNormalCardContent() {
    return Center(
      child: Text(
        cardValue,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _getTextColor(),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.remove,
          color: Colors.grey[600],
          size: 24,
        ),
      ),
    );
  }

  Color _getActionCardColor() {
    final actionType = ActionCardController.getActionType(cardValue);

    switch (actionType) {
      case ActionCardType.look:
        return Colors.orange[600]!; // 6-7: Orange
      case ActionCardType.spy:
        return Colors.red[600]!;    // 8-9: Rot
      case ActionCardType.trade:
        return Colors.purple[600]!; // 10-11: Lila
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

  Color _getTextColor() {
    if (isVisible) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}