import 'package:flutter/foundation.dart';
import 'game_state_manager.dart';

class PawsyManager {
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;

  void reset() {
    pawsyCaller = null;
    remainingTurnsAfterPawsy = 0;
  }

  bool canCallPawsy(GameStateManager state) {
    return state.gamePhase == 'playing' &&
        !state.hasPerformedActionThisTurn &&
        state.drawnCard == null &&
        pawsyCaller == null;
  }

  void callPawsy(GameStateManager state) {
    if (canCallPawsy(state)) {
      pawsyCaller = state.currentPlayer;
      state.gamePhase = 'pawsy_called';

      // Der andere Spieler bekommt noch EINEN Zug
      remainingTurnsAfterPawsy = 1;

      debugPrint('🐾 PAWSY gerufen von ${state.currentPlayer}! Noch $remainingTurnsAfterPawsy Zug(e) für den anderen Spieler');
    }
  }

  bool processTurnEnd(GameStateManager state) {
    if (pawsyCaller == null) return false;

    debugPrint('🐾 PAWSY aktiv: Noch $remainingTurnsAfterPawsy Züge übrig');

    // NUR reduzieren wenn der VORHERIGE Spieler NICHT der PAWSY-Caller war
    final previousPlayer = state.currentPlayer == 'player' ? 'ai' : 'player';

    if (previousPlayer != pawsyCaller) {
      remainingTurnsAfterPawsy--;
      debugPrint('🐾 Zug reduziert: Noch $remainingTurnsAfterPawsy Züge übrig');

      if (remainingTurnsAfterPawsy <= 0) {
        debugPrint('🏁 Spiel beendet - keine Züge mehr übrig');
        state.endGame();
        return true; // Spiel beendet
      }
    } else {
      debugPrint('🐾 PAWSY-Caller hat Zug beendet - Zähler nicht reduziert');
    }

    return false; // Spiel läuft weiter
  }

  String getStatusText(GameStateManager state) {
    if (state.gamePhase == 'pawsy_called') {
      final caller = pawsyCaller == 'player' ? 'Dir' : 'KI';
      final nextPlayer = state.currentPlayer == 'player' ? 'Du' : 'KI';
      return 'PAWSY gerufen von $caller! $nextPlayer: Noch $remainingTurnsAfterPawsy Zug(e)';
    }
    return '';
  }
}