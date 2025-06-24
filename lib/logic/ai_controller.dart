import 'dart:math';

class AIController {
  static const List<String> allCards = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13'
  ];

  // KI "weiß" welche ihrer Karten sie gesehen hat
  List<String?> knownCards = [null, null, null, null];
  List<String> aiCards = ['?', '?', '?', '?'];

  void setInitialCards(List<String> cards) {
    aiCards = List.from(cards);
    // KI "schaut" sich 2 zufällige Karten an
    final random = Random();
    final indices = [0, 1, 2, 3]..shuffle(random);
    knownCards[indices[0]] = cards[indices[0]];
    knownCards[indices[1]] = cards[indices[1]];
  }

  void updateCard(int index, String newCard) {
    aiCards[index] = newCard;
    knownCards[index] = newCard; // KI weiß was sie getauscht hat
  }

  void setCardEmpty(int index) {
    aiCards[index] = 'LEER';
    knownCards[index] = 'LEER';
  }

  AIDecision makeDecision({
    required String? drawnCard,
    required String topDiscardCard,
    required bool canDrawFromDeck,
    required bool canDrawFromDiscard,
    required bool canCallPawsy,
  }) {

    // 1. PAWSY-Entscheidung (nur wenn keine Karte gezogen)
    if (drawnCard == null && canCallPawsy) {
      if (_shouldCallPawsy()) {
        return AIDecision.pawsy();
      }
    }

    // 2. Karte ziehen
    if (drawnCard == null) {
      if (_shouldDrawFromDiscard(topDiscardCard)) {
        return AIDecision.drawFromDiscard();
      } else {
        return AIDecision.drawFromDeck();
      }
    }

    // 3. Mit gezogener Karte entscheiden
    return _decideWhatToDoWithCard(drawnCard);
  }

  bool _shouldCallPawsy() {
    // Schätze Punktzahl basierend auf bekannten Karten
    int estimatedScore = 0;
    int knownCardsCount = 0;

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        estimatedScore += _getCardValue(knownCards[i]!);
        knownCardsCount++;
      }
    }

    // Wenn weniger als 2 Karten bekannt → zu riskant
    if (knownCardsCount < 2) return false;

    // Hochrechnung auf alle Karten (konservativ)
    double avgPerKnownCard = estimatedScore / knownCardsCount;
    double estimatedTotal = avgPerKnownCard * _getActiveCardCount();

    // PAWSY nur bei sehr niedrigen geschätzten Punkten
    return estimatedTotal <= 15 && Random().nextBool(); // 50% Chance
  }

  bool _shouldDrawFromDiscard(String topCard) {
    // Ziehe vom Discard wenn Karte nützlich ist
    int cardValue = _getCardValue(topCard);

    // Niedrige Karten (0-6) sind immer gut
    if (cardValue <= 6) return true;

    // Hohe Karten nur wenn wir vermutlich schlechtere haben
    return Random().nextDouble() < 0.3; // 30% Chance
  }

  AIDecision _decideWhatToDoWithCard(String drawnCard) {
    int cardValue = _getCardValue(drawnCard);

    // Sehr niedrige Karten (0-4) fast immer behalten
    if (cardValue <= 4) {
      int bestIndex = _findWorstKnownCardIndex();
      if (bestIndex != -1) {
        return AIDecision.swap(bestIndex);
      }
    }

    // Mittlere Karten (5-8) manchmal behalten
    if (cardValue <= 8 && Random().nextDouble() < 0.6) {
      int bestIndex = _findWorstKnownCardIndex();
      if (bestIndex != -1) {
        return AIDecision.swap(bestIndex);
      }
    }

    // Hohe Karten meist ablegen
    return AIDecision.discard();
  }

  int _findWorstKnownCardIndex() {
    int worstIndex = -1;
    int worstValue = -1;

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        int value = _getCardValue(knownCards[i]!);
        if (value > worstValue) {
          worstValue = value;
          worstIndex = i;
        }
      }
    }

    return worstIndex;
  }

  int _getCardValue(String card) {
    if (card == 'LEER') return 0;
    if (card == '0') return 0;
    if (card == '13') return 13;
    return int.tryParse(card) ?? 10;
  }

  int _getActiveCardCount() {
    return aiCards.where((card) => card != 'LEER').length;
  }

  void reset() {
    knownCards = [null, null, null, null];
    aiCards = ['?', '?', '?', '?'];
  }
}

class AIDecision {
  final String action; // 'draw_deck', 'draw_discard', 'swap', 'discard', 'pawsy'
  final int? cardIndex;

  AIDecision._(this.action, {this.cardIndex});

  factory AIDecision.drawFromDeck() => AIDecision._('draw_deck');
  factory AIDecision.drawFromDiscard() => AIDecision._('draw_discard');
  factory AIDecision.swap(int index) => AIDecision._('swap', cardIndex: index);
  factory AIDecision.discard() => AIDecision._('discard');
  factory AIDecision.pawsy() => AIDecision._('pawsy');

  bool get isDrawFromDeck => action == 'draw_deck';
  bool get isDrawFromDiscard => action == 'draw_discard';
  bool get isSwap => action == 'swap';
  bool get isDiscard => action == 'discard';
  bool get isPawsy => action == 'pawsy';
}