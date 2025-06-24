import 'dart:math';
import 'package:flutter/foundation.dart';
import 'ai_card_memory.dart';

class AIPawsyStrategy {
  int turnsPlayed = 0;

  void incrementTurns() {
    turnsPlayed++;
  }

  bool shouldCallPawsy(AICardMemory memory) {
    double myEstimatedScore = _calculateMyEstimatedScore(memory);
    double opponentEstimatedScore = _calculateOpponentEstimatedScore(memory);

    debugPrint('🧠 KI Analysis: Meine Punkte ≈ $myEstimatedScore, Gegner ≈ $opponentEstimatedScore, Züge: $turnsPlayed');

    int knownCardsCount = memory.getKnownCardsCount();

    // 1. Aggressive PAWSY wenn KI deutlich im Vorteil
    if (myEstimatedScore < opponentEstimatedScore - 5 && knownCardsCount >= 2) {
      debugPrint('🐾 PAWSY Grund: Deutlicher Vorteil ($myEstimatedScore vs $opponentEstimatedScore)');
      return true;
    }

    // 2. Sehr niedrige Punkte (unter 15) - fast immer PAWSY
    if (myEstimatedScore <= 12 && knownCardsCount >= 3) {
      debugPrint('🐾 PAWSY Grund: Sehr niedrige Punkte ($myEstimatedScore)');
      return true;
    }

    // 3. Nach vielen Zügen (ab Zug 15) - aggressiver werden
    if (turnsPlayed >= 15 && myEstimatedScore < opponentEstimatedScore && knownCardsCount >= 2) {
      debugPrint('🐾 PAWSY Grund: Langes Spiel (Zug $turnsPlayed)');
      return true;
    }

    // 4. Moderate Punkte aber trotzdem besser als Gegner
    if (myEstimatedScore <= 18 && myEstimatedScore < opponentEstimatedScore - 2 && knownCardsCount >= 3) {
      debugPrint('🐾 PAWSY Grund: Moderate Punkte aber im Vorteil');
      return true;
    }

    // 5. Zufallsfaktor bei knappen Entscheidungen
    if (myEstimatedScore < opponentEstimatedScore &&
        myEstimatedScore <= 20 &&
        knownCardsCount >= 3 &&
        Random().nextDouble() < 0.25) { // 25% Chance
      debugPrint('🐾 PAWSY Grund: Zufallsfaktor bei knapper Führung');
      return true;
    }

    debugPrint('❌ Kein PAWSY: Score $myEstimatedScore vs $opponentEstimatedScore, bekannte Karten: $knownCardsCount');
    return false;
  }

  double _calculateMyEstimatedScore(AICardMemory memory) {
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

  double _calculateOpponentEstimatedScore(AICardMemory memory) {
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

  void reset() {
    turnsPlayed = 0;
  }
}