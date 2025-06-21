// lib/controllers/action_controller.dart
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';

class ActionController {
  /// Startet eine Aktionskarte
  static GameState startActionCard(GameState gameState, int cardValue) {
    if (!gameState.currentPlayer.isHuman) {
      return gameState;
    }

    if (cardValue >= 6 && cardValue <= 7) {
      // SCOUT
      return gameState.copyWith(
        actionPhase: ActionCardPhase.scoutSelectCard,
        activeActionCard: cardValue,
      );
    } else if (cardValue >= 8 && cardValue <= 9) {
      // STALK
      return gameState.copyWith(
        actionPhase: ActionCardPhase.stalkSelectPlayer,
        activeActionCard: cardValue,
      );
    } else if (cardValue >= 10 && cardValue <= 11) {
      // SWITCH
      return gameState.copyWith(
        actionPhase: ActionCardPhase.switchSelectPlayer,
        activeActionCard: cardValue,
      );
    }

    return gameState;
  }

  /// Bricht eine Aktionskarte ab
  static GameState cancelActionCard(GameState gameState) {
    return gameState.copyWith(
      actionPhase: ActionCardPhase.none,
      activeActionCard: null,
      selectedPlayerIndex: null,
      selectedCardIndex: null,
      revealedPlayerIndex: null,
      revealedCardIndex: null,
      animationPhase: AnimationPhase.none,
      highlightedPlayerIndex: null,
      highlightedCardIndex: null,
      isAnimating: false,
    );
  }

  // =============================================================================
  // SCOUT AKTIONEN (6-7)
  // =============================================================================

