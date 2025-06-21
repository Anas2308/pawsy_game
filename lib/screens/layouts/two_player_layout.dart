// lib/screens/layouts/two_player_layout.dart
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../controllers/game_controller.dart';
import '../../widgets/player_area.dart';
import '../../widgets/center_stacks.dart';

class TwoPlayerLayout extends StatelessWidget {
  final GameState gameState;
  final GameController gameController;
  final Function(int) onPlayerTap;
  final Function(int, int) onOpponentCardTap;
  final Function(int) onHumanCardTap;

  const TwoPlayerLayout({
    super.key,
    required this.gameState,
    required this.gameController,
    required this.onPlayerTap,
    required this.onOpponentCardTap,
    required this.onHumanCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gegner (Spieler 1) - Oben
        if (gameState.players.length > 1)
          Expanded(flex: 2, child: _buildOpponentArea()),

        // Freier Raum
        const Spacer(),

        // Center Stacks - Mitte
        Expanded(flex: 3, child: _buildCenterArea()),

        // Freier Raum
        const Spacer(),

        // Menschlicher Spieler (Spieler 0) - Unten
        if (gameState.players.isNotEmpty)
          Expanded(flex: 2, child: _buildHumanPlayerArea()),
      ],
    );
  }

  Widget _buildOpponentArea() {
    return Container(
      alignment: Alignment.center,
      child: PlayerArea(
        player: gameState.players[1],
        showDrawnCard: gameState.showDrawnCard,
        isLookingAtCards: gameState.isLookingAtCards,
        actionPhase: gameState.actionPhase,
        animationPhase: gameState.animationPhase,
        selectedPlayerIndex: gameState.selectedPlayerIndex,
        selectedCardIndex: gameState.selectedCardIndex,
        revealedPlayerIndex: gameState.revealedPlayerIndex,
        revealedCardIndex: gameState.revealedCardIndex,
        highlightedPlayerIndex: gameState.highlightedPlayerIndex,
        highlightedCardIndex: gameState.highlightedCardIndex,
        switchingCards: gameState.switchingCards,
        onPlayerTap: (playerIndex) => onPlayerTap(1),
        onCardTap: (cardIndex) => onOpponentCardTap(1, cardIndex),
      ),
    );
  }

  Widget _buildCenterArea() {
    return Container(
      alignment: Alignment.center,
      child: CenterStacks(
        deckSize: gameState.deck.length,
        discardCard: gameState.discardPile,
        showDrawnCard: gameState.showDrawnCard,
        isDealing: gameState.isDealing,
        isDrawingFromDiscard: gameState.isDrawingFromDiscard,
        onDrawFromDeck: () => gameController.drawCardFromDeck(),
        onDrawFromDiscard: () => _handleDrawFromDiscard(),
        onDiscardDrawnCard: () => gameController.discardDrawnCard(),
      ),
    );
  }

  Widget _buildHumanPlayerArea() {
    return Container(
      alignment: Alignment.center,
      child: PlayerArea(
        player: gameState.players[0],
        showDrawnCard: gameState.showDrawnCard,
        isLookingAtCards: gameState.isLookingAtCards,
        actionPhase: gameState.actionPhase,
        animationPhase: gameState.animationPhase,
        selectedPlayerIndex: gameState.selectedPlayerIndex,
        selectedCardIndex: gameState.selectedCardIndex,
        revealedPlayerIndex: gameState.revealedPlayerIndex,
        revealedCardIndex: gameState.revealedCardIndex,
        highlightedPlayerIndex: gameState.highlightedPlayerIndex,
        highlightedCardIndex: gameState.highlightedCardIndex,
        switchingCards: gameState.switchingCards,
        onCardTap: onHumanCardTap,
      ),
    );
  }

  void _handleDrawFromDiscard() {
    gameController.drawCardFromDiscard();
    // Animation handling wird später von AnimationService übernommen
  }
}
