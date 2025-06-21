// lib/utils/helpers.dart
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';

class GameHelpers {
  // =============================================================================
  // GAME STATE HELPERS
  // =============================================================================

  /// Prüft ob das Spiel in einem gültigen Zustand ist
  static bool isValidGameState(GameState gameState) {
    // Mindestens 2 Spieler
    if (gameState.players.length < 2) return false;

    // Alle Spieler haben die richtige Anzahl Karten
    for (Player player in gameState.players) {
      if (player.cards.length != 4) return false;
    }

    // Aktueller Spieler Index ist gültig
    if (gameState.currentPlayerIndex >= gameState.players.length) return false;

    return true;
  }

  /// Gibt den Gewinner des Spiels zurück
  static Player? getWinner(GameState gameState) {
    if (!gameState.isGameOver) return null;

    Player? winner;
    int lowestScore = 999;

    for (Player player in gameState.players) {
      int score = calculatePlayerScore(player);
      if (score < lowestScore) {
        lowestScore = score;
        winner = player;
      }
    }

    return winner;
  }

  /// Berechnet die Punkte eines Spielers
  static int calculatePlayerScore(Player player) {
    return player.cards.fold(0, (sum, card) => sum + card.value);
  }

  /// Gibt die Spielstatistiken zurück
  static Map<String, dynamic> getGameStatistics(GameState gameState) {
    return {
      'totalCards': gameState.players.fold(
        0,
        (sum, player) => sum + player.cards.length,
      ),
      'deckSize': gameState.deck.length,
      'currentRound': getCurrentRound(gameState),
      'averageScore': getAverageScore(gameState),
      'highestScore': getHighestScore(gameState),
      'lowestScore': getLowestScore(gameState),
    };
  }

  // =============================================================================
  // PLAYER HELPERS
  // =============================================================================

  /// Gibt alle menschlichen Spieler zurück
  static List<Player> getHumanPlayers(GameState gameState) {
    return gameState.players.where((player) => player.isHuman).toList();
  }

  /// Gibt alle KI-Spieler zurück
  static List<Player> getAIPlayers(GameState gameState) {
    return gameState.players.where((player) => !player.isHuman).toList();
  }

  /// Gibt den Spieler mit dem niedrigsten Score zurück
  static Player? getPlayerWithLowestScore(GameState gameState) {
    if (gameState.players.isEmpty) return null;

    Player bestPlayer = gameState.players.first;
    int lowestScore = calculatePlayerScore(bestPlayer);

    for (Player player in gameState.players) {
      int score = calculatePlayerScore(player);
      if (score < lowestScore) {
        lowestScore = score;
        bestPlayer = player;
      }
    }

    return bestPlayer;
  }

  /// Gibt den Spieler mit dem höchsten Score zurück
  static Player? getPlayerWithHighestScore(GameState gameState) {
    if (gameState.players.isEmpty) return null;

    Player worstPlayer = gameState.players.first;
    int highestScore = calculatePlayerScore(worstPlayer);

    for (Player player in gameState.players) {
      int score = calculatePlayerScore(player);
      if (score > highestScore) {
        highestScore = score;
        worstPlayer = player;
      }
    }

    return worstPlayer;
  }

  // =============================================================================
  // CARD HELPERS
  // =============================================================================

  /// Gibt alle sichtbaren Karten eines Spielers zurück
  static List<GameCard> getVisibleCards(Player player) {
    return player.cards.where((card) => card.isVisible).toList();
  }

  /// Gibt alle verdeckten Karten eines Spielers zurück
  static List<GameCard> getHiddenCards(Player player) {
    return player.cards.where((card) => !card.isVisible).toList();
  }

  /// Prüft ob ein Spieler Aktionskarten hat
  static bool hasActionCards(Player player) {
    return player.cards.any((card) => card.isActionCard);
  }

  /// Gibt alle Aktionskarten eines Spielers zurück
  static List<GameCard> getActionCards(Player player) {
    return player.cards.where((card) => card.isActionCard).toList();
  }

  /// Gibt die beste sichtbare Karte eines Spielers zurück
  static GameCard? getBestVisibleCard(Player player) {
    List<GameCard> visibleCards = getVisibleCards(player);
    if (visibleCards.isEmpty) return null;

    GameCard bestCard = visibleCards.first;
    for (GameCard card in visibleCards) {
      if (card.value < bestCard.value) {
        bestCard = card;
      }
    }

    return bestCard;
  }

  /// Gibt die schlechteste sichtbare Karte eines Spielers zurück
  static GameCard? getWorstVisibleCard(Player player) {
    List<GameCard> visibleCards = getVisibleCards(player);
    if (visibleCards.isEmpty) return null;

    GameCard worstCard = visibleCards.first;
    for (GameCard card in visibleCards) {
      if (card.value > worstCard.value) {
        worstCard = card;
      }
    }

    return worstCard;
  }

