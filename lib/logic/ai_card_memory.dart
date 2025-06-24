import 'dart:math';

class AICardMemory {
  List<String?> knownCards = [null, null, null, null];
  List<String> aiCards = ['?', '?', '?', '?'];
  List<String> seenCards = [];
  Map<String, int> remainingCardCount = {};
  List<String> playerRevealedCards = [];

  AICardMemory() {
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

  int getKnownCardsCount() {
    return knownCards.where((c) => c != null && c != 'LEER').length;
  }

  int getActiveCardCount() {
    return aiCards.where((card) => card != 'LEER').length;
  }

  double calculateAverageRemainingCardValue() {
    double totalValue = 0;
    int totalCards = 0;

    remainingCardCount.forEach((card, count) {
      totalValue += getCardValue(card) * count;
      totalCards += count;
    });

    return totalCards > 0 ? totalValue / totalCards : 6.5;
  }

  double getWorstKnownCardValue() {
    double worst = 0;

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] != null && knownCards[i] != 'LEER') {
        double value = getCardValue(knownCards[i]!);
        if (value > worst) worst = value;
      }
    }

    return worst;
  }

  List<int> findDuplicates(String targetCard) {
    List<int> duplicates = [];

    for (int i = 0; i < 4; i++) {
      if (knownCards[i] == targetCard) {
        duplicates.add(i);
      }
    }

    return duplicates;
  }

  double getCardValue(String card) {
    if (card == 'LEER') return 0;
    if (card == '0') return 0;
    if (card == '13') return 13;
    return double.tryParse(card) ?? 10;
  }

  void reset() {
    knownCards = [null, null, null, null];
    aiCards = ['?', '?', '?', '?'];
    seenCards.clear();
    playerRevealedCards.clear();
    _initializeDeck();
  }
}