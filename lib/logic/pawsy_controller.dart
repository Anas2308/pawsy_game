import 'package:flutter/foundation.dart';
import 'game_state_manager.dart';
import 'ai_card_memory.dart';

class PawsyController {
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;
  int turnsPlayed = 0;

  void reset() {
    pawsyCaller = null;
    remainingTurnsAfterPawsy = 0;
    turnsPlayed = 0;
  }

  void incrementTurns() {
    turnsPlayed++;
  }

  // ✅ ZENTRALE PAWSY-LOGIK: Kann PAWSY gerufen werden?
  bool canCallPawsy(GameStateManager state) {
    return state.gamePhase == 'playing' &&
        !state.hasPerformedActionThisTurn &&
        state.drawnCard == null &&
        pawsyCaller == null;
  }

  // ✅ ZENTRALE PAWSY-LOGIK: PAWSY aufrufen
  void callPawsy(GameStateManager state) {
    if (!canCallPawsy(state)) {
      return;
    }

    pawsyCaller = state.currentPlayer;
    state.gamePhase = 'pawsy_called';
    remainingTurnsAfterPawsy = 1;
  }

  // ✅ ZENTRALE PAWSY-LOGIK: Soll KI PAWSY rufen?
  bool shouldAICallPawsy(AICardMemory memory) {
    double myEstimatedScore = _calculateAIScore(memory);
    double opponentEstimatedScore = _calculatePlayerScore(memory);

    int knownCardsCount = memory.getKnownCardsCount();

    // 1. Aggressive PAWSY wenn KI deutlich im Vorteil
    if (myEstimatedScore < opponentEstimatedScore - 5 && knownCardsCount >= 2) {
      return true;
    }

    // 2. Sehr niedrige Punkte (unter 12) - fast immer PAWSY
    if (myEstimatedScore <= 12 && knownCardsCount >= 3) {
      return true;
    }

    // 3. Nach vielen Zügen (ab Zug 15) - aggressiver werden
    if (turnsPlayed >= 15 && myEstimatedScore < opponentEstimatedScore && knownCardsCount >= 2) {
      return true;
    }

    return false;
  }

  // ✅ ZENTRALE PAWSY-LOGIK: Zug-Ende verarbeiten
  bool processTurnEnd(GameStateManager state) {
    if (pawsyCaller == null) return false;

    // WICHTIG: Der PAWSY-Caller reduziert NICHT den Zähler bei seinem eigenen Zug-Ende
    if (state.currentPlayer == pawsyCaller) {
      return false; // Spiel läuft weiter, aber Zähler nicht reduzieren
    }

    // Nur der ANDERE Spieler reduziert den Zähler
    remainingTurnsAfterPawsy--;

    if (remainingTurnsAfterPawsy <= 0) {
      state.endGame();
      return true; // Spiel beendet
    }

    return false; // Spiel läuft weiter
  }

  // ✅ ZENTRALE PAWSY-LOGIK: Status-Text
  String getStatusText(GameStateManager state) {
    if (state.gamePhase == 'pawsy_called') {
      final caller = pawsyCaller == 'player' ? 'Dir' : 'KI';
      final nextPlayer = state.currentPlayer == 'player' ? 'Du' : 'KI';
      return 'PAWSY gerufen von $caller! $nextPlayer: Noch $remainingTurnsAfterPawsy Zug(e)';
    }
    return '';
  }

  // ✅ ZENTRALE PAWSY-LOGIK: Ist das Spiel in PAWSY-Phase?
  bool isPawsyPhase(GameStateManager state) {
    return state.gamePhase == 'pawsy_called';
  }

  // Private Hilfsmethoden für KI-Scoring
  double _calculateAIScore(AICardMemory memory) {
    double totalScore = 0;
    int knownCount = 0;

    for (int i = 0; i < 4; i++) {
      if (memory.knownCards[i] != null && memory.knownCards[i] != 'LEER') {
        totalScore += memory.getCardValue(memory.knownCards[i]!);
        knownCount++;
      }
    }

    int unknownCount = memory.getActiveCardCount() - knownCount;
    if (unknownCount > 0) {
      double avgRemainingCardValue = memory.calculateAverageRemainingCardValue();
      // Optimistischere Schätzung für unbekannte Karten (20% besser)
      totalScore += unknownCount * (avgRemainingCardValue * 0.8);
    }

    return totalScore;
  }

  double _calculatePlayerScore(AICardMemory memory) {
    double baseEstimate = 6.5 * 4; // Standard-Durchschnitt

    if (memory.playerRevealedCards.isNotEmpty) {
      double revealedAvg = memory.playerRevealedCards.map(memory.getCardValue).reduce((a, b) => a + b) / memory.playerRevealedCards.length;
      baseEstimate = revealedAvg * 4;
    }

    // Wenn viel Zeit vergangen ist, pessimistischere Schätzung für Gegner
    if (turnsPlayed >= 10) {
      baseEstimate *= 0.9; // Gegner wird besser mit der Zeit
    }

    return baseEstimate;
  }
}