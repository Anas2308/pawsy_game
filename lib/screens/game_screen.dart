import 'package:flutter/material.dart';
import '../widgets/player_area.dart';
import '../widgets/deck_area.dart';
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
      _handleCardAction(cardIndex);
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

  void _handleCardAction(int cardIndex) {
    if (multiSelectController.isMultiSelectMode) {
      setState(() {
        multiSelectController.toggleCardSelection(cardIndex);
      });
      debugPrint('🎯 Karte $cardIndex ${multiSelectController.selectedCards[cardIndex] ? "ausgewählt" : "abgewählt"}');
    } else {
      setState(() {
        gameController.swapCard(cardIndex);
        multiSelectController.resetSelection();
      });
      debugPrint('🔄 Karte $cardIndex getauscht');
    }
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
            tooltip: 'Restart Game',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusText(),
          _buildOpponentArea(),
          const Spacer(),
          _buildDeckArea(),
          _buildDrawnCardArea(),
          const Spacer(),
          _buildPlayerArea(),
          _buildRestartButton(),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        gameController.getStatusText(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOpponentArea() {
    return const PlayerArea(
      playerName: 'Player 2',
      isCurrentPlayer: false,
      cardValues: ['?', '?', '?', '?'],
    );
  }

  Widget _buildDeckArea() {
    return DeckArea(
      topDiscardCard: gameController.topDiscardCard,
      onDrawFromDeck: () => setState(() => gameController.drawRandomCard()),
      onDrawFromDiscard: () => setState(() => gameController.drawFromDiscard()),
      canDraw: gameController.gamePhase == 'playing' && !gameController.hasDrawnThisTurn,
    );
  }

  Widget _buildDrawnCardArea() {
    if (gameController.drawnCard == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Column(
        children: [
          _buildDrawnCard(),
          const SizedBox(height: 12),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDrawnCard() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Gezogen: ', style: TextStyle(color: Colors.white, fontSize: 16)),
        Container(
          width: 40,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              gameController.drawnCard!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => setState(() {
                gameController.discardDrawnCard();
                multiSelectController.resetSelection();
              }),
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Ablegen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => setState(() => multiSelectController.toggleMultiSelectMode()),
              icon: Icon(
                multiSelectController.isMultiSelectMode ? Icons.close : Icons.select_all,
                size: 16,
              ),
              label: Text(multiSelectController.isMultiSelectMode ? 'Abbrechen' : 'Multi-Select'),
              style: ElevatedButton.styleFrom(
                backgroundColor: multiSelectController.isMultiSelectMode ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (multiSelectController.isMultiSelectMode && multiSelectController.selectedCount > 1) ...[
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Multi-Swap Logic hier einbauen
              debugPrint('🎯 Multi-Swap noch nicht implementiert');
            },
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: Text('Duett/Triplett (${multiSelectController.selectedCount})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayerArea() {
    return PlayerArea(
      playerName: 'You',
      isCurrentPlayer: true,
      cardsVisible: gameController.playerCardsVisible,
      cardValues: gameController.playerCards,
      selectedCards: multiSelectController.selectedCards,
      onCardTap: _onCardTap,
      canSelectCards: (gameController.gamePhase == 'look_at_cards' && gameController.cardsLookedAt < 2) ||
          (gameController.gamePhase == 'playing' && gameController.drawnCard != null),
      isMultiSelectMode: multiSelectController.isMultiSelectMode,
    );
  }

  Widget _buildRestartButton() {
    return Padding(
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
    );
  }
}