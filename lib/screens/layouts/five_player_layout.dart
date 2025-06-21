// lib/screens/layouts/five_player_layout.dart
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../controllers/game_controller.dart';
import '../../widgets/player_area.dart';
import '../../widgets/center_stacks.dart';

class FivePlayerLayout extends StatelessWidget {
  final GameState gameState;
  final GameController gameController;
  final Function(int) onPlayerTap;
  final Function(int, int) onOpponentCardTap;
  final Function(int) onHumanCardTap;

  const FivePlayerLayout({
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
        // Obere Gegner (Spieler 2 & 3) - Oben
        Expanded(flex: 2, child: _buildTopOpponentsArea()),

        // Mittlerer Bereich mit seitlichen Gegnern und Center
        Expanded(flex: 4, child: _buildMiddleArea()),

        // Menschlicher Spieler (Spieler 0) - Unten
        if (gameState.players.isNotEmpty)
          Expanded(flex: 2, child: _buildHumanPlayerArea()),
      ],
    );
  }

  Widget _buildTopOpponentsArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Spieler 2 (links oben)
        if (gameState.players.length > 2)
          Expanded(child: _buildTopOpponentArea(2)),

        // Abstand
        const SizedBox(width: 20),

        // Spieler 3 (rechts oben)
        if (gameState.players.length > 3)
          Expanded(child: _buildTopOpponentArea(3)),
      ],
    );
  }

  Widget _buildTopOpponentArea(int playerIndex) {
    return Container(
      alignment: Alignment.center,
      child: PlayerArea(
        player: gameState.players[playerIndex],
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
        onPlayerTap: (pIndex) => onPlayerTap(playerIndex),
        onCardTap: (cardIndex) => onOpponentCardTap(playerIndex, cardIndex),
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

        // Rechter Gegner (Spieler 4) - Rotiert
        if (gameState.players.length > 4)
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
          player: gameState.players[4],
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
          onPlayerTap: (playerIndex) => onPlayerTap(4),
          onCardTap: (cardIndex) => onOpponentCardTap(4, cardIndex),
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
