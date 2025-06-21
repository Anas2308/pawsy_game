// lib/services/card_service.dart
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../controllers/deck_controller.dart';
import '../utils/constants.dart';

class CardService {
  // =============================================================================
  // KARTEN ZIEHEN
  // =============================================================================

  /// Zieht eine Karte vom Deck für menschlichen Spieler
  static GameState drawCardFromDeck(GameState gameState) {
    if (!gameState.canDrawCard || !gameState.isHumanTurn) {
      return gameState;
    }

    int? card = DeckController.drawCard(gameState.deck);
    if (card == null) {
      return gameState;
    }

    return gameState.copyWith(
      drawnCard: GameCard(value: card, isVisible: true),
      showDrawnCard: true,
      hasDrawnCardThisTurn: true,
    );
  }

  /// Zieht eine Karte vom Ablagestapel für menschlichen Spieler
  static GameState drawCardFromDiscard(GameState gameState) {
    if (gameState.showDrawnCard ||
        gameState.isDrawingFromDiscard ||
        gameState.discardPile == null ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    return gameState.copyWith(
      drawnCard: GameCard(value: gameState.discardPile!.value, isVisible: true),
      isDrawingFromDiscard: true,
      hasDrawnCardThisTurn: true,
    );
  }

  /// Zieht eine Karte vom Deck für KI-Spieler
  static GameState aiDrawFromDeck(GameState gameState) {
    if (!gameState.canDrawCard || gameState.hasDrawnCardThisTurn) {
      return gameState;
    }

    int? card = DeckController.drawCard(gameState.deck);
    if (card == null) {
      return gameState;
    }

    return gameState.copyWith(
      drawnCard: GameCard(value: card, isVisible: true),
      hasDrawnCardThisTurn: true,
    );
  }

  /// Zieht eine Karte vom Ablagestapel für KI-Spieler
  static GameState aiDrawFromDiscard(GameState gameState) {
    if (gameState.discardPile == null || gameState.hasDrawnCardThisTurn) {
      return gameState;
    }

    return gameState.copyWith(
      drawnCard: GameCard(value: gameState.discardPile!.value, isVisible: true),
      hasDrawnCardThisTurn: true,
    );
  }

  /// Beendet das Ziehen vom Ablagestapel
  static GameState finishDrawingFromDiscard(GameState gameState) {
    return gameState.copyWith(showDrawnCard: true, isDrawingFromDiscard: false);
  }

  // =============================================================================
  // KARTEN ABLEGEN
  // =============================================================================

  /// Legt die gezogene Karte auf den Ablagestapel
  static GameState discardDrawnCard(GameState gameState) {
    if (gameState.drawnCard == null || !gameState.isHumanTurn) {
      return gameState;
    }

    bool wasDrawnFromDeck = !gameState.isDrawingFromDiscard;

    return gameState.copyWith(
      discardPile: gameState.drawnCard,
      drawnCard: null,
      showDrawnCard: false,
      hasDrawnCardThisTurn: false,
      canActivateAction: wasDrawnFromDeck && gameState.drawnCard!.isActionCard,
    );
  }

  /// KI legt die gezogene Karte ab
  static GameState aiDiscardCard(GameState gameState) {
    if (gameState.drawnCard == null) {
      return gameState;
    }

    return gameState.copyWith(
      discardPile: gameState.drawnCard,
      drawnCard: null,
      hasDrawnCardThisTurn: false,
    );
  }

  // =============================================================================
  // KARTEN TAUSCHEN
  // =============================================================================

  /// Tauscht die gezogene Karte mit einer Spielerkarte
  static GameState swapWithPlayerCard(GameState gameState, int cardIndex) {
    if (gameState.drawnCard == null ||
        cardIndex >= GameConstants.maxCardsPerPlayer ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    List<Player> updatedPlayers = List.from(gameState.players);
    Player humanPlayer = updatedPlayers[0];

    if (cardIndex >= humanPlayer.cards.length) {
      return gameState;
    }

    List<GameCard> updatedCards = List.from(humanPlayer.cards);
    GameCard oldCard = updatedCards[cardIndex];

    updatedCards[cardIndex] = gameState.drawnCard!.copyWith(isVisible: false);

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    return gameState.copyWith(
      players: updatedPlayers,
      discardPile: oldCard.copyWith(isVisible: true),
      drawnCard: null,
      showDrawnCard: false,
      hasDrawnCardThisTurn: false,
    );
  }

  /// KI tauscht eine Karte
  static GameState aiSwapCard(GameState gameState, int cardIndex) {
    if (gameState.drawnCard == null ||
        cardIndex >= GameConstants.maxCardsPerPlayer) {
      return gameState;
    }

    List<Player> updatedPlayers = List.from(gameState.players);
    Player aiPlayer = updatedPlayers[gameState.currentPlayerIndex];

    if (cardIndex >= aiPlayer.cards.length) {
      return gameState;
    }

    List<GameCard> updatedCards = List.from(aiPlayer.cards);
    GameCard oldCard = updatedCards[cardIndex];

    updatedCards[cardIndex] = gameState.drawnCard!.copyWith(isVisible: false);

    updatedPlayers[gameState.currentPlayerIndex] = aiPlayer.copyWith(
      cards: updatedCards,
    );

    return gameState.copyWith(
      players: updatedPlayers,
      discardPile: oldCard.copyWith(isVisible: true),
      drawnCard: null,
      hasDrawnCardThisTurn: false,
    );
  }

  // =============================================================================
  // KARTEN AUFDECKEN
  // =============================================================================

  /// Deckt eine Startkarte auf (Spielbeginn)
  static GameState lookAtStartCard(GameState gameState, int cardIndex) {
    if (!gameState.isLookingAtCards ||
        gameState.cardsLookedAt >= 2 ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    List<Player> updatedPlayers = List.from(gameState.players);
    Player humanPlayer = updatedPlayers[0];

    if (cardIndex >= humanPlayer.cards.length) {
      return gameState;
    }

    List<GameCard> updatedCards = List.from(humanPlayer.cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isVisible: true);

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    return gameState.copyWith(
      players: updatedPlayers,
      cardsLookedAt: gameState.cardsLookedAt + 1,
    );
  }

  /// Versteckt alle Spielerkarten (nach Startphase)
  static GameState hideAllPlayerCards(GameState gameState) {
    List<Player> updatedPlayers = List.from(gameState.players);

    for (int i = 0; i < updatedPlayers.length; i++) {
      Player player = updatedPlayers[i];
      List<GameCard> updatedCards = player.cards
          .map((card) => card.copyWith(isVisible: false))
          .toList();
      updatedPlayers[i] = player.copyWith(cards: updatedCards);
    }

    return gameState.copyWith(players: updatedPlayers);
  }

  /// Deckt eine Spielerkarte dauerhaft auf (Debug/Test)
  static GameState revealPlayerCard(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) {
    if (playerIndex >= gameState.players.length) {
      return gameState;
    }

    List<Player> updatedPlayers = List.from(gameState.players);
    Player player = updatedPlayers[playerIndex];

    if (cardIndex >= player.cards.length) {
      return gameState;
    }

    List<GameCard> updatedCards = List.from(player.cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isVisible: true);

    updatedPlayers[playerIndex] = player.copyWith(cards: updatedCards);

    return gameState.copyWith(players: updatedPlayers);
  }

  /// Deckt alle Karten des menschlichen Spielers auf (Debug)
  static GameState debugRevealHumanCards(GameState gameState) {
    if (gameState.players.isEmpty) {
      return gameState;
    }

    List<Player> updatedPlayers = List.from(gameState.players);
    Player humanPlayer = updatedPlayers[0];

    List<GameCard> updatedCards = humanPlayer.cards
        .map((card) => card.copyWith(isVisible: true))
        .toList();

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    return gameState.copyWith(players: updatedPlayers);
  }

  // =============================================================================
  // HILFSMETHODEN
  // =============================================================================

  /// Prüft ob eine Aktionskarte getauscht wurde (nicht aktivierbar)
  static bool isActionCardSwapped(GameCard swappedCard) {
    return swappedCard.isActionCard;
  }

  /// Prüft ob eine Aktionskarte direkt vom Deck abgelegt wurde (aktivierbar)
  static bool isActionCardDiscarded(
    GameCard discardedCard,
    bool wasDrawnFromDeck,
  ) {
    return discardedCard.isActionCard && wasDrawnFromDeck;
  }

  /// Gibt die Kartenverteilung für Debugging zurück
  static Map<String, dynamic> getGameStatistics(GameState gameState) {
    int totalCards = gameState.players.fold(
      0,
      (sum, player) => sum + player.cards.length,
    );

    return {
      'deckSize': gameState.deck.length,
      'totalPlayerCards': totalCards,
      'discardPile': gameState.discardPile?.value,
      'drawnCard': gameState.drawnCard?.value,
      'hasDrawnCard': gameState.hasDrawnCardThisTurn,
    };
  }

  /// Validiert den Spielzustand
  static bool validateGameState(GameState gameState) {
    // Prüfe ob alle Spieler die richtige Anzahl Karten haben
    for (Player player in gameState.players) {
      if (player.cards.length != GameConstants.maxCardsPerPlayer) {
        return false;
      }
    }

    // Prüfe Deck-Größe
    int expectedDeckSize =
        GameConstants.cardsInDeck -
        (gameState.players.length * GameConstants.maxCardsPerPlayer) -
        (gameState.discardPile != null ? 1 : 0) -
        (gameState.drawnCard != null ? 1 : 0);

    return gameState.deck.length == expectedDeckSize;
  }
}
