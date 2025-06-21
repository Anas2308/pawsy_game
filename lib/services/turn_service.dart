// lib/services/turn_service.dart
import '../models/game_state.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import '../controllers/ai_controller.dart';

class TurnService {
  // =============================================================================
  // SPIELZUG MANAGEMENT
  // =============================================================================

  /// Startet die Spielphase nach dem Kartenausteilen
  static GameState startPlayingPhase(GameState gameState) {
    return gameState.copyWith(
      phase: GamePhase.playing,
      hasDrawnCardThisTurn: false,
    );
  }

  /// Wechselt zum nächsten Spieler
  static GameState nextPlayerTurn(GameState gameState) {
    int nextPlayerIndex =
        (gameState.currentPlayerIndex + 1) % gameState.playerCount;

    return gameState.copyWith(
      currentPlayerIndex: nextPlayerIndex,
      hasDrawnCardThisTurn: false,
    );
  }

  /// Startet einen KI-Zug
  static Future<GameState> startAITurn(GameState gameState) async {
    if (gameState.currentPlayer.isHuman || gameState.hasDrawnCardThisTurn) {
      return gameState;
    }

    // Kurze Pause für realistische KI-Überlegung
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!gameState.isPlaying || gameState.hasDrawnCardThisTurn) {
      return gameState;
    }