  /// SCOUT: Spieler wählt eigene Karte zum Erkunden
  static GameState selectCardForScout(GameState gameState, int cardIndex) {
    if (gameState.actionPhase != ActionCardPhase.scoutSelectCard ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    Player humanPlayer = gameState.players[0];
    if (cardIndex >= humanPlayer.cards.length) {
      return gameState;
    }

    // Starte Highlight-Animation und temporäre Aufdeckung
    return gameState.copyWith(
      animationPhase: AnimationPhase.highlighting,
      highlightedPlayerIndex: 0,
      highlightedCardIndex: cardIndex,
      isAnimating: true,
      revealedPlayerIndex: 0,
      revealedCardIndex: cardIndex,
    );
  }

  /// SCOUT: Beendet die Scout-Aktion
  static GameState finishScoutAction(GameState gameState) {
    return gameState.copyWith(
      actionPhase: ActionCardPhase.none,
      activeActionCard: null,
      revealedPlayerIndex: null,
      revealedCardIndex: null,
      animationPhase: AnimationPhase.none,
      highlightedPlayerIndex: null,
      highlightedCardIndex: null,
      isAnimating: false,
    );
  }

  // =============================================================================
  // STALK AKTIONEN (8-9)
  // =============================================================================

  /// STALK: Spieler wählt Gegner
  static GameState selectPlayerForStalk(GameState gameState, int playerIndex) {
    if (gameState.actionPhase != ActionCardPhase.stalkSelectPlayer ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    if (playerIndex == 0 || playerIndex >= gameState.players.length) {
      return gameState;
    }

    return gameState.copyWith(
      actionPhase: ActionCardPhase.stalkSelectCard,
      selectedPlayerIndex: playerIndex,
    );
  }

  /// STALK: Spieler wählt Gegnerkarte zum Verfolgen
  static GameState selectCardForStalk(GameState gameState, int cardIndex) {
    if (gameState.actionPhase != ActionCardPhase.stalkSelectCard ||
        gameState.selectedPlayerIndex == null ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    Player targetPlayer = gameState.players[gameState.selectedPlayerIndex!];
    if (cardIndex >= targetPlayer.cards.length) {
      return gameState;
    }

    // Starte Highlight-Animation und temporäre Aufdeckung
    return gameState.copyWith(
      animationPhase: AnimationPhase.highlighting,
      highlightedPlayerIndex: gameState.selectedPlayerIndex,
      highlightedCardIndex: cardIndex,
      isAnimating: true,
      revealedPlayerIndex: gameState.selectedPlayerIndex,
      revealedCardIndex: cardIndex,
    );
  }

  /// STALK: Beendet die Stalk-Aktion
  static GameState finishStalkAction(GameState gameState) {
    return gameState.copyWith(
      actionPhase: ActionCardPhase.none,
      activeActionCard: null,
      selectedPlayerIndex: null,
      revealedPlayerIndex: null,
      revealedCardIndex: null,
      animationPhase: AnimationPhase.none,
      highlightedPlayerIndex: null,
      highlightedCardIndex: null,
      isAnimating: false,
    );
  }

  // =============================================================================
  // SWITCH AKTIONEN (10-11)
  // =============================================================================

  /// SWITCH: Spieler wählt Gegner
  static GameState selectPlayerForSwitch(GameState gameState, int playerIndex) {
    if (gameState.actionPhase != ActionCardPhase.switchSelectPlayer ||
        playerIndex == 0 ||
        playerIndex >= gameState.players.length ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    return gameState.copyWith(
      actionPhase: ActionCardPhase.switchSelectOwnCard,
      selectedPlayerIndex: playerIndex,
    );
  }

  /// SWITCH: Spieler wählt eigene Karte
  static GameState selectOwnCardForSwitch(GameState gameState, int cardIndex) {
    if (gameState.actionPhase != ActionCardPhase.switchSelectOwnCard ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    Player humanPlayer = gameState.players[0];
    if (cardIndex >= humanPlayer.cards.length) {
      return gameState;
    }

    return gameState.copyWith(
      actionPhase: ActionCardPhase.switchSelectOpponentCard,
      selectedCardIndex: cardIndex,
    );
  }

  /// SWITCH: Spieler wählt Gegnerkarte
  static GameState selectOpponentCardForSwitch(
    GameState gameState,
    int cardIndex,
  ) {
    if (gameState.actionPhase != ActionCardPhase.switchSelectOpponentCard ||
        gameState.selectedPlayerIndex == null ||
        gameState.selectedCardIndex == null ||
        !gameState.isHumanTurn) {
      return gameState;
    }

    Player targetPlayer = gameState.players[gameState.selectedPlayerIndex!];
    if (cardIndex >= targetPlayer.cards.length) {
      return gameState;
    }

    // Starte Switch-Animation
    return gameState.copyWith(
      animationPhase: AnimationPhase.switching,
      switchingCards: [
        (0, gameState.selectedCardIndex!), // Human Player Karte
        (gameState.selectedPlayerIndex!, cardIndex), // Opponent Karte
      ],
      isAnimating: true,
    );
  }

  /// SWITCH: Führt den Kartentausch durch
  static GameState finishSwitchAction(
    GameState gameState,
    int opponentCardIndex,
  ) {
    if (gameState.selectedPlayerIndex == null ||
        gameState.selectedCardIndex == null) {
      return gameState;
    }

    // Führe den Kartentausch durch
    List<Player> updatedPlayers = List.from(gameState.players);

    Player humanPlayer = updatedPlayers[0];
    Player opponentPlayer = updatedPlayers[gameState.selectedPlayerIndex!];

    List<GameCard> humanCards = List.from(humanPlayer.cards);
    List<GameCard> opponentCards = List.from(opponentPlayer.cards);

    // Tausche die Karten
    GameCard humanCard = humanCards[gameState.selectedCardIndex!];
    GameCard opponentCard = opponentCards[opponentCardIndex];

    humanCards[gameState.selectedCardIndex!] = opponentCard.copyWith(
      isVisible: false,
    );
    opponentCards[opponentCardIndex] = humanCard.copyWith(isVisible: false);

    updatedPlayers[0] = humanPlayer.copyWith(cards: humanCards);
    updatedPlayers[gameState.selectedPlayerIndex!] = opponentPlayer.copyWith(
      cards: opponentCards,
    );

    return gameState.copyWith(
      players: updatedPlayers,
      actionPhase: ActionCardPhase.none,
      activeActionCard: null,
      selectedPlayerIndex: null,
      selectedCardIndex: null,
      animationPhase: AnimationPhase.none,
      switchingCards: [],
      isAnimating: false,
    );
  }

  // =============================================================================
  // HILFSMETHODEN
  // =============================================================================

  /// Prüft ob eine Aktionskarte aktiviert werden kann
  static bool canActivateActionCard(GameState gameState, int cardValue) {
    return gameState.currentPlayer.isHuman &&
        gameState.actionPhase == ActionCardPhase.none &&
        cardValue >= 6 &&
        cardValue <= 11;
  }

  /// Gibt die Beschreibung einer Aktionskarte zurück
  static String getActionDescription(int cardValue) {
    if (cardValue >= 6 && cardValue <= 7) {
      return "SCOUT: Erkunde eine eigene Karte";
    } else if (cardValue >= 8 && cardValue <= 9) {
      return "STALK: Verfolge eine Gegnerkarte";
    } else if (cardValue >= 10 && cardValue <= 11) {
      return "SWITCH: Wechsle Karten mit Gegner";
    }
    return "";
  }
}
