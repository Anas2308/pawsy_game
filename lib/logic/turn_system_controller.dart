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
    if (gameController.gamePhase != 'playing') return;

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

      // Schritt 3: Wenn KI Karte gezogen hat, zweite Entscheidung
      if (gameController.drawnCard != null && gameController.isAITurn) {
        await Future.delayed(const Duration(milliseconds: 1500));

        final secondDecision = await gameController.getAIDecision();
        gameController.executeAIDecision(secondDecision);

        debugPrint('🤖 KI zweite Aktion: ${secondDecision.action}');
      }

    } catch (e) {
      debugPrint('❌ KI Fehler: $e');
    } finally {
      isProcessingAITurn = false;
    }
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