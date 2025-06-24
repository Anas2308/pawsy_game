import 'package:flutter/foundation.dart';
import 'game_state_manager.dart';
import 'multi_swap_controller.dart';

class CardOperations {
  final List<String> deckCards = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '0'
  ];

  void drawRandomCard(GameStateManager state) {
    if (state.gamePhase == 'playing' && !state.hasDrawnThisTurn) {
      final random = DateTime.now().millisecondsSinceEpoch % deckCards.length;
      state.drawnCard = deckCards[random];
      state.hasDrawnThisTurn = true;
      state.drawnFromDeck = true;
      debugPrint('🎴 Karte vom DECK gezogen: ${state.drawnCard}');
    }
  }

  void drawFromDiscard(GameStateManager state) {
    if (state.gamePhase == 'playing' && !state.hasDrawnThisTurn) {
      state.drawnCard = state.topDiscardCard;
      state.hasDrawnThisTurn = true;
      state.drawnFromDeck = false;
      debugPrint('🎴 Karte vom DISCARD gezogen: ${state.drawnCard}');
    }
  }

  void swapCard(GameStateManager state, int cardIndex) {
    if (state.drawnCard != null) {
      if (state.currentPlayer == 'player') {
        final oldCard = state.playerCards[cardIndex];
        state.playerCards[cardIndex] = state.drawnCard!;
        state.topDiscardCard = oldCard;
      } else {
        final oldCard = state.aiCards[cardIndex];
        state.aiCards[cardIndex] = state.drawnCard!;
        state.topDiscardCard = oldCard;
      }
      state.drawnCard = null;
      state.drawnFromDeck = false;
    }
  }

  MultiSwapResult executeMultiSwap(GameStateManager state, List<int> selectedIndices) {
    if (state.drawnCard == null) {
      return MultiSwapResult.failure('Keine Karte gezogen');
    }

    final result = MultiSwapController.executeMultiSwap(
      playerCards: state.currentPlayer == 'player' ? state.playerCards : state.aiCards,
      selectedIndices: selectedIndices,
      drawnCard: state.drawnCard!,
    );

    if (result.isSuccess) {
      if (state.currentPlayer == 'player') {
        state.playerCards = result.newPlayerCards!;
      } else {
        state.aiCards = result.newPlayerCards!;
      }
      state.topDiscardCard = result.discardedCard!;
      state.drawnCard = null;
      state.drawnFromDeck = false;
    }

    return result;
  }

  void endTurnAfterPenalty(GameStateManager state) {
    if (state.drawnCard != null) {
      state.topDiscardCard = state.drawnCard!;
      state.drawnCard = null;
      state.drawnFromDeck = false;
    }
  }

  double getCardValueAsDouble(String card) {
    if (card == 'LEER') return 0.0;
    if (card == '0') return 0.0;
    if (card == '13') return 13.0;
    return double.tryParse(card) ?? 10.0;
  }
}