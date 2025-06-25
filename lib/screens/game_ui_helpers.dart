import 'package:flutter/foundation.dart';
import '../logic/game_controller.dart';
import '../logic/multi_select_controller.dart';
import '../logic/turn_system_controller.dart';

class GameUIHelpers {
  static bool canDrawCards(
      TurnSystemController turnController,
      GameController gameController,
      ) {
    return turnController.canPlayerAct &&
        (gameController.gamePhase == 'playing' || gameController.gamePhase == 'pawsy_called') &&
        !gameController.hasDrawnThisTurn;
  }

  static bool canCallPawsy(
      TurnSystemController turnController,
      GameController gameController,
      ) {
    return turnController.canPlayerAct &&
        gameController.canCallPawsy() &&
        gameController.gamePhase == 'playing';
  }

  static bool canSelectCards(
      TurnSystemController turnController,
      GameController gameController,
      ) {
    return turnController.canPlayerAct &&
        ((gameController.gamePhase == 'look_at_cards' && gameController.cardsLookedAt < 2) ||
            ((gameController.gamePhase == 'playing' || gameController.gamePhase == 'pawsy_called') &&
                gameController.drawnCard != null));
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
    gameController.restartGame();
    multiSelectController.resetSelection();
    updateUI();
    debugPrint('🔄 Game restarted!');
  }
}