  // =============================================================================
  // SCORING HELPERS
  // =============================================================================

  /// Berechnet den Durchschnittsscore aller Spieler
  static double getAverageScore(GameState gameState) {
    if (gameState.players.isEmpty) return 0.0;

    int totalScore = gameState.players.fold(
      0,
      (sum, player) => sum + calculatePlayerScore(player),
    );

    return totalScore / gameState.players.length;
  }

  /// Gibt den höchsten Score zurück
  static int getHighestScore(GameState gameState) {
    if (gameState.players.isEmpty) return 0;

    return gameState.players.fold(0, (max, player) {
      int score = calculatePlayerScore(player);
      return score > max ? score : max;
    });
  }

  /// Gibt den niedrigsten Score zurück
  static int getLowestScore(GameState gameState) {
    if (gameState.players.isEmpty) return 0;

    return gameState.players.fold(999, (min, player) {
      int score = calculatePlayerScore(player);
      return score < min ? score : min;
    });
  }

  // =============================================================================
  // TURN HELPERS
  // =============================================================================

  /// Berechnet die aktuelle Runde
  static int getCurrentRound(GameState gameState) {
    int totalCardsDealt = gameState.players.length * 4;
    int cardsUsed = 50 - gameState.deck.length - totalCardsDealt;
    if (gameState.discardPile != null) cardsUsed--;
    if (gameState.drawnCard != null) cardsUsed--;

    return (cardsUsed ~/ gameState.players.length) + 1;
  }

  /// Gibt den nächsten Spieler zurück
  static Player getNextPlayer(GameState gameState) {
    int nextIndex =
        (gameState.currentPlayerIndex + 1) % gameState.players.length;
    return gameState.players[nextIndex];
  }

  /// Gibt den vorherigen Spieler zurück
  static Player getPreviousPlayer(GameState gameState) {
    int prevIndex =
        (gameState.currentPlayerIndex - 1 + gameState.players.length) %
        gameState.players.length;
    return gameState.players[prevIndex];
  }

  // =============================================================================
  // DEBUG HELPERS
  // =============================================================================

  /// Erstellt einen Debug-String für den GameState
  static String debugGameState(GameState gameState) {
    StringBuffer buffer = StringBuffer();

    buffer.writeln('=== GAME STATE DEBUG ===');
    buffer.writeln('Phase: ${gameState.phase}');
    buffer.writeln('Current Player: ${gameState.currentPlayer.name}');
    buffer.writeln('Deck Size: ${gameState.deck.length}');
    buffer.writeln('Discard: ${gameState.discardPile?.value ?? 'None'}');
    buffer.writeln('Drawn Card: ${gameState.drawnCard?.value ?? 'None'}');
    buffer.writeln('Action Phase: ${gameState.actionPhase}');

    buffer.writeln('\n=== PLAYERS ===');
    for (int i = 0; i < gameState.players.length; i++) {
      Player player = gameState.players[i];
      buffer.writeln(
        '$i: ${player.name} (${calculatePlayerScore(player)} pts)',
      );

      for (int j = 0; j < player.cards.length; j++) {
        GameCard card = player.cards[j];
        String visibility = card.isVisible ? 'visible' : 'hidden';
        buffer.writeln('  Card $j: ${card.value} ($visibility)');
      }
    }

    return buffer.toString();
  }

  /// Validiert die Deck-Integrität
  static bool validateDeckIntegrity(GameState gameState) {
    Map<int, int> cardCounts = {};

    // Zähle Karten im Deck
    for (int card in gameState.deck) {
      cardCounts[card] = (cardCounts[card] ?? 0) + 1;
    }

    // Zähle Karten bei Spielern
    for (Player player in gameState.players) {
      for (GameCard card in player.cards) {
        cardCounts[card.value] = (cardCounts[card.value] ?? 0) + 1;
      }
    }

    // Zähle Ablagestapel und gezogene Karte
    if (gameState.discardPile != null) {
      cardCounts[gameState.discardPile!.value] =
          (cardCounts[gameState.discardPile!.value] ?? 0) + 1;
    }

    if (gameState.drawnCard != null) {
      cardCounts[gameState.drawnCard!.value] =
          (cardCounts[gameState.drawnCard!.value] ?? 0) + 1;
    }

    // Erwartete Kartenverteilung prüfen
    Map<int, int> expectedCounts = {
      0: 2, // 2x Null
      13: 2, // 2x Dreizehn
    };

    // 4x Karten 1-12
    for (int i = 1; i <= 12; i++) {
      expectedCounts[i] = 4;
    }

    // Vergleiche mit erwarteten Werten
    for (int card in expectedCounts.keys) {
      if (cardCounts[card] != expectedCounts[card]) {
        return false;
      }
    }

    return true;
  }
}
