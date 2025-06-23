import 'package:flutter/material.dart';
import 'card_widget.dart';

class PlayerArea extends StatelessWidget {
  final String playerName;
  final bool isCurrentPlayer;
  final List<bool>? cardsVisible;
  final List<String>? cardValues;
  final List<bool>? selectedCards;
  final Function(int)? onCardTap;
  final bool canSelectCards;
  final bool isMultiSelectMode;

  const PlayerArea({
    super.key,
    required this.playerName,
    required this.isCurrentPlayer,
    this.cardsVisible,
    this.cardValues,
    this.selectedCards,
    this.onCardTap,
    this.canSelectCards = false,
    this.isMultiSelectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final values = cardValues ?? ['7', '3', '9', '1'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isCurrentPlayer
            ? Border.all(color: Colors.yellow, width: 3)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            playerName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isVisible = cardsVisible?[index] ?? false;
              final isSelected = selectedCards?[index] ?? false;
              final isSelectable = canSelectCards && !isVisible;

              return Padding(
                padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                child: CardWidget(
                  cardValue: values[index],
                  isVisible: isVisible,
                  isSelectable: isSelectable,
                  isSelected: isSelected,
                  onTap: isSelectable ? () => onCardTap?.call(index) : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}