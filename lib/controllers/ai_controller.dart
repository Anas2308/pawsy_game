// lib/controllers/ai_controller.dart
import 'dart:math';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';

class AIController {
  static final Random _random = Random();

  /// Führt einen KI-Zug aus
  static AIDecision makeDecision(GameState gameState) {
    Player aiPlayer = gameState.currentPlayer;

    // 1. Soll PAWSY gerufen werden?
    if (_shouldCallPawsy(aiPlayer, gameState)) {
      return AIDecision.callPawsy();
    }

    // 2. Soll vom Ablagestapel gezogen werden?
    if (_shouldDrawFromDiscard(gameState)) {
      return AIDecision.drawFromDiscard();
    }

    // 3. Vom Deck ziehen
    return AIDecision.drawFromDeck();
  }

  /// Entscheidet was mit der gezogenen Karte passiert
  static AIDecision makeDiscardDecision(GameState gameState) {
    Player aiPlayer = gameState.currentPlayer;
    GameCard drawnCard = gameState.drawnCard!;

    // Finde die schlechteste Karte zum Tauschen
    int worstCardIndex = _findWorstCardIndex(aiPlayer, drawnCard);

    if (worstCardIndex != -1) {
      return AIDecision.swapCard(worstCardIndex);
    }

    // Karte ablegen wenn kein guter Tausch möglich
    return AIDecision.discardCard();
  }

  /// Prüft ob KI PAWSY rufen sollte
  static bool _shouldCallPawsy(Player aiPlayer, GameState gameState) {
    if (!gameState.canCallPawsy) return false;

    // Einfache Strategie: PAWSY wenn geschätzte Punkte niedrig sind
    int estimatedScore = _estimatePlayerScore(aiPlayer);

    // Rufe PAWSY wenn Punkte unter 15 (aggressiv) oder unter 10 (konservativ)
    return estimatedScore <=
        (10 + _random.nextInt(10)); // 10-20 Punkte Schwelle
  }

  /// Prüft ob vom Ablagestapel gezogen werden sollte
  static bool _shouldDrawFromDiscard(GameState gameState) {
    if (gameState.discardPile == null) return false;

    GameCard discardCard = gameState.discardPile!;
    Player aiPlayer = gameState.currentPlayer;

    // Ziehe vom Ablagestapel wenn:
    // 1. Die Karte sehr gut ist (0-4)
    if (discardCard.value <= 4) return true;

    // 2. Es eine nützliche Aktionskarte ist (manchmal)
    if (discardCard.isActionCard && _random.nextBool()) return true;

    // 3. Wir haben sehr schlechte Karten und brauchen jeden Vorteil
    int estimatedScore = _estimatePlayerScore(aiPlayer);
    if (estimatedScore > 25 && discardCard.value < 8) return true;

    return false;
  }

  /// Findet die schlechteste Karte zum Tauschen
  static int _findWorstCardIndex(Player aiPlayer, GameCard drawnCard) {
    int worstIndex = -1;
    int worstValue = drawnCard.value;

    for (int i = 0; i < aiPlayer.cards.length; i++) {
      GameCard card = aiPlayer.cards[i];

      // Geschätzte Kartenqualität (unbekannte Karten = durchschnittlich 7)
      int estimatedValue = card.isVisible ? card.value : 7;

      // Tausche wenn die neue Karte besser ist
      if (estimatedValue > worstValue) {
        worstValue = estimatedValue;
        worstIndex = i;
      }
    }

    return worstIndex;
  }

  /// Schätzt die Gesamtpunktzahl eines Spielers
  static int _estimatePlayerScore(Player aiPlayer) {
    int totalScore = 0;

    for (GameCard card in aiPlayer.cards) {
      if (card.isVisible) {
        totalScore += card.value;
      } else {
        // Unbekannte Karten = Durchschnittswert 7
        totalScore += 7;
      }
    }

    return totalScore;
  }