    AIDecision decision = AIController.makeDecision(gameState);
    return _executeAIDecision(gameState, decision);
  }

  /// Führt eine KI-Entscheidung aus
  static GameState _executeAIDecision(
    GameState gameState,
    AIDecision decision,
  ) {
    switch (decision.action) {
      case AIAction.callPawsy:
        return callPawsy(gameState);

      case AIAction.drawFromDeck:
        return _aiDrawFromDeck(gameState);

      case AIAction.drawFromDiscard:
        return _aiDrawFromDiscard(gameState);

      default:
        return gameState;
    }
  }

  /// KI zieht vom Deck
  static GameState _aiDrawFromDeck(GameState gameState) {
    // Diese Logik wird an CardService delegiert
    // Hier nur die KI-spezifische Timing-Logik
    return gameState.copyWith(
      // Markierung dass KI-Zug läuft
      hasDrawnCardThisTurn: true,
    );
  }

  /// KI zieht vom Ablagestapel
  static GameState _aiDrawFromDiscard(GameState gameState) {
    // Diese Logik wird an CardService delegiert
    // Hier nur die KI-spezifische Timing-Logik
    return gameState.copyWith(hasDrawnCardThisTurn: true);
  }

  // =============================================================================
  // SPIEL BEENDEN
  // =============================================================================

  /// Spieler ruft PAWSY
  static GameState callPawsy(GameState gameState) {
    if (!gameState.canCallPawsy) {
      return gameState;
    }

    return gameState.copyWith(phase: GamePhase.gameOver);
  }

  /// Berechnet die Endpunktzahl
  static Map<String, int> calculateFinalScores(GameState gameState) {
    Map<String, int> scores = {};

    for (Player player in gameState.players) {
      scores[player.name] = player.totalScore;
    }

    return scores;
  }

  /// Ermittelt den Gewinner
  static Player? getWinner(GameState gameState) {
    if (!gameState.isGameOver) return null;

    Player? winner;
    int lowestScore = 999;

    for (Player player in gameState.players) {
      if (player.totalScore < lowestScore) {
        lowestScore = player.totalScore;
        winner = player;
      }
    }

    return winner;
  }

  // =============================================================================
  // SPIELZUSTAND VALIDIERUNG
  // =============================================================================

  /// Prüft ob ein Spieler an der Reihe ist
  static bool isPlayerTurn(GameState gameState, int playerIndex) {
    return gameState.currentPlayerIndex == playerIndex && gameState.isPlaying;
  }

  /// Prüft ob der menschliche Spieler dran ist
  static bool isHumanTurn(GameState gameState) {
    return gameState.currentPlayer.isHuman && gameState.isPlaying;
  }

  /// Prüft ob ein KI-Spieler dran ist
  static bool isAITurn(GameState gameState) {
    return !gameState.currentPlayer.isHuman && gameState.isPlaying;
  }

  /// Prüft ob Karten gezogen werden können
  static bool canDrawCards(GameState gameState) {
    return gameState.isPlaying &&
        !gameState.showDrawnCard &&
        !gameState.isDrawingFromDiscard &&
        gameState.actionPhase == ActionCardPhase.none;
  }

  /// Prüft ob PAWSY gerufen werden kann
  static bool canCallPawsy(GameState gameState) {
    return gameState.isPlaying &&
        !gameState.hasDrawnCardThisTurn &&
        gameState.actionPhase == ActionCardPhase.none;
  }

  // =============================================================================
  // TURN TIMER & AUTOMATION
  // =============================================================================

  /// Automatischer Zug nach Timeout (optional für Zukunft)
  static Future<GameState> handleTurnTimeout(GameState gameState) async {
    if (gameState.currentPlayer.isHuman) {
      // Menschlicher Spieler: Automatisch eine Karte ziehen
      return gameState.copyWith(
        // Könnte später implementiert werden
      );
    }

    // KI-Spieler: Normaler Zug
    return startAITurn(gameState);
  }

  /// Überspringt den aktuellen Spieler (Debug)
  static GameState skipCurrentPlayer(GameState gameState) {
    return nextPlayerTurn(gameState);
  }

  // =============================================================================
  // TURN STATISTICS
  // =============================================================================

  /// Zählt die Anzahl der gespielten Runden
  static int getCurrentRound(GameState gameState) {
    // Einfache Berechnung basierend auf Deck-Größe
    int cardsDealt = gameState.players.length * GameConstants.maxCardsPerPlayer;
    int cardsPlayed =
        GameConstants.cardsInDeck - gameState.deck.length - cardsDealt;

    if (gameState.discardPile != null) cardsPlayed--;
    if (gameState.drawnCard != null) cardsPlayed--;

    return (cardsPlayed ~/ gameState.players.length) + 1;
  }

  /// Berechnet die durchschnittliche Zugzeit
  static Duration getAverageTurnTime() {
    // Placeholder für spätere Implementierung
    return const Duration(seconds: 30);
  }

  /// Gibt Turn-Statistiken zurück
  static Map<String, dynamic> getTurnStatistics(GameState gameState) {
    return {
      'currentPlayer': gameState.currentPlayer.name,
      'currentPlayerIndex': gameState.currentPlayerIndex,
      'round': getCurrentRound(gameState),
      'hasDrawnCard': gameState.hasDrawnCardThisTurn,
      'canCallPawsy': canCallPawsy(gameState),
      'canDrawCards': canDrawCards(gameState),
      'isHumanTurn': isHumanTurn(gameState),
      'gamePhase': gameState.phase.toString(),
    };
  }

  // =============================================================================
  // GAME FLOW HELPERS
  // =============================================================================

  /// Startet ein neues Spiel
  static GameState initializeNewGame(List<Player> players, List<int> deck) {
    return GameState(
      players: players,
      deck: deck,
      phase: GamePhase.dealing,
      currentPlayerIndex: 0,
      currentDealingCard: 0,
      dealingToPlayerIndex: 0,
    );
  }

  /// Bereitet das Spiel für die nächste Runde vor
  static GameState prepareNextRound(GameState gameState) {
    // Für Multi-Round Spiele (später)
    return gameState.copyWith(
      phase: GamePhase.dealing,
      currentPlayerIndex: 0,
      hasDrawnCardThisTurn: false,
    );
  }

  /// Reset für Neustart
  static GameState resetGame(GameState gameState) {
    return const GameState(players: [], deck: [], phase: GamePhase.dealing);
  }
}
