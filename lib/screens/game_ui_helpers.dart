import 'package:flutter/foundation.dart';
import '../logic/game_controller.dart';
import '../logic/multi_select_controller.dart';
import '../logic/turn_system_controller.dart';

class GameUIHelpers {
  static bool canDrawCards(
      TurnSystemController turnController,
      GameController gameController,
      ) {
    final canPlayerAct = turnController.canPlayerAct;
    final gamePhaseOk = (gameController.gamePhase == 'playing' || gameController.gamePhase == 'pawsy_called');
    final hasNotDrawn = !gameController.hasDrawnThisTurn;

    final result = canPlayerAct && gamePhaseOk && hasNotDrawn;

    debugPrint('🔧 DEBUG canDrawCards:');
    debugPrint('  - canPlayerAct: $canPlayerAct');
    debugPrint('  - gamePhase: ${gameController.gamePhase} (ok: $gamePhaseOk)');
    debugPrint('  - hasDrawnThisTurn: ${gameController.hasDrawnThisTurn} (hasNotDrawn: $hasNotDrawn)');
    debugPrint('  - RESULT: $result');

    return result;
  }

  static bool canCallPawsy(
      TurnSystemController turnController,
      GameController gameController,
      ) {
    final canPlayerAct = turnController.canPlayerAct;
    final canCallPawsy = gameController.canCallPawsy();
    final gamePhaseOk = gameController.gamePhase == 'playing';

    final result = canPlayerAct && canCallPawsy && gamePhaseOk;

    debugPrint('🔧 DEBUG canCallPawsy:');
    debugPrint('  - canPlayerAct: $canPlayerAct');
    debugPrint('  - canCallPawsy: $canCallPawsy');
    debugPrint('  - gamePhase: ${gameController.gamePhase} (ok: $gamePhaseOk)');
    debugPrint('  - RESULT: $result');

    return result;
  }

  static bool canSelectCards(
      TurnSystemController turnController,
      GameController gameController,
      ) {
    final canPlayerAct = turnController.canPlayerAct;
    final lookAtPhase = gameController.gamePhase == 'look_at_cards' && gameController.cardsLookedAt < 2;
    final playingPhase = (gameController.gamePhase == 'playing' || gameController.gamePhase == 'pawsy_called') && gameController.drawnCard != null;

    final result = canPlayerAct && (lookAtPhase || playingPhase);

    debugPrint('🔧 DEBUG canSelectCards:');
    debugPrint('  - canPlayerAct: $canPlayerAct');
    debugPrint('  - gamePhase: ${gameController.gamePhase}');
    debugPrint('  - cardsLookedAt: ${gameController.cardsLookedAt}');
    debugPrint('  - drawnCard: ${gameController.drawnCard}');
    debugPrint('  - lookAtPhase: $lookAtPhase');
    debugPrint('  - playingPhase: $playingPhase');
    debugPrint('  - RESULT: $result');

    return result;
  }

  static String getActionCardButtonText(GameController gameController) {
    final actionName = gameController.getPendingActionCard().toString().split('.').last.toUpperCase();
    return 'Aktionskarte verwenden ($actionName)';
  }

  static void startTurnMonitoring(
      TurnSystemController turnController,
      Function() updateUI,
      bool Function() isMounted,
      ) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (isMounted()) {
        await turnController.processNextTurn();
        if (isMounted()) updateUI();
      }

      return isMounted();
    });
  }

  static void restartGame(
      GameController gameController,
      MultiSelectController multiSelectController,
      Function() updateUI,
      ) {
    updateUI();
    gameController.restartGame();
    multiSelectController.resetSelection();
    debugPrint('🔄 Game restarted!');
  }
}