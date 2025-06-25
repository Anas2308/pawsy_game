// lib/logic/minimal_game_controller.dart
import 'package:flutter/foundation.dart';

class MinimalGameController {
  String gamePhase = 'playing';  // 'playing' oder 'pawsy_called' oder 'game_ended'
  String currentPlayer = 'player';  // 'player' oder 'ai'

  // PAWSY-spezifische Variablen
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;

  // Basis-Karten (nur für Anzeige)
  List<String> playerCards = ['7', '3', '9', '1'];
  List<String> aiCards = ['2', '8', '5', '11'];

  // Turn Management
  int turnCounter = 0;

  void resetGame() {
    gamePhase = 'playing';
    currentPlayer = 'player';
    pawsyCaller = null;
    remainingTurnsAfterPawsy = 0;
    turnCounter = 0;
    playerCards = ['7', '3', '9', '1'];
    aiCards = ['2', '8', '5', '11'];
    debugPrint('🔄 Game reset');
  }

  // ✅ ZENTRALE PAWSY-LOGIK
  bool canCallPawsy() {
    return gamePhase == 'playing' && pawsyCaller == null;
  }

  void callPawsy() {
    if (!canCallPawsy()) {
      debugPrint('❌ PAWSY kann nicht gerufen werden');
      return;
    }

    pawsyCaller = currentPlayer;
    gamePhase = 'pawsy_called';
    remainingTurnsAfterPawsy = 1;  // Der andere Spieler bekommt noch 1 Zug

    debugPrint('🐾 PAWSY gerufen von $currentPlayer! Noch $remainingTurnsAfterPawsy Zug(e)');
  }

  void nextTurn() {
    turnCounter++;
    debugPrint('🔄 Turn $turnCounter: $currentPlayer beendet Zug');

    // PAWSY-Logik
    if (pawsyCaller != null) {
      // Der PAWSY-Caller reduziert NICHT den Zähler
      if (currentPlayer != pawsyCaller) {
        remainingTurnsAfterPawsy--;
        debugPrint('🐾 Züge nach PAWSY reduziert: $remainingTurnsAfterPawsy');

        if (remainingTurnsAfterPawsy <= 0) {
          _endGame();
          return;
        }
      }
    }

    // Spieler wechseln
    _switchPlayer();
  }

  void _switchPlayer() {
    final previousPlayer = currentPlayer;
    currentPlayer = currentPlayer == 'player' ? 'ai' : 'player';
    debugPrint('🔄 Spielerwechsel: $previousPlayer → $currentPlayer');
  }

  void _endGame() {
    gamePhase = 'game_ended';
    debugPrint('🏁 Spiel beendet!');
  }

  // Status-Texte
  String getStatusText() {
    if (gamePhase == 'game_ended') {
      final caller = pawsyCaller == 'player' ? 'Du' : 'KI';
      final playerScore = _calculateScore(playerCards);
      final aiScore = _calculateScore(aiCards);
      final winner = playerScore <= aiScore ? 'Du' : 'KI';
      return 'Spiel beendet! PAWSY von $caller. $winner gewinnst! (Du: $playerScore, KI: $aiScore)';
    } else if (gamePhase == 'pawsy_called') {
      final caller = pawsyCaller == 'player' ? 'Dir' : 'KI';
      final nextPlayer = currentPlayer == 'player' ? 'Du' : 'KI';
      return 'PAWSY gerufen von $caller! $nextPlayer: Noch $remainingTurnsAfterPawsy Zug(e)';
    } else {
      final currentPlayerName = currentPlayer == 'player' ? 'Du' : 'KI';
      return '$currentPlayerName ${currentPlayer == 'player' ? 'bist' : 'ist'} am Zug! (Turn $turnCounter)';
    }
  }

  int _calculateScore(List<String> cards) {
    return cards.fold(0, (sum, card) {
      if (card == '0') return sum + 0;
      if (card == '13') return sum + 13;
      return sum + (int.tryParse(card) ?? 0);
    });
  }

  // Getter für UI
  bool get isPlayerTurn => currentPlayer == 'player';
  bool get isAITurn => currentPlayer == 'ai';
  bool get isGameEnded => gamePhase == 'game_ended';
  bool get isPawsyPhase => gamePhase == 'pawsy_called';

  int get playerScore => _calculateScore(playerCards);
  int get aiScore => _calculateScore(aiCards);
}