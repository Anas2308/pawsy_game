// lib/widgets/center_stacks.dart
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../utils/constants.dart';

class CenterStacks extends StatelessWidget {
  final int deckSize;
  final GameCard? discardCard;
  final bool showDrawnCard;
  final bool isDealing;
  final bool isDrawingFromDiscard;
  final VoidCallback? onDrawFromDeck;
  final VoidCallback? onDrawFromDiscard;
  final VoidCallback? onDiscardDrawnCard;

  const CenterStacks({
    Key? key,
    required this.deckSize,
    this.discardCard,
    this.showDrawnCard = false,
    this.isDealing = false,
    this.isDrawingFromDiscard = false,
    this.onDrawFromDeck,
    this.onDrawFromDiscard,
    this.onDiscardDrawnCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDrawPile(),
          const SizedBox(width: 20),
          _buildDiscardPile(),
        ],
      ),
    );
  }

  Widget _buildDrawPile() {
    bool canDraw = !isDealing && !showDrawnCard && !isDrawingFromDiscard;

    return GestureDetector(
      onTap: canDraw ? onDrawFromDeck : null,
      child: Container(
        width: CardSizes.centerWidth,
        height: CardSizes.centerHeight,
        decoration: BoxDecoration(
          color: canDraw ? AppColors.deckCard : AppColors.emptyCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textPrimary, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, color: AppColors.textPrimary, size: 40),
            Text(
              '$deckSize',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              GameStrings.drawPile,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscardPile() {
    bool canDrawFromDiscard =
        !isDealing && !isDrawingFromDiscard && !showDrawnCard;
    bool canDiscardTo = showDrawnCard;
    bool isInteractive = canDrawFromDiscard || canDiscardTo;

    return GestureDetector(
      onTap: canDiscardTo
          ? onDiscardDrawnCard
          : (canDrawFromDiscard ? onDrawFromDiscard : null),
      child: Container(
        width: CardSizes.centerWidth,
        height: CardSizes.centerHeight,
        decoration: BoxDecoration(
          color: discardCard?.color ?? AppColors.emptyCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInteractive
                ? AppColors.interactiveCard
                : AppColors.textPrimary,
            width: isInteractive ? 4 : 3,
          ),
        ),
        child: Center(
          child: discardCard != null
              ? Text(
                  '${discardCard!.value}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(
                  Icons.help_outline,
                  color: AppColors.textPrimary,
                  size: 36,
                ),
        ),
      ),
    );
  }
}
