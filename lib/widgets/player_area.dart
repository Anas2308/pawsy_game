// lib/widgets/player_area.dart
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../utils/constants.dart';

class PlayerArea extends StatelessWidget {
  final Player player;
  final bool isCompact;
  final bool showDrawnCard;
  final bool isLookingAtCards;
  final Function(int)? onCardTap;

  const PlayerArea({
    super.key,
    required this.player,
    this.isCompact = false,
    this.showDrawnCard = false,
    this.isLookingAtCards = false,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!player.isHuman)
            Text(
              '${player.name} (${player.cards.length} Karten)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return _buildCard(index);
            }),
          ),
          const SizedBox(height: 8),
          if (player.isHuman)
            Text(
              '${player.name} (${player.cards.length} Karten)',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    bool hasCard = index < player.cards.length;
    bool isPlayerCard = player.isHuman && hasCard;
    GameCard? card = hasCard ? player.cards[index] : null;

    return GestureDetector(
      onTap: () {
        if (isLookingAtCards && player.isHuman && hasCard && !card!.isVisible) {
          onCardTap?.call(index);
        } else if (isPlayerCard && showDrawnCard) {
          onCardTap?.call(index);
        }
      },
      child: Container(
        width: isCompact ? CardSizes.compactWidth : CardSizes.normalWidth,
        height: isCompact ? CardSizes.compactHeight : CardSizes.normalHeight,
        margin: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 4),
        decoration: BoxDecoration(
          color: _getCardBackgroundColor(hasCard, isPlayerCard, card),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getCardBorderColor(hasCard, isPlayerCard),
            width: _getCardBorderWidth(hasCard, isPlayerCard),
          ),
        ),
        child: Center(child: _getCardContent(hasCard, isPlayerCard, card)),
      ),
    );
  }

  Color _getCardBackgroundColor(
    bool hasCard,
    bool isPlayerCard,
    GameCard? card,
  ) {
    if (!hasCard) return AppColors.emptyCard;

    if (player.isHuman) {
      if (isLookingAtCards && hasCard && !card!.isVisible) {
        return AppColors.interactiveCard;
      }
      if (isPlayerCard && showDrawnCard) {
        return AppColors.interactiveCard;
      }
      return card?.isVisible == true ? card!.color : AppColors.playerCard;
    }

    return AppColors.opponentCard;
  }

  Color _getCardBorderColor(bool hasCard, bool isPlayerCard) {
    if (isLookingAtCards && player.isHuman && hasCard) {
      return AppColors.selectedCard;
    }
    if (isPlayerCard && showDrawnCard) return AppColors.selectedCard;
    return hasCard ? AppColors.textPrimary : AppColors.border;
  }

  double _getCardBorderWidth(bool hasCard, bool isPlayerCard) {
    if (isLookingAtCards && player.isHuman && hasCard) return 3;
    if (isPlayerCard && showDrawnCard) return 3;
    return hasCard ? 2 : 1;
  }

  Widget _getCardContent(bool hasCard, bool isPlayerCard, GameCard? card) {
    if (!hasCard) {
      return Icon(
        Icons.crop_portrait,
        color: AppColors.border,
        size: isCompact ? 15 : 20,
      );
    }

    if (player.isHuman && card?.isVisible == true) {
      return Text(
        '${card!.value}',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isCompact ? 16 : 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Zeige Kartenrücken mit Hintergrundbild
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/starter.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Center(
          child: Icon(
            Icons.pets,
            color: AppColors.textPrimary,
            size: isCompact ? 20 : 30,
          ),
        ),
      ),
    );
  }
}
