// lib/services/animation_service.dart
import 'package:flutter/animation.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class AnimationService {
  // =============================================================================
  // ANIMATION STATE MANAGEMENT
  // =============================================================================

  /// Startet eine Highlight-Animation
  static GameState startHighlightAnimation(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) {
    return gameState.copyWith(
      animationPhase: AnimationPhase.highlighting,
      highlightedPlayerIndex: playerIndex,
      highlightedCardIndex: cardIndex,
      isAnimating: true,
    );
  }

  /// Beendet eine Highlight-Animation
  static GameState finishHighlightAnimation(GameState gameState) {
    return gameState.copyWith(
      animationPhase: AnimationPhase.none,
      highlightedPlayerIndex: null,
      highlightedCardIndex: null,
      isAnimating: false,
    );
  }

  /// Startet eine Switch-Animation
  static GameState startSwitchAnimation(
    GameState gameState,
    List<(int, int)> switchingCards,
  ) {
    return gameState.copyWith(
      animationPhase: AnimationPhase.switching,
      switchingCards: switchingCards,
      isAnimating: true,
    );
  }

  /// Beendet eine Switch-Animation
  static GameState finishSwitchAnimation(GameState gameState) {
    return gameState.copyWith(
      animationPhase: AnimationPhase.none,
      switchingCards: [],
      isAnimating: false,
    );
  }

  /// Startet eine temporäre Kartenaufdeckung
  static GameState startCardReveal(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) {
    return gameState.copyWith(
      revealedPlayerIndex: playerIndex,
      revealedCardIndex: cardIndex,
    );
  }

  /// Beendet eine temporäre Kartenaufdeckung
  static GameState finishCardReveal(GameState gameState) {
    return gameState.copyWith(
      revealedPlayerIndex: null,
      revealedCardIndex: null,
    );
  }

  // =============================================================================
  // ANIMATION TIMING
  // =============================================================================

  /// Führt eine komplette Highlight-Animation aus
  static Future<GameState> executeHighlightAnimation(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) async {
    // Starte Animation
    GameState animatingState = startHighlightAnimation(
      gameState,
      playerIndex,
      cardIndex,
    );

    // Warte auf Animation-Dauer
    await Future.delayed(GameConstants.highlightAnimationDuration);

    // Beende Animation
    return finishHighlightAnimation(animatingState);
  }

  /// Führt eine komplette Switch-Animation aus
  static Future<GameState> executeSwitchAnimation(
    GameState gameState,
    List<(int, int)> switchingCards,
  ) async {
    // Starte Animation
    GameState animatingState = startSwitchAnimation(gameState, switchingCards);

    // Warte auf Animation-Dauer
    await Future.delayed(GameConstants.switchAnimationDuration);

    // Beende Animation
    return finishSwitchAnimation(animatingState);
  }

  /// Führt eine temporäre Kartenaufdeckung mit Timer aus
  static Future<GameState> executeCardReveal(
    GameState gameState,
    int playerIndex,
    int cardIndex, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    // Starte Aufdeckung
    GameState revealedState = startCardReveal(
      gameState,
      playerIndex,
      cardIndex,
    );

    // Warte auf gewünschte Dauer
    await Future.delayed(duration);

    // Beende Aufdeckung
    return finishCardReveal(revealedState);
  }

  // =============================================================================
  // DEALING ANIMATION
  // =============================================================================

  /// Berechnet die Zielposition für eine ausgeteilte Karte
  static Offset calculateDealingTarget(int playerIndex, int playerCount) {
    switch (playerCount) {
      case 2:
        return playerIndex == 0 ? const Offset(0, 1.5) : const Offset(0, -1.5);

      case 3:
        if (playerIndex == 0) return const Offset(0, 1.5);
        if (playerIndex == 1) return const Offset(-1, -1);
        return const Offset(1, -1);

      case 4:
        if (playerIndex == 0) return const Offset(0, 1.5);
        if (playerIndex == 1) return const Offset(-1.5, 0);
        if (playerIndex == 2) return const Offset(0, -1.5);
        return const Offset(1.5, 0);

      case 5:
        if (playerIndex == 0) return const Offset(0, 1.5);
        if (playerIndex == 1) return const Offset(-1.5, 0);
        if (playerIndex == 2) return const Offset(-0.8, -1.2);
        if (playerIndex == 3) return const Offset(0.8, -1.2);
        return const Offset(1.5, 0);

      default:
        return Offset.zero;
    }
  }

  /// Berechnet die Animation-Kurve für Kartenausteilen
  static Curve getDealingCurve() {
    return Curves.easeInOut;
  }

  /// Berechnet die Verzögerung zwischen Karten beim Austeilen
  static Duration getDealingDelay(int cardIndex) {
    return Duration(
      milliseconds: cardIndex * GameConstants.betweenCardDelay.inMilliseconds,
    );
  }

  // =============================================================================
  // CARD ANIMATION HELPERS
  // =============================================================================

  /// Berechnet die Skalierung für animierte Karten
  static double calculateCardScale(
    AnimationPhase phase,
    double animationProgress,
  ) {
    switch (phase) {
      case AnimationPhase.highlighting:
        return 1.0 + ((GameConstants.highlightScale - 1.0) * animationProgress);

      case AnimationPhase.switching:
        // Ping-Pong Animation für Switch
        if (animationProgress < 0.5) {
          return 1.0 +
              ((GameConstants.switchScale - 1.0) * animationProgress * 2);
        } else {
          return GameConstants.switchScale -
              ((GameConstants.switchScale - 1.0) *
                  (animationProgress - 0.5) *
                  2);
        }

      default:
        return 1.0;
    }
  }

  /// Berechnet den Offset für animierte Karten
  static Offset calculateCardOffset(
    AnimationPhase phase,
    double animationProgress,
  ) {
    switch (phase) {
      case AnimationPhase.highlighting:
        return Offset(0, -GameConstants.highlightOffset * animationProgress);

      case AnimationPhase.switching:
        // Bewegung zur Mitte und zurück
        double progress = animationProgress;
        if (progress < 0.5) {
          return Offset(0, -50 * progress * 2);
        } else {
          return Offset(0, -50 * (1 - progress) * 2);
        }

      default:
        return Offset.zero;
    }
  }

  // =============================================================================
  // ANIMATION UTILITIES
  // =============================================================================

  /// Prüft ob gerade eine Animation läuft
  static bool isAnimating(GameState gameState) {
    return gameState.isAnimating ||
        gameState.animationPhase != AnimationPhase.none;
  }

  /// Prüft ob eine Karte gerade highlighted ist
  static bool isCardHighlighted(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) {
    return gameState.highlightedPlayerIndex == playerIndex &&
        gameState.highlightedCardIndex == cardIndex;
  }

  /// Prüft ob eine Karte gerade getauscht wird
  static bool isCardSwitching(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) {
    return gameState.switchingCards.any(
      (card) => card.$1 == playerIndex && card.$2 == cardIndex,
    );
  }

  /// Prüft ob eine Karte temporär aufgedeckt ist
  static bool isCardRevealed(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) {
    return gameState.revealedPlayerIndex == playerIndex &&
        gameState.revealedCardIndex == cardIndex;
  }

  /// Stoppt alle laufenden Animationen (Emergency Stop)
  static GameState stopAllAnimations(GameState gameState) {
    return gameState.copyWith(
      animationPhase: AnimationPhase.none,
      highlightedPlayerIndex: null,
      highlightedCardIndex: null,
      switchingCards: [],
      revealedPlayerIndex: null,
      revealedCardIndex: null,
      isAnimating: false,
    );
  }

  // =============================================================================
  // ANIMATION PRESETS
  // =============================================================================

  /// Vordefinierte Animation für SCOUT
  static Future<GameState> executeScoutAnimation(
    GameState gameState,
    int cardIndex,
  ) async {
    return executeCardReveal(
      gameState,
      0, // Human player
      cardIndex,
      duration: const Duration(seconds: 2),
    );
  }

  /// Vordefinierte Animation für STALK
  static Future<GameState> executeStalkAnimation(
    GameState gameState,
    int playerIndex,
    int cardIndex,
  ) async {
    return executeCardReveal(
      gameState,
      playerIndex,
      cardIndex,
      duration: const Duration(seconds: 2),
    );
  }

  /// Vordefinierte Animation für SWITCH
  static Future<GameState> executeSwitchCardAnimation(
    GameState gameState,
    int humanCardIndex,
    int opponentPlayerIndex,
    int opponentCardIndex,
  ) async {
    List<(int, int)> switchingCards = [
      (0, humanCardIndex), // Human player card
      (opponentPlayerIndex, opponentCardIndex), // Opponent card
    ];

    return executeSwitchAnimation(gameState, switchingCards);
  }

  /// Animation für Kartenziehen vom Ablagestapel
  static GameState startDiscardDrawAnimation(GameState gameState) {
    return gameState.copyWith(isDrawingFromDiscard: true);
  }

  /// Beendet Kartenziehen-Animation
  static GameState finishDiscardDrawAnimation(GameState gameState) {
    return gameState.copyWith(isDrawingFromDiscard: false, showDrawnCard: true);
  }
}
