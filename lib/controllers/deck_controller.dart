// lib/controllers/deck_controller.dart
import 'dart:math';
import '../utils/constants.dart';

class DeckController {
  static final Random _random = Random();

  /// Erstellt ein komplettes CABO-Deck
  static List<int> createCaboDeck() {
    List<int> deck = [];

    // 2x Null-Karten und 2x Dreizehn-Karten
    deck.addAll([0, 0, 13, 13]);

    // 4x Karten 1-12
    for (int cardValue = 1; cardValue <= 12; cardValue++) {
      for (int count = 0; count < 4; count++) {
        deck.add(cardValue);
      }
    }

    shuffleDeck(deck);
    return deck;
  }

  /// Mischt das Deck
  static void shuffleDeck(List<int> deck) {
    deck.shuffle(_random);
  }

  /// Zieht eine Karte vom Deck
  static int? drawCard(List<int> deck) {
    if (deck.isEmpty) return null;
    return deck.removeAt(0);
  }

  /// Prüft ob genug Karten für das Spiel vorhanden sind
  static bool hasEnoughCards(List<int> deck, int playerCount) {
    return deck.length >= (playerCount * GameConstants.maxCardsPerPlayer + 1);
  }

  /// Erstellt Deck-Statistiken für Debugging
  static Map<int, int> getDeckStatistics(List<int> deck) {
    Map<int, int> cardCounts = {};
    for (int card in deck) {
      cardCounts[card] = (cardCounts[card] ?? 0) + 1;
    }
    return cardCounts;
  }

  /// Gibt Deck-Statistiken als String zurück
  static String getDeckStatisticsString(List<int> deck) {
    Map<int, int> cardCounts = getDeckStatistics(deck);
    List<String> stats = [];

    for (int i = 0; i <= 13; i++) {
      if (cardCounts.containsKey(i)) {
        stats.add('$i:${cardCounts[i]}x');
      }
    }

    return stats.join(', ');
  }

  /// Validiert die Deck-Zusammensetzung
  static bool validateDeck(List<int> deck) {
    Map<int, int> counts = getDeckStatistics(deck);

    // Prüfe spezielle Karten
    if (counts[0] != 2) return false; // 2x Null
    if (counts[13] != 2) return false; // 2x Dreizehn

    // Prüfe normale Karten
    for (int i = 1; i <= 12; i++) {
      if (counts[i] != 4) return false; // 4x je Karte
    }

    return deck.length == GameConstants.cardsInDeck;
  }
}
