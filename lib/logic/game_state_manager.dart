class GameStateManager {
  String gamePhase = 'look_at_cards';
  List<bool> playerCardsVisible = [false, false, false, false];
  List<bool> aiCardsVisible = [false, false, false, false];
  List<String> playerCards = ['7', '3', '9', '1'];
  List<String> aiCards = ['2', '8', '5', '11'];
  String currentPlayer = 'player';
  int cardsLookedAt = 0;
  String? drawnCard;
  String topDiscardCard = '7';
  bool hasDrawnThisTurn = false;
  bool hasPerformedActionThisTurn = false;
  bool drawnFromDeck = false;

  void resetState() {
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
    drawnFromDeck = false;
    topDiscardCard = '7';
  }

  void switchPlayer() {
    final previousPlayer = currentPlayer;
    currentPlayer = currentPlayer == 'player' ? 'ai' : 'player';
    print('🔄 Spielerwechsel: $previousPlayer → $currentPlayer');
  }

  void endTurn() {
    hasDrawnThisTurn = false;
    hasPerformedActionThisTurn = false;
    drawnFromDeck = false;
  }

  void revealCards(List<int> indices) {
    for (int index in indices) {
      if (currentPlayer == 'player' && index < playerCardsVisible.length) {
        playerCardsVisible[index] = true;
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

  void endGame() {
    gamePhase = 'game_ended';
    for (int i = 0; i < playerCardsVisible.length; i++) {
      playerCardsVisible[i] = true;
      aiCardsVisible[i] = true;
    }
  }

  bool get isPlayerTurn => currentPlayer == 'player';
  bool get isAITurn => currentPlayer == 'ai';

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

  String getWinner() {
    final playerScore = calculatePlayerScore();
    final aiScore = calculateAIScore();
    return playerScore <= aiScore ? 'Du' : 'KI';
  }
}