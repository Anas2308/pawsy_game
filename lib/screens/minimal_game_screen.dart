// lib/screens/minimal_game_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

class MinimalGameController {
  String gamePhase = 'playing';
  String currentPlayer = 'player';
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;
  List<String> playerCards = ['7', '3', '9', '1'];
  List<String> aiCards = ['2', '8', '5', '11'];
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

  bool canCallPawsy() {
    return gamePhase == 'playing' && pawsyCaller == null;
  }

  void callPawsy() {
    if (!canCallPawsy()) return;

    pawsyCaller = currentPlayer;
    gamePhase = 'pawsy_called';
    remainingTurnsAfterPawsy = 1;

    debugPrint('🐾 PAWSY gerufen von $currentPlayer! Noch $remainingTurnsAfterPawsy Zug(e)');
  }

  void nextTurn() {
    turnCounter++;
    debugPrint('🔄 Turn $turnCounter: $currentPlayer beendet Zug');

    if (pawsyCaller != null) {
      if (currentPlayer != pawsyCaller) {
        remainingTurnsAfterPawsy--;
        debugPrint('🐾 Züge nach PAWSY reduziert: $remainingTurnsAfterPawsy');

        if (remainingTurnsAfterPawsy <= 0) {
          gamePhase = 'game_ended';
          debugPrint('🏁 Spiel beendet!');
          return;
        }
      }
    }

    currentPlayer = currentPlayer == 'player' ? 'ai' : 'player';
    debugPrint('🔄 Spielerwechsel zu: $currentPlayer');
  }

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

  bool get isPlayerTurn => currentPlayer == 'player';
  bool get isAITurn => currentPlayer == 'ai';
  bool get isGameEnded => gamePhase == 'game_ended';
  bool get isPawsyPhase => gamePhase == 'pawsy_called';
}

class MinimalGameScreen extends StatefulWidget {
  const MinimalGameScreen({super.key});

  @override
  State<MinimalGameScreen> createState() => _MinimalGameScreenState();
}

class _MinimalGameScreenState extends State<MinimalGameScreen> {
  final MinimalGameController controller = MinimalGameController();
  Timer? aiTimer;
  bool isAIThinking = false;

  @override
  void initState() {
    super.initState();
    _startAIMonitoring();
  }

  @override
  void dispose() {
    aiTimer?.cancel();
    super.dispose();
  }

  void _startAIMonitoring() {
    aiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (controller.isAITurn && !controller.isGameEnded && !isAIThinking) {
        _processAITurn();
      }
    });
  }

  Future<void> _processAITurn() async {
    setState(() {
      isAIThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    // KI entscheidet zufällig ob PAWSY (20% Chance) oder normaler Zug
    if (controller.canCallPawsy() && DateTime.now().millisecond % 5 == 0) {
      controller.callPawsy();
      _showMessage('🐾 KI ruft PAWSY!');
    } else {
      controller.nextTurn();
    }

    setState(() {
      isAIThinking = false;
    });
  }

  void _onPlayerPawsy() {
    if (controller.canCallPawsy()) {
      setState(() {
        controller.callPawsy();
      });
      _showMessage('🐾 Du rufst PAWSY!');
    }
  }

  void _onPlayerNextTurn() {
    if (controller.isPlayerTurn && !controller.isGameEnded) {
      setState(() {
        controller.nextTurn();
      });
    }
  }

  void _restartGame() {
    setState(() {
      controller.resetGame();
      isAIThinking = false;
    });
    _showMessage('🔄 Spiel neu gestartet!');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildCard(String value, bool isVisible) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: isVisible ? Colors.white : Colors.blue[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          isVisible ? value : '?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isVisible ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerArea(String playerName, List<String> cards, bool isCurrentPlayer, bool showCards) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isCurrentPlayer ? Border.all(color: Colors.yellow, width: 3) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                playerName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isCurrentPlayer && isAIThinking) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: cards.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(right: entry.key < 3 ? 8 : 0),
                child: _buildCard(entry.value, showCards),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text('PAWSY - Minimal Test'),
        backgroundColor: Colors.green[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restartGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Text
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              controller.getStatusText(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),

          // KI Bereich
          _buildPlayerArea('KI', controller.aiCards, controller.isAITurn, controller.isGameEnded),

          const Spacer(),

          // Debug Info
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  'Turn: ${controller.turnCounter} | Phase: ${controller.gamePhase}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (controller.pawsyCaller != null)
                  Text(
                    'PAWSY Caller: ${controller.pawsyCaller} | Remaining: ${controller.remainingTurnsAfterPawsy}',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Aktions-Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: controller.isPlayerTurn && !controller.isGameEnded ? _onPlayerNextTurn : null,
                icon: const Icon(Icons.skip_next),
                label: const Text('Zug beenden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: (controller.isPlayerTurn && controller.canCallPawsy()) ? _onPlayerPawsy : null,
                icon: const Icon(Icons.pets),
                label: const Text('PAWSY!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.canCallPawsy() ? Colors.orange[700] : Colors.grey,
                  foregroundColor: Colors.white,
                  elevation: controller.canCallPawsy() ? 8 : 0,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Player Bereich
          _buildPlayerArea('You', controller.playerCards, controller.isPlayerTurn, controller.isGameEnded),

          // Restart Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _restartGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}