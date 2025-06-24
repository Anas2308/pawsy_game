import 'package:flutter/foundation.dart';
import 'game_controller.dart';
import 'smart_ai_controller.dart';
import 'multi_select_controller.dart';

class TurnSystemController {
  final GameController gameController;
  final MultiSelectController multiSelectController;
  bool isProcessingAITurn = false;

  TurnSystemController({
    required this.gameController,
    required this.multiSelectController,
  });

  Future<void> processNextTurn() async {
    if (gameController.gamePhase != 'playing' && gameController.gamePhase != 'pawsy_called') return;

    if (gameController.isAITurn && !isProcessingAITurn) {
      await _processAITurn();
    }
  }

  Future<void> _processAITurn() async {
    isProcessingAITurn = true;
    debugPrint('🤖 KI beginnt Zug...');

    try {
      // Schritt 1: KI entscheidet was zu tun ist
      final decision = await gameController.getAIDecision();

      // Warte 1 Sekunde für realistische Geschwindigkeit
      await Future.delayed(const Duration(seconds: 1));

      // Schritt 2: Führe KI-Entscheidung aus
      gameController.executeAIDecision(decision);

      debugPrint('🤖 KI Aktion: ${decision.action}');

      // Schritt 3: Wenn KI Karte gezogen hat UND noch am Zug ist, zweite Entscheidung
      if (gameController.drawnCard != null && gameController.isAITurn) {
        await Future.delayed(const Duration(milliseconds: 1500));

        final secondDecision = await gameController.getAIDecision();

        // WICHTIG: Prüfe ob zweite Entscheidung sinnvoll ist
        if (_isValidSecondDecision(secondDecision)) {
          gameController.executeAIDecision(secondDecision);
          debugPrint('🤖 KI zweite Aktion: ${secondDecision.action}');
        } else {
          // Fallback: Einfach ablegen wenn ungültige Entscheidung
          debugPrint('🤖 KI Fallback: Karte ablegen');
          gameController.discardDrawnCard();
        }
      }

      // SICHERHEIT: Wenn KI immer noch eine Karte hat, force discard
      if (gameController.drawnCard != null && gameController.isAITurn) {
        debugPrint('🤖 SICHERHEIT: Force discard');
        gameController.discardDrawnCard();
      }

      // SICHERHEIT: Wenn KI immer noch am Zug ist, force next turn
      if (gameController.isAITurn) {
        debugPrint('🤖 SICHERHEIT: Force next turn');
        gameController.nextTurn();
      }

    } catch (e) {
      debugPrint('❌ KI Fehler: $e');

      // NOTFALL-PROTOKOLL: Zug komplett beenden
      if (gameController.drawnCard != null) {
        gameController.discardDrawnCard();
      }
      if (gameController.isAITurn) {
        gameController.nextTurn();
      }
    } finally {
      isProcessingAITurn = false;
    }
  }

  bool _isValidSecondDecision(AIDecision decision) {
    // Prüfe ob die zweite Entscheidung sinnvoll ist
    if (decision.isSwap && decision.cardIndex != null) {
      // Einzeltausch ist immer ok
      return true;
    }

    if (decision.isMultiSwap && decision.cardIndices != null) {
      // Multi-Swap nur wenn mindestens 2 Indizes
      if (decision.cardIndices!.length < 2) {
        debugPrint('❌ Multi-Swap mit nur ${decision.cardIndices!.length} Karten');
        return false;
      }

      // Prüfe ob alle Indizes gültig sind
      for (int index in decision.cardIndices!) {
        if (index < 0 || index >= 4) {
          debugPrint('❌ Ungültiger Index: $index');
          return false;
        }
      }

      return true;
    }

    if (decision.isDiscard) {
      // Ablegen ist immer ok
      return true;
    }

    // Alle anderen Aktionen sind für zweite Entscheidung ungültig
    return false;
  }

  void startPlayerTurn() {
    debugPrint('👤 Spieler ist am Zug');
    multiSelectController.resetSelection();
  }

  void endPlayerTurn() {
    debugPrint('👤 Spieler Zug beendet');
    multiSelectController.resetSelection();
  }

  bool get canPlayerAct => gameController.isPlayerTurn && !isProcessingAITurn;

  String getCurrentPlayerName() {
    if (gameController.isPlayerTurn) return 'Du';
    if (gameController.isAITurn) return 'KI';
    return 'Unbekannt';
  }

  String getTurnInfo() {
    if (isProcessingAITurn) {
      return 'KI denkt...';
    } else if (gameController.isPlayerTurn) {
      return 'Du bist dran!';
    } else if (gameController.isAITurn) {
      return 'KI ist am Zug';
    }
    return '';
  }
}