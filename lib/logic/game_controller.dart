import 'multi_swap_controller.dart';

class GameController {
  String gamePhase = 'look_at_cards';
  List<bool> playerCardsVisible = [false, false, false, false];
  List<String> playerCards = ['7', '3', '9', '1'];
  int cardsLookedAt = 0;
  String? drawnCard;
  String topDiscardCard = '7';
  bool hasDrawnThisTurn = false;

  final List<String> deckCards = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '0'
  ];

  void restartGame() {
    gamePhase = 'look_at_cards';
    playerCardsVisible = [false, false, false, false];
    playerCards = ['7', '3', '9', '1'];
    cardsLookedAt = 0;
    drawnCard = null;
    hasDrawnThisTurn = false;
    topDiscardCard = '7';
  }

  void drawRandomCard() {
    if (gamePhase == 'playing' && !hasDrawnThisTurn) {
      final random = DateTime.now().millisecondsSinceEpoch % deckCards.length;
      drawnCard = deckCards[random];
      hasDrawnThisTurn = true;
    }
  }

  void drawFromDiscard() {
    if (gamePhase == 'playing' && !hasDrawnThisTurn) {
      drawnCard = topDiscardCard;
      hasDrawnThisTurn = true;
    }
  }

  void discardDrawnCard() {
    if (drawnCard != null) {
      topDiscardCard = drawnCard!;
      drawnCard = null;
      hasDrawnThisTurn = false;
    }
  }

  void swapCard(int cardIndex) {
    if (drawnCard != null) {
      final oldCard = playerCards[cardIndex];
      playerCards[cardIndex] = drawnCard!;
      topDiscardCard = oldCard;
      drawnCard = null;
      hasDrawnThisTurn = false;
    }
  }

  MultiSwapResult executeMultiSwap(List<int> selectedIndices) {
    if (drawnCard == null) {
      return MultiSwapResult.failure('Keine Karte gezogen');
    }

    final result = MultiSwapController.executeMultiSwap(
      playerCards: playerCards,
      selectedIndices: selectedIndices,
      drawnCard: drawnCard!,
    );

    if (result.isSuccess) {
      playerCards = result.newPlayerCards!;
      topDiscardCard = result.discardedCard!;
      drawnCard = null;
      hasDrawnThisTurn = false;
    }

    return result;
  }

  void revealCards(List<int> indices) {
    for (int index in indices) {
      if (index < playerCardsVisible.length) {
        playerCardsVisible[index] = true;
      }
    }
  }

  void hideCards(List<int> indices) {
    for (int index in indices) {
      if (index < playerCardsVisible.length) {
        playerCardsVisible[index] = false;
      }
    }
  }

  void endTurnAfterPenalty() {
    if (drawnCard != null) {
      topDiscardCard = drawnCard!;
      drawnCard = null;
    }
    hasDrawnThisTurn = false;
  }

  String getStatusText() {
    if (gamePhase == 'look_at_cards') {
      return 'Schaue dir 2 Karten an ($cardsLookedAt/2)';
    } else if (drawnCard != null) {
      return 'Gezogene Karte: $drawnCard\nKarten wählen → Tausch-Button klicken';
    } else if (hasDrawnThisTurn) {
      return 'Zug beendet - Nächster Spieler';
    } else {
      return 'Ziehe eine Karte vom Deck oder Ablagestapel';
    }
  }
}