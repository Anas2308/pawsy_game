import 'ai_card_memory.dart';
import 'ai_pawsy_strategy.dart';
import 'smart_ai_controller.dart'; // für AIDecision

class AIDecisionMaker {
  final AICardMemory memory = AICardMemory();
  final AIPawsyStrategy pawsyStrategy = AIPawsyStrategy();

  AIDecision makeDecision({
    required String? drawnCard,
    required String topDiscardCard,
    required bool canDrawFromDeck,
    required bool canDrawFromDiscard,
    required bool canCallPawsy,
  }) {
    pawsyStrategy.incrementTurns();

    if (drawnCard == null && canCallPawsy) {
      if (pawsyStrategy.shouldCallPawsy(memory)) {
        return AIDecision.pawsy();
      }
    }

    if (drawnCard == null) {
      if (_shouldDrawFromDiscard(topDiscardCard)) {
        return AIDecision.drawFromDiscard();
      } else {
        return AIDecision.drawFromDeck();
      }
    }

    return _makeCardDecision(drawnCard);
  }

  bool _shouldDrawFromDiscard(String topCard) {
    double cardValue = memory.getCardValue(topCard);
    memory.observeCard(topCard);

    if (cardValue <= 3) return true;

    if (cardValue <= 7) {
      double worstKnownValue = memory.getWorstKnownCardValue();
      return cardValue < worstKnownValue - 2;
    }

    return cardValue <= 8 && memory.getActiveCardCount() <= 2;
  }

  AIDecision _makeCardDecision(String drawnCard) {
    double cardValue = memory.getCardValue(drawnCard);
    memory.observeCard(drawnCard);

    int bestSwapIndex = _findBestSwapPosition(cardValue.toInt());

    if (bestSwapIndex != -1) {
      List<int> duplicateIndices = memory.findDuplicates(drawnCard);

      if (duplicateIndices.isNotEmpty && cardValue <= 6) {
        return AIDecision.multiSwap([bestSwapIndex, ...duplicateIndices]);
      }

      return AIDecision.swap(bestSwapIndex);
    }

    return AIDecision.discard();
  }

  int _findBestSwapPosition(int newCardValue) {
    int bestIndex = -1;
    double bestImprovement = 0;

    for (int i = 0; i < 4; i++) {
      if (memory.knownCards[i] != null && memory.knownCards[i] != 'LEER') {
        double currentValue = memory.getCardValue(memory.knownCards[i]!);
        double improvement = currentValue - newCardValue;

        if (improvement > bestImprovement) {
          bestImprovement = improvement;
          bestIndex = i;
        }
      }
    }

    return bestImprovement >= 2 ? bestIndex : -1;
  }

  void setInitialCards(List<String> cards) {
    memory.setInitialCards(cards);
  }

  void observePlayerReveal(int cardIndex, String cardValue) {
    memory.observePlayerReveal(cardIndex, cardValue);
  }

  void updateCard(int index, String newCard) {
    memory.updateCard(index, newCard);
  }

  void setCardEmpty(int index) {
    memory.setCardEmpty(index);
  }

  void reset() {
    memory.reset();
    pawsyStrategy.reset();
  }

  // Getters für Kompatibilität
  List<String?> get knownCards => memory.knownCards;
  List<String> get playerRevealedCards => memory.playerRevealedCards;
}