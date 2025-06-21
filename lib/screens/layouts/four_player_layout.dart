// lib/screens/layouts/four_player_layout.dart
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../controllers/game_controller.dart';
import '../../widgets/player_area.dart';
import '../../widgets/center_stacks.dart';

class FourPlayerLayout extends StatelessWidget {
  final GameState gameState;
  final GameController gameController;
  final Function(int) onPlayerTap;
  final Function(int, int) onOpponentCardTap;
  final Function(int) onHumanCardTap;

  const FourPlayerLayout({
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
        // Oberer Gegner (Spieler 2) - Oben
        if (gameState.players.length > 2)
          Expanded(flex: 2, child: _buildTopOpponentArea()),

        // Mittlerer Bereich mit seitlichen Gegnern und Center
        Expanded(flex: 4, child: _buildMiddleArea()),

        // Menschlicher Spieler (Spieler 0) - Unten
        if (gameState.players.isNotEmpty)
          Expanded(flex: 2, child: _buildHumanPlayerArea()),
      ],
    );
  }

  Widget _buildTopOpponentArea() {
    return Container(
      alignment: Alignment.center,
      child: PlayerArea(
        player: gameState.players[2],
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
        onPlayerTap: (playerIndex) => onPlayerTap(2),
        onCardTap: (cardIndex) => onOpponentCardTap(2, cardIndex),
      ),
    );
  }

  Widget _buildMiddleArea() {
    return Row(
      children: [
        // Linker Gegner (Spieler 1) - Rotiert
        if (gameState.players.length > 1)
          Expanded(flex: 2, child: _buildLeftOpponentArea()),

        // Center Stacks - Mitte
        Expanded(flex: 3, child: _buildCenterArea()),

        // Rechter Gegner (Spieler 3) - Rotiert
        if (gameState.players.length > 3)
          Expanded(flex: 2, child: _buildRightOpponentArea()),
      ],
    );
  }

  Widget _buildLeftOpponentArea() {
    return Container(
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 1,
        child: PlayerArea(
          player: gameState.players[1],
          isCompact: true,
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
      ),
    );
  }

  Widget _buildRightOpponentArea() {
    return Container(
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 3,
        child: PlayerArea(
          player: gameState.players[3],
          isCompact: true,
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
          onPlayerTap: (playerIndex) => onPlayerTap(3),
          onCardTap: (cardIndex) => onOpponentCardTap(3, cardIndex),
        ),
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