  /// Führt Aktionskarten-Aktionen aus
  static AIDecision handleActionCard(GameState gameState, int cardValue) {
    switch (cardValue) {
      case 6:
      case 7:
        // PEEK: Schaue eigene Karte an
        return AIDecision.peekOwnCard(
          _selectRandomHiddenCard(gameState.currentPlayer),
        );

      case 8:
      case 9:
        // SPY: Schaue Gegnerkarte an
        int opponentIndex = _selectRandomOpponent(gameState);
        int cardIndex = _selectRandomHiddenCard(
          gameState.players[opponentIndex],
        );
        return AIDecision.spyOpponentCard(opponentIndex, cardIndex);

      case 10:
      case 11:
        // SWAP: Tausche Karten mit Gegner
        int opponentIndex = _selectRandomOpponent(gameState);
        int ownCardIndex = _random.nextInt(
          gameState.currentPlayer.cards.length,
        );
        int opponentCardIndex = _random.nextInt(
          gameState.players[opponentIndex].cards.length,
        );
        return AIDecision.swapWithOpponent(
          opponentIndex,
          ownCardIndex,
          opponentCardIndex,
        );

      case 12:
        // WILD: Freie Wahl der Aktion
        List<AIDecision> wildActions = [
          AIDecision.peekOwnCard(
            _selectRandomHiddenCard(gameState.currentPlayer),
          ),
          AIDecision.spyOpponentCard(_selectRandomOpponent(gameState), 0),
        ];
        return wildActions[_random.nextInt(wildActions.length)];

      default:
        return AIDecision.doNothing();
    }
  }

  /// Wählt zufälligen Gegner aus
  static int _selectRandomOpponent(GameState gameState) {
    List<int> opponents = [];
    for (int i = 0; i < gameState.players.length; i++) {
      if (i != gameState.currentPlayerIndex) {
        opponents.add(i);
      }
    }
    return opponents[_random.nextInt(opponents.length)];
  }

  /// Wählt zufällige verdeckte Karte
  static int _selectRandomHiddenCard(Player player) {
    List<int> hiddenCards = [];
    for (int i = 0; i < player.cards.length; i++) {
      if (!player.cards[i].isVisible) {
        hiddenCards.add(i);
      }
    }

    if (hiddenCards.isEmpty) {
      return _random.nextInt(player.cards.length);
    }

    return hiddenCards[_random.nextInt(hiddenCards.length)];
  }
}

/// KI-Entscheidungen
class AIDecision {
  final AIAction action;
  final int? cardIndex;
  final int? targetPlayerIndex;
  final int? targetCardIndex;

  const AIDecision({
    required this.action,
    this.cardIndex,
    this.targetPlayerIndex,
    this.targetCardIndex,
  });

  factory AIDecision.callPawsy() =>
      const AIDecision(action: AIAction.callPawsy);
  factory AIDecision.drawFromDeck() =>
      const AIDecision(action: AIAction.drawFromDeck);
  factory AIDecision.drawFromDiscard() =>
      const AIDecision(action: AIAction.drawFromDiscard);
  factory AIDecision.swapCard(int cardIndex) =>
      AIDecision(action: AIAction.swapCard, cardIndex: cardIndex);
  factory AIDecision.discardCard() =>
      const AIDecision(action: AIAction.discardCard);
  factory AIDecision.peekOwnCard(int cardIndex) =>
      AIDecision(action: AIAction.peekOwnCard, cardIndex: cardIndex);
  factory AIDecision.spyOpponentCard(int playerIndex, int cardIndex) =>
      AIDecision(
        action: AIAction.spyOpponentCard,
        targetPlayerIndex: playerIndex,
        targetCardIndex: cardIndex,
      );
  factory AIDecision.swapWithOpponent(
    int playerIndex,
    int ownCard,
    int opponentCard,
  ) => AIDecision(
    action: AIAction.swapWithOpponent,
    cardIndex: ownCard,
    targetPlayerIndex: playerIndex,
    targetCardIndex: opponentCard,
  );
  factory AIDecision.doNothing() =>
      const AIDecision(action: AIAction.doNothing);
}

enum AIAction {
  callPawsy,
  drawFromDeck,
  drawFromDiscard,
  swapCard,
  discardCard,
  peekOwnCard,
  spyOpponentCard,
  swapWithOpponent,
  doNothing,
}
