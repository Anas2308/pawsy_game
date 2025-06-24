import 'dart:math';
import 'package:flutter/foundation.dart';

class SmartAIController {
  List<String?> knownCards = [null, null, null, null];
  List<String> aiCards = ['?', '?', '?', '?'];
  List<String> seenCards = [];
  Map<String, int> remainingCardCount = {};
  List<String> playerRevealedCards = [];
  int turnsPlayed = 0; // NEU: Zähle Züge

  SmartAIController() {
    _initializeDeck();
  }

  void _initializeDeck() {
    remainingCardCount = {
      '0': 2, '1': 4, '2': 4, '3': 4, '4': 4, '5': 4, '6': 4,
      '7': 4, '8': 4, '9': 4, '10': 4, '11': 4, '12': 4, '13': 2
    };
  }

  void setInitialCards(List<String> cards) {
    aiCards = List.from(cards);
    final random = Random();
    final indices = [0, 1, 2, 3]..shuffle(random);
    knownCards[indices[0]] = cards[indices[0]];
    knownCards[indices[1]] = cards[indices[1]];
    turnsPlayed = 0; // Reset

    for (String card in cards) {
      _removeCardFromDeck(card);
    }
  }

  void observeCard(String card) {
    if (!seenCards.contains(card)) {
      seenCards.add(card);
    }
  }

  void observePlayerReveal(int cardIndex, String cardValue) {
    playerRevealedCards.add(cardValue);
    observeCard(cardValue);
  }

  void updateCard(int index, String newCard) {
    aiCards[index] = newCard;
    knownCards[index] = newCard;
    observeCard(newCard);
  }

  void setCardEmpty(int index) {
    aiCards[index] = 'LEER';
    knownCards[index] = 'LEER';
  }

  void _removeCardFromDeck(String card) {
    if (remainingCardCount.containsKey(card) && remainingCardCount[card]! > 0) {
      remainingCardCount[card] = remainingCardCount[card]! - 1;
    }
  }

  AIDecision makeDecision({
    required String? drawnCard,
    required String topDiscardCard,
    required bool canDrawFromDeck,
    required bool canDrawFromDiscard,
    required bool canCallPawsy,
  }) {
    turnsPlayed++; // Zähle jeden Entscheidungszug

    if (drawnCard == null && canCallPawsy) {
      if (_shouldCallPawsyStrategic()) {
        return AIDecision.pawsy();
      }
    }

    if (drawnCard == null) {
      if (_shouldDrawFromDiscardStrategic(topDiscardCard)) {
        return AIDecision.drawFromDiscard();
      } else {
        return AIDecision.drawFromDeck();
      }
    }

    return _makeAdvancedCardDecision(drawnCard);
  }

  bool _shouldCallPawsyStrategic() {
    double myEstimatedScore = _calculateMyEstimatedScore();
    double opponentEstimatedScore = _calculateOpponentEstimatedScore();

    debugPrint('🧠 KI Analysis: Meine Punkte ≈ $myEstimatedScore, Gegner ≈ $opponentEstimatedScore, Züge: $turnsPlayed');

    int knownCardsCount = knownCards.where((c) => c != null && c != 'LEER').length;

    // VERBESSERTE PAWSY-LOGIK:

    // 1. Aggressive PAWSY wenn KI deutlich im Vorteil
    if (myEstimatedScore < opponentEstimatedScore - 5 && knownCardsCount >= 2) {
      debugPrint('🐾 PAWSY Grund: Deutlicher Vorteil (${myEstimatedScore} vs ${opponentEstimatedScore})');
      return true;
    }

    // 2. Sehr niedrige Punkte (unter 15) - fast immer PAWSY
    if (myEstimatedScore <= 12 && knownCardsCount >= 3) {
      debugPrint('🐾 PAWSY Grund: Sehr niedrige Punkte ($myEstimatedScore)');
      return true;
    }

    // 3. Nach vielen Zügen (ab Zug 15) - aggressiver werden
    if (turnsPlayed >= 15 && myEstimatedScore < opponentEstimatedScore && knownCardsCount >= 2) {
      debugPrint('🐾 PAWSY Grund: Langes Spiel (Zug $turnsPlayed)');
      return true;
    }

    // 4. Moderate Punkte aber trotzdem besser als Gegner
    if (myEstimatedScore <= 18 && myEstimatedScore < opponentEstimatedScore - 2 && knownCardsCount >= 3) {
      debugPrint('🐾 PAWSY Grund: Moderate Punkte aber im Vorteil');
      return true;
    }

    // 5. Zufallsfaktor bei knappen Entscheidungen
    if (myEstimatedScore < opponentEstimatedScore &&
        myEstimatedScore <= 20 &&
        knownCardsCount >= 3 &&
        Random().nextDouble() < 0.25) { // 25% Chance
      debugPrint('🐾 PAWSY Grund: Zufallsfaktor bei knapper Führung');
      return true;
    }

    debugPrint('❌ Kein PAWSY: Score $myEstimatedScore vs $opponentEstimatedScore, bekannte Karten: $knownCardsCount');
    return false;
  }

