import 'package:flutter/material.dart';
import '../widgets/player_area.dart';
import '../widgets/deck_area.dart';
import '../widgets/status_text_widget.dart';
import '../widgets/drawn_card_widget.dart';
import '../logic/game_controller.dart';
import '../logic/multi_select_controller.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController gameController = GameController();
  final MultiSelectController multiSelectController = MultiSelectController();

  void _restartGame() {
    setState(() {
      gameController.restartGame();
      multiSelectController.resetSelection();
    });
    debugPrint('🔄 Game restarted!');
  }

  void _onCardTap(int cardIndex) {
    if (gameController.gamePhase == 'look_at_cards' && gameController.cardsLookedAt < 2) {
      _handleLookAtCard(cardIndex);
    } else if (gameController.gamePhase == 'playing' && gameController.drawnCard != null) {
      _handleCardSelection(cardIndex);
    }
  }

  void _handleLookAtCard(int cardIndex) {
    setState(() {
      gameController.playerCardsVisible[cardIndex] = true;
      gameController.cardsLookedAt++;
    });

    debugPrint('🃏 Karte $cardIndex aufgedeckt! (${gameController.cardsLookedAt}/2)');

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        gameController.playerCardsVisible[cardIndex] = false;
      });

      if (gameController.cardsLookedAt == 2) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            gameController.gamePhase = 'playing';
          });
          debugPrint('🎮 Spiel gestartet!');
        });
      }
    });
  }

  void _handleCardSelection(int cardIndex) {
    setState(() {
      multiSelectController.toggleCardSelection(cardIndex);
    });
    debugPrint('🎯 Karte $cardIndex ${multiSelectController.selectedCards[cardIndex] ? "ausgewählt" : "abgewählt"}');
  }

  void _handleSwap() {
    final selectedIndices = multiSelectController.getSelectedIndices();

    if (selectedIndices.length == 1) {
      // Einzeltausch
      setState(() {
        gameController.swapCard(selectedIndices.first);
        multiSelectController.resetSelection();
      });
      debugPrint('🔄 Einzeltausch Karte ${selectedIndices.first}');
    } else {
      // Multi-Swap (Duett/Triplett)
      final result = gameController.executeMultiSwap(selectedIndices);
      debugPrint('🎯 Multi-Swap: ${result.message}');

      if (result.isSuccess) {
        setState(() {
          multiSelectController.resetSelection();
        });
        _showSuccessMessage(result.message);
      } else if (result.isPenalty) {
        setState(() {
          gameController.revealCards(result.revealedIndices!);
          multiSelectController.resetSelection();
        });
        _showPenaltyMessage(result.message);

        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            gameController.hideCards(result.revealedIndices!);
            gameController.endTurnAfterPenalty();
          });
          debugPrint('🙈 Strafe beendet - Zug zu Ende');
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPenaltyMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text('PAWSY'),
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
          StatusTextWidget(statusText: gameController.getStatusText()),
          const PlayerArea(
            playerName: 'Player 2',
            isCurrentPlayer: false,
            cardValues: ['?', '?', '?', '?'],
          ),
          const Spacer(),
          DeckArea(
            topDiscardCard: gameController.topDiscardCard,
            onDrawFromDeck: () => setState(() => gameController.drawRandomCard()),
            onDrawFromDiscard: () => setState(() => gameController.drawFromDiscard()),
            canDraw: gameController.gamePhase == 'playing' && !gameController.hasDrawnThisTurn,
          ),
          if (gameController.drawnCard != null)
            DrawnCardWidget(
              drawnCard: gameController.drawnCard!,
              onDiscard: () => setState(() {
                gameController.discardDrawnCard();
                multiSelectController.resetSelection();
              }),
              onSwap: _handleSwap,
              selectedCount: multiSelectController.selectedCount,
            ),
          const Spacer(),
          PlayerArea(
            playerName: 'You',
            isCurrentPlayer: true,
            cardsVisible: gameController.playerCardsVisible,
            cardValues: gameController.playerCards,
            selectedCards: multiSelectController.selectedCards,
            onCardTap: _onCardTap,
            canSelectCards: (gameController.gamePhase == 'look_at_cards' && gameController.cardsLookedAt < 2) ||
                (gameController.gamePhase == 'playing' && gameController.drawnCard != null),
          ),
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