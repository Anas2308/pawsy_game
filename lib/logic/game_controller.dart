import 'multi_swap_controller.dart';
import 'smart_ai_controller.dart';

class GameController {
  String gamePhase = 'look_at_cards';
  List<bool> playerCardsVisible = [false, false, false, false];
  List<bool> aiCardsVisible = [false, false, false, false];
  List<String> playerCards = ['7', '3', '9', '1'];
  List<String> aiCards = ['2', '8', '5', '11'];
  String currentPlayer = 'player'; // 'player' or 'ai'
  int cardsLookedAt = 0;
  String? drawnCard;
  String topDiscardCard = '7';
  bool hasDrawnThisTurn = false;
  bool hasPerformedActionThisTurn = false;
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;

  final SmartAIController smartAI = SmartAIController();

  final List<String> deckCards = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '0'
  ];

  void restartGame() {
    gamePhase = 'look_at_cards';
    playerCardsVisible = [false, false, false, false];
    aiCardsVisible = [false, false, false, false];
    playerCards = ['7', '3', '9', '1'];
    aiCards = ['2', '8', '5', '11'];
    currentPlayer = 'player';
    cardsLookedAt = 0;
    drawnCard = null;
    hasDrawnThisTurn = false;
    hasPerformedActionThisTurn = false;
    pawsyCaller = null;
    remainingTurnsAfterPawsy = 0;
    topDiscardCard = '7';

    // Smart AI initialisieren
    smartAI.reset();
    smartAI.setInitialCards(aiCards);
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
      _endTurn();
    }
  }

  void swapCard(int cardIndex) {
    if (drawnCard != null) {
      if (currentPlayer == 'player') {
        final oldCard = playerCards[cardIndex];
        playerCards[cardIndex] = drawnCard!;
        topDiscardCard = oldCard;
      } else {
        final oldCard = aiCards[cardIndex];
        aiCards[cardIndex] = drawnCard!;
        smartAI.updateCard(cardIndex, drawnCard!);
        topDiscardCard = oldCard;
      }
      drawnCard = null;
      _endTurn();
    }
  }

  MultiSwapResult executeMultiSwap(List<int> selectedIndices) {
    if (drawnCard == null) {
      return MultiSwapResult.failure('Keine Karte gezogen');
    }

    final result = MultiSwapController.executeMultiSwap(
      playerCards: currentPlayer == 'player' ? playerCards : aiCards,
      selectedIndices: selectedIndices,
      drawnCard: drawnCard!,
    );

    if (result.isSuccess) {
      if (currentPlayer == 'player') {
        playerCards = result.newPlayerCards!;
      } else {
        aiCards = result.newPlayerCards!;
        // KI über Änderungen informieren
        for (int i = 1; i < selectedIndices.length; i++) {
          smartAI.setCardEmpty(selectedIndices[i]);
        }
        smartAI.updateCard(selectedIndices.first, drawnCard!);
      }
      topDiscardCard = result.discardedCard!;
      drawnCard = null;
      _endTurn();
    }

    return result;
  }

  void callPawsy() {
    if (canCallPawsy()) {
      pawsyCaller = currentPlayer;
      remainingTurnsAfterPawsy = currentPlayer == 'player' ? 1 : 1;
      gamePhase = 'pawsy_called';
      _endTurn();
    }
  }

  bool canCallPawsy() {
    return gamePhase == 'playing' &&
        !hasPerformedActionThisTurn &&
        drawnCard == null;
  }

  void _endTurn() {
    hasDrawnThisTurn = false;
    hasPerformedActionThisTurn = false;

    if (pawsyCaller != null) {
      remainingTurnsAfterPawsy--;
      if (remainingTurnsAfterPawsy <= 0) {
        endGame();
        return;
      }
    }

    // Spielerwechsel
    currentPlayer = currentPlayer == 'player' ? 'ai' : 'player';
  }

  void nextTurn() {
    _endTurn();
  }

  bool get isPlayerTurn => currentPlayer == 'player';
  bool get isAITurn => currentPlayer == 'ai';

  // KI-Entscheidungen
  Future<AIDecision> getAIDecision() async {
    return smartAI.makeDecision(
      drawnCard: drawnCard,
      topDiscardCard: topDiscardCard,
      canDrawFromDeck: !hasDrawnThisTurn,
      canDrawFromDiscard: !hasDrawnThisTurn,
      canCallPawsy: canCallPawsy(),
    );
  }

  void executeAIDecision(AIDecision decision) {
    if (decision.isDrawFromDeck) {
      drawRandomCard();
    } else if (decision.isDrawFromDiscard) {
      drawFromDiscard();
    } else if (decision.isSwap) {
      swapCard(decision.cardIndex!);
    } else if (decision.isMultiSwap) {
      final result = executeMultiSwap(decision.cardIndices!);
      if (result.isPenalty) {
        smartAI.observeCard(aiCards[decision.cardIndices!.first]);
      }
    } else if (decision.isDiscard) {
      discardDrawnCard();
    } else if (decision.isPawsy) {
      callPawsy();
    }
  }

  void revealCards(List<int> indices) {
    for (int index in indices) {
      if (currentPlayer == 'player' && index < playerCardsVisible.length) {
        playerCardsVisible[index] = true;
        // KI beobachtet aufgedeckte Spielerkarten
        smartAI.observePlayerReveal(index, playerCards[index]);
      } else if (currentPlayer == 'ai' && index < aiCardsVisible.length) {
        aiCardsVisible[index] = true;
      }
    }
  }

  void hideCards(List<int> indices) {
    for (int index in indices) {
      if (currentPlayer == 'player' && index < playerCardsVisible.length) {
        playerCardsVisible[index] = false;
      } else if (currentPlayer == 'ai' && index < aiCardsVisible.length) {
        aiCardsVisible[index] = false;
      }
    }
  }

  void endTurnAfterPenalty() {
    if (drawnCard != null) {
      topDiscardCard = drawnCard!;
      drawnCard = null;
    }
    _endTurn();
  }

  void endGame() {
    gamePhase = 'game_ended';
    // Alle Karten aufdecken
    for (int i = 0; i < playerCardsVisible.length; i++) {
      playerCardsVisible[i] = true;
      aiCardsVisible[i] = true;
    }
  }

  int calculateScore() {
    return calculatePlayerScore();
  }

  int calculatePlayerScore() {
    return _calculateScore(playerCards);
  }

  int calculateAIScore() {
    return _calculateScore(aiCards);
  }

  int _calculateScore(List<String> cards) {
    int score = 0;
    for (String card in cards) {
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

  String getStatusText() {
    if (gamePhase == 'look_at_cards') {
      return 'Schaue dir 2 Karten an ($cardsLookedAt/2)';
    } else if (gamePhase == 'pawsy_called') {
      return 'PAWSY gerufen von ${pawsyCaller == 'player' ? 'Dir' : 'KI'}! Noch $remainingTurnsAfterPawsy Zug(e)';
    } else if (gamePhase == 'game_ended') {
      final playerScore = calculatePlayerScore();
      final aiScore = calculateAIScore();
      final winner = playerScore <= aiScore ? 'Du' : 'KI';
      return 'Spiel beendet! $winner gewinnst! (Du: $playerScore, KI: $aiScore)';
    } else if (currentPlayer == 'ai') {
      return 'KI ist am Zug...';
    } else if (drawnCard != null) {
      return 'Gezogene Karte: $drawnCard\nKarten wählen → Tausch-Button klicken';
    } else if (hasPerformedActionThisTurn) {
      return 'Zug beendet - KI ist dran';
    } else {
      return 'Du bist dran! Ziehe eine Karte oder rufe PAWSY!';
    }
  }
}