  double _calculateMyEstimatedScore() {
    double totalScore = 0;
    int knownCount = 0;

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        totalScore += _getCardValue(knownCards[i]!);
        knownCount++;
      }
    }

    int unknownCount = _getActiveCardCount() - knownCount;
    if (unknownCount > 0) {
      double avgRemainingCardValue = _calculateAverageRemainingCardValue();
      // Optimistischere Schätzung für unbekannte Karten (20% besser)
      totalScore += unknownCount * (avgRemainingCardValue * 0.8);
    }

    return totalScore;
  }

  double _calculateOpponentEstimatedScore() {
    double baseEstimate = 6.5 * 4; // Standard-Durchschnitt

    if (playerRevealedCards.isNotEmpty) {
      double revealedAvg = playerRevealedCards.map(_getCardValue).reduce((a, b) => a + b) / playerRevealedCards.length;
      baseEstimate = revealedAvg * 4;
    }

    // Wenn viel Zeit vergangen ist, pessimistischere Schätzung für Gegner
    if (turnsPlayed >= 10) {
      baseEstimate *= 0.9; // Gegner wird besser mit der Zeit
    }

    return baseEstimate;
  }

  double _calculateAverageRemainingCardValue() {
    double totalValue = 0;
    int totalCards = 0;

    remainingCardCount.forEach((card, count) {
      totalValue += _getCardValue(card) * count;
      totalCards += count;
    });

    return totalCards > 0 ? totalValue / totalCards : 6.5;
  }

  bool _shouldDrawFromDiscardStrategic(String topCard) {
    double cardValue = _getCardValue(topCard);
    observeCard(topCard);

    if (cardValue <= 3) return true;

    if (cardValue <= 7) {
      double worstKnownValue = _getWorstKnownCardValue();
      return cardValue < worstKnownValue - 2;
    }

    return cardValue <= 8 && _getActiveCardCount() <= 2;
  }

  AIDecision _makeAdvancedCardDecision(String drawnCard) {
    double cardValue = _getCardValue(drawnCard);
    observeCard(drawnCard);

    int bestSwapIndex = _findBestSwapPosition(cardValue.toInt());

    if (bestSwapIndex != -1) {
      List<int> duplicateIndices = _findDuplicates(drawnCard);

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
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        double currentValue = _getCardValue(knownCards[i]!);
        double improvement = currentValue - newCardValue;

        if (improvement > bestImprovement) {
          bestImprovement = improvement;
          bestIndex = i;
        }
      }
    }

    return bestImprovement >= 2 ? bestIndex : -1;
  }

  List<int> _findDuplicates(String targetCard) {
    List<int> duplicates = [];

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] == targetCard) {
        duplicates.add(i);
      }
    }

    return duplicates;
  }

  double _getWorstKnownCardValue() {
    double worst = 0;

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        double value = _getCardValue(knownCards[i]!);
        if (value > worst) worst = value;
      }
    }

    return worst;
  }

  double _getCardValue(String card) {
    if (card == 'LEER') return 0;
    if (card == '0') return 0;
    if (card == '13') return 13;
    return double.tryParse(card) ?? 10;
  }

  int _getActiveCardCount() {
    return aiCards.where((card) => card != 'LEER').length;
  }

  void reset() {
    knownCards = [null, null, null, null];
    aiCards = ['?', '?', '?', '?'];
    seenCards.clear();
    playerRevealedCards.clear();
    turnsPlayed = 0; // Reset
    _initializeDeck();
  }
}

class AIDecision {
  final String action;
  final int? cardIndex;
  final List<int>? cardIndices;

  AIDecision._(this.action, {this.cardIndex, this.cardIndices});

  factory AIDecision.drawFromDeck() => AIDecision._('draw_deck');
  factory AIDecision.drawFromDiscard() => AIDecision._('draw_discard');
  factory AIDecision.swap(int index) => AIDecision._('swap', cardIndex: index);
  factory AIDecision.multiSwap(List<int> indices) => AIDecision._('multi_swap', cardIndices: indices);
  factory AIDecision.discard() => AIDecision._('discard');
  factory AIDecision.pawsy() => AIDecision._('pawsy');

  bool get isDrawFromDeck => action == 'draw_deck';
  bool get isDrawFromDiscard => action == 'draw_discard';
  bool get isSwap => action == 'swap';
  bool get isMultiSwap => action == 'multi_swap';
  bool get isDiscard => action == 'discard';
  bool get isPawsy => action == 'pawsy';
}