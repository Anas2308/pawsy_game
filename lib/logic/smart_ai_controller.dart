import 'dart:math';

class SmartAIController {
  // KI verfolgt Wahrscheinlichkeiten und Statistiken
  List<String?> knownCards = [null, null, null, null];
  List<String> aiCards = ['?', '?', '?', '?'];
  List<String> seenCards = []; // Alle gesehenen Karten
  Map<String, int> remainingCardCount = {}; // Verbleibende Karten im Deck
  List<String> playerRevealedCards = []; // Was vom Gegner gesehen wurde

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
    // KI merkt sich ihre Startkarten
    final random = Random();
    final indices = [0, 1, 2, 3]..shuffle(random);
    knownCards[indices[0]] = cards[indices[0]];
    knownCards[indices[1]] = cards[indices[1]];

    // Verfolge bekannte Karten
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

    // 1. Hochintelligente PAWSY-Entscheidung
    if (drawnCard == null && canCallPawsy) {
      if (_shouldCallPawsyStrategic()) {
        return AIDecision.pawsy();
      }
    }

    // 2. Strategische Kartenziehung
    if (drawnCard == null) {
      if (_shouldDrawFromDiscardStrategic(topDiscardCard)) {
        return AIDecision.drawFromDiscard();
      } else {
        return AIDecision.drawFromDeck();
      }
    }

    // 3. Fortgeschrittene Entscheidung für gezogene Karte
    return _makeAdvancedCardDecision(drawnCard);
  }

  bool _shouldCallPawsyStrategic() {
    // Berechne exakte Punktzahl basierend auf allem was KI weiß
    double myEstimatedScore = _calculateMyEstimatedScore();
    double opponentEstimatedScore = _calculateOpponentEstimatedScore();

    print('🧠 KI Analysis: Meine Punkte ≈ $myEstimatedScore, Gegner ≈ $opponentEstimatedScore');

    // PAWSY nur wenn:
    // 1. Meine Punkte wahrscheinlich niedrig (< 20)
    // 2. Ich wahrscheinlich besser als Gegner
    // 3. Genug Karten bekannt für Sicherheit
    int knownCardsCount = knownCards.where((c) => c != null && c != 'LEER').length;

    return myEstimatedScore < 20 &&
        myEstimatedScore < opponentEstimatedScore - 3 &&
        knownCardsCount >= 3;
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

    // Für unbekannte Karten: Verwende Wahrscheinlichkeits-basierte Schätzung
    int unknownCount = _getActiveCardCount() - knownCount;
    if (unknownCount > 0) {
      double avgRemainingCardValue = _calculateAverageRemainingCardValue();
      totalScore += unknownCount * avgRemainingCardValue;
    }

    return totalScore;
  }

  double _calculateOpponentEstimatedScore() {
    // Schätze Gegnerpunkte basierend auf:
    // 1. Gesehene Karten bei Strafen
    // 2. Durchschnittswerte
    // 3. Spielverhalten

    double baseEstimate = 6.5 * 4; // Durchschnittskarte * 4 Karten

    // Adjustiere basierend auf gesehenen Gegnerkarten
    if (playerRevealedCards.isNotEmpty) {
      double revealedAvg = playerRevealedCards.map(_getCardValue).reduce((a, b) => a + b) / playerRevealedCards.length;
      baseEstimate = revealedAvg * 4; // Hochrechnung
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
    int cardValue = _getCardValue(topCard);
    observeCard(topCard);

    // Sehr niedrige Karten (0-3) immer nehmen
    if (cardValue <= 3) return true;

    // Mittlere Karten nur wenn sie besser sind als geschätzte eigene schlechteste
    if (cardValue <= 7) {
      int worstKnownValue = _getWorstKnownCardValue();
      return cardValue < worstKnownValue - 2;
    }

    // Hohe Karten nur in Notfällen
    return cardValue <= 8 && _getActiveCardCount() <= 2;
  }

  AIDecision _makeAdvancedCardDecision(String drawnCard) {
    int cardValue = _getCardValue(drawnCard);
    observeCard(drawnCard);

    // Finde beste Tausch-Position basierend auf Strategie
    int bestSwapIndex = _findBestSwapPosition(cardValue);

    if (bestSwapIndex != -1) {
      // Erweiterte Logik: Prüfe Duett/Triplett Möglichkeiten
      List<int> duplicateIndices = _findDuplicates(drawnCard);

      if (duplicateIndices.length >= 1 && cardValue <= 6) {
        // Versuche Duett/Triplett wenn Karte gut ist
        return AIDecision.multiSwap([bestSwapIndex, ...duplicateIndices]);
      }

      return AIDecision.swap(bestSwapIndex);
    }

    // Ablegen wenn Karte nicht nützlich
    return AIDecision.discard();
  }

  int _findBestSwapPosition(int newCardValue) {
    int bestIndex = -1;
    double bestImprovement = 0; // double statt int

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        double currentValue = _getCardValue(knownCards[i]!); // double
        double improvement = currentValue - newCardValue; // double

        if (improvement > bestImprovement) {
          bestImprovement = improvement;
          bestIndex = i;
        }
      }
    }

    return bestImprovement >= 2 ? bestIndex : -1;
  }

  int _getWorstKnownCardValue() {
    double worst = 0; // double statt int

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        double value = _getCardValue(knownCards[i]!);
        if (value > worst) worst = value;
      }
    }

    return worst.toInt(); // zu int konvertieren
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

  int _getWorstKnownCardValue() {
    int worst = 0;

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        int value = _getCardValue(knownCards[i]!);
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
    _initializeDeck();
  }
}

class AIDecision {
  final String action;
  final int? cardIndex;
  final List<int>? cardIndices; // Für Multi-Swaps

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