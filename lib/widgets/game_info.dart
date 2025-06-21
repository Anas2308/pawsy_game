// lib/widgets/game_info.dart
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class GameInfo extends StatelessWidget {
  final GameState gameState;
  final int playerCount;

  const GameInfo({
    super.key,
    required this.gameState,
    required this.playerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMainInfo(),
          if (_shouldShowPhaseInfo()) _buildPhaseInfo(),
          if (_shouldShowActionInfo()) _buildActionInfo(),
          if (_shouldShowAnimationInfo()) _buildAnimationInfo(),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      children: [
        Text(
          '$playerCount Spieler',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Deck: ${gameState.deck.length} Karten',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPhaseInfo() {
    String phaseText = _getPhaseText();
    Color phaseColor = _getPhaseColor();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Text(
        phaseText,
        style: TextStyle(
          color: phaseColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        children: [
          Text(
            gameState.discardPile?.actionName ?? '',
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            gameState.actionPhaseDescription,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Text(
        'Animation: ${_getAnimationText()}',
        style: const TextStyle(color: Colors.yellow, fontSize: 12),
      ),
    );
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  bool _shouldShowPhaseInfo() {
    return gameState.isDealing ||
        gameState.isLookingAtCards ||
        gameState.showDrawnCard ||
        gameState.isDrawingFromDiscard;
  }

  bool _shouldShowActionInfo() {
    return gameState.isInActionPhase;
  }

  bool _shouldShowAnimationInfo() {
    return gameState.isAnimating;
  }

  String _getPhaseText() {
    if (gameState.isDealing) {
      return 'Teile Karte ${gameState.currentDealingCard + 1} an ${_getCurrentDealingPlayerName()} aus...';
    }

    if (gameState.isLookingAtCards) {
      return GameStrings.lookAtCards;
    }

    if (gameState.showDrawnCard && gameState.drawnCard != null) {
      return '${GameStrings.cardDrawn} ${gameState.drawnCard!.value} - ${GameStrings.clickToInteract}';
    }

    if (gameState.isDrawingFromDiscard) {
      return GameStrings.drawingFromDiscard;
    }

    return '';
  }

  Color _getPhaseColor() {
    if (gameState.isDealing) return Colors.yellow;
    if (gameState.isLookingAtCards) return Colors.yellow;
    if (gameState.showDrawnCard) return Colors.lightBlue;
    if (gameState.isDrawingFromDiscard) return Colors.orange;
    return AppColors.textPrimary;
  }

  String _getAnimationText() {
    switch (gameState.animationPhase) {
      case AnimationPhase.highlighting:
        return 'Highlighting';
      case AnimationPhase.switching:
        return 'Switching';
      default:
        return 'None';
    }
  }

  String _getCurrentDealingPlayerName() {
    if (gameState.players.isEmpty ||
        gameState.dealingToPlayerIndex >= gameState.players.length) {
      return 'Spieler';
    }
    return gameState.players[gameState.dealingToPlayerIndex].name;
  }
}
