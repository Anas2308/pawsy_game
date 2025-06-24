import 'multi_swap_controller.dart';

class GameController {
  String gamePhase = 'look_at_cards';
  List<bool> playerCardsVisible = [false, false, false, false];
  List<String> playerCards = ['7', '3', '9', '1'];
  int cardsLookedAt = 0;
  String? drawnCard;
  String topDiscardCard = '7';
  bool hasDrawnThisTurn = false;
  bool hasPerformedActionThisTurn = false;
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;

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
    hasPerformedActionThisTurn = false;
    pawsyCaller = null;
    remainingTurnsAfterPawsy = 0;
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
      hasPerformedActionThisTurn = true;
    }
  }

  void swapCard(int cardIndex) {
    if (drawnCard != null) {
      final oldCard = playerCards[cardIndex];
      playerCards[cardIndex] = drawnCard!;
      topDiscardCard = oldCard;
      drawnCard = null;
      hasDrawnThisTurn = false;
      hasPerformedActionThisTurn = true;
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
      hasPerformedActionThisTurn = true;
    }

    return result;
  }

  void callPawsy() {
    if (canCallPawsy()) {
      pawsyCaller = 'You';
      remainingTurnsAfterPawsy = 1; // 1 Gegner = 1 Zug
      gamePhase = 'pawsy_called';
      hasDrawnThisTurn = false;
      hasPerformedActionThisTurn = true;
    }
  }

  bool canCallPawsy() {
    return gamePhase == 'playing' &&
        !hasPerformedActionThisTurn &&
        drawnCard == null &&
        pawsyCaller == null;
  }

  void nextTurn() {
    if (pawsyCaller != null) {
      remainingTurnsAfterPawsy--;
      if (remainingTurnsAfterPawsy <= 0) {
        endGame();
      }
    }

    hasDrawnThisTurn = false;
    hasPerformedActionThisTurn = false;
  }

  void endGame() {
    gamePhase = 'game_ended';
    // Alle Karten aufdecken
    for (int i = 0; i < playerCardsVisible.length; i++) {
      playerCardsVisible[i] = true;
    }
  }

  int calculateScore() {
    int score = 0;
    for (String card in playerCards) {
      if (card == 'LEER') continue;
      if (card == '0') {
        score += 0;
      } else if (card == '13') {
        score += 13;
      } else {
        score += int.tryParse(card) ?? 0;
      }
    }
    return score;
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
    hasPerformedActionThisTurn = true;
  }

  String getStatusText() {
    if (gamePhase == 'look_at_cards') {
      return 'Schaue dir 2 Karten an ($cardsLookedAt/2)';
    } else if (gamePhase == 'pawsy_called') {
      return 'PAWSY gerufen! Noch $remainingTurnsAfterPawsy Zug(e) bis Spielende';
    } else if (gamePhase == 'game_ended') {
      return 'Spiel beendet! Deine Punkte: ${calculateScore()}';
    } else if (drawnCard != null) {
      return 'Gezogene Karte: $drawnCard\nKarten wählen → Tausch-Button klicken';
    } else if (hasPerformedActionThisTurn) {
      return 'Zug beendet - Nächster Spieler';
    } else {
      return 'Ziehe eine Karte oder rufe PAWSY!';
    }
  }
}