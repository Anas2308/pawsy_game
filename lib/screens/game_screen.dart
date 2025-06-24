import 'package:flutter/material.dart';
import '../widgets/player_area.dart';
import '../widgets/deck_area.dart';
import '../widgets/status_text_widget.dart';
import '../widgets/drawn_card_widget.dart';
import '../widgets/pawsy_button_widget.dart';
import '../widgets/turn_indicator_widget.dart';
import '../widgets/action_card_popup.dart';
import '../logic/game_controller.dart';
import '../logic/multi_select_controller.dart';
import '../logic/turn_system_controller.dart';
import '../logic/action_card_controller.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController gameController = GameController();
  final MultiSelectController multiSelectController = MultiSelectController();
  late final TurnSystemController turnSystemController;

  @override
  void initState() {
    super.initState();
    turnSystemController = TurnSystemController(
      gameController: gameController,
      multiSelectController: multiSelectController,
    );

    _startTurnMonitoring();
  }

  void _startTurnMonitoring() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        await turnSystemController.processNextTurn();
        if (mounted) setState(() {});
      }

      return mounted;
    });
  }

  void _restartGame() {
    setState(() {
      gameController.restartGame();
      multiSelectController.resetSelection();
    });
    debugPrint('🔄 Game restarted!');
  }

  void _onCardTap(int cardIndex) {
    if (!turnSystemController.canPlayerAct) return;

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
    if (!turnSystemController.canPlayerAct) return;

    final selectedIndices = multiSelectController.getSelectedIndices();

    if (selectedIndices.length == 1) {
      setState(() {
        gameController.swapCard(selectedIndices.first);
        multiSelectController.resetSelection();
      });
      debugPrint('🔄 Einzeltausch Karte ${selectedIndices.first}');
    } else {
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

  void _handlePawsy() {
    if (!turnSystemController.canPlayerAct) return;

    setState(() {
      gameController.callPawsy();
    });
    debugPrint('🐾 PAWSY gerufen!');

    _showPawsyMessage('PAWSY gerufen! Das Spiel endet bald...');
  }

  void _handleDrawFromDeck() {
    if (!turnSystemController.canPlayerAct) return;
    setState(() => gameController.drawRandomCard());
    debugPrint('🎴 Karte vom Deck gezogen: ${gameController.drawnCard}');
  }

  void _handleDrawFromDiscard() {
    if (!turnSystemController.canPlayerAct) return;
    setState(() => gameController.drawFromDiscard());
    debugPrint('🎴 Karte vom Ablagestapel gezogen: ${gameController.drawnCard}');
  }

  void _handleDiscard() {
    if (!turnSystemController.canPlayerAct) return;

    final drawnCard = gameController.drawnCard;

    setState(() {
      gameController.discardDrawnCard();
      multiSelectController.resetSelection();
    });

    debugPrint('🗑️ Karte $drawnCard abgelegt');

    // WICHTIG: Prüfe NACH dem Ablegen ob Aktionskarte verfügbar ist
    // (hasUsedActionCard wird nur bei Deck-Karten auf true gesetzt)
    if (gameController.hasUsedActionCard) {
      debugPrint('⚡ Aktionskarte verfügbar! Zeige Popup...');
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleUseActionCard();
      });
    }
  }

  void _handleUseActionCard() {
    if (!gameController.hasUsedActionCard) {
      debugPrint('❌ Keine Aktionskarte verfügbar');
      return;
    }

    final actionType = gameController.getPendingActionCard();
    debugPrint('⚡ Zeige Aktionskarten-Popup für: $actionType');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActionCardPopup(
        actionType: actionType,
        playerCards: gameController.playerCards,
        aiCards: gameController.aiCards,
        onActionComplete: (result) {
          debugPrint('⚡ Aktionskarten-Ergebnis: ${result.message}');

          setState(() {
            gameController.executeActionCard(result);
          });

          if (result.isSuccess) {
            _showSuccessMessage(result.message);
          } else {
            _showPenaltyMessage(result.message);
          }
        },
        onSkip: () {
          debugPrint('⚡ Aktionskarte übersprungen');
          setState(() {
            gameController.skipActionCard();
          });
        },
      ),
    );
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

  void _showPawsyMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🐾 $message'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
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
          TurnIndicatorWidget(
            currentPlayer: turnSystemController.getCurrentPlayerName(),
            turnInfo: turnSystemController.getTurnInfo(),
            isProcessing: turnSystemController.isProcessingAITurn,
          ),
          PlayerArea(
            playerName: 'KI',
            isCurrentPlayer: gameController.isAITurn,
            cardValues: gameController.aiCards,
            cardsVisible: gameController.aiCardsVisible,
          ),
          const Spacer(),
          DeckArea(
            topDiscardCard: gameController.topDiscardCard,
            onDrawFromDeck: _handleDrawFromDeck,
            onDrawFromDiscard: _handleDrawFromDiscard,
            canDraw: turnSystemController.canPlayerAct &&
                gameController.gamePhase == 'playing' &&
                !gameController.hasDrawnThisTurn,
          ),
          if (gameController.drawnCard != null)
            DrawnCardWidget(
              drawnCard: gameController.drawnCard!,
              onDiscard: _handleDiscard,
              onSwap: _handleSwap,
              onUseActionCard: _handleUseActionCard,
              selectedCount: multiSelectController.selectedCount,
              hasActionCardAvailable: gameController.hasUsedActionCard,
              actionCardType: gameController.getPendingActionCard(),
            ),

          // ZUSÄTZLICHER BUTTON: Falls Aktionskarte verfügbar ist
          if (gameController.hasUsedActionCard)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _handleUseActionCard,
                icon: const Icon(Icons.flash_on),
                label: Text('Aktionskarte verwenden (${ActionCardController.getActionName(gameController.getPendingActionCard()).split(' ')[0]})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),

          PawsyButtonWidget(
            onPawsy: _handlePawsy,
            canCallPawsy: turnSystemController.canPlayerAct && gameController.canCallPawsy(),
          ),
          const Spacer(),
          PlayerArea(
            playerName: 'You',
            isCurrentPlayer: gameController.isPlayerTurn,
            cardsVisible: gameController.playerCardsVisible,
            cardValues: gameController.playerCards,
            selectedCards: multiSelectController.selectedCards,
            onCardTap: _onCardTap,
            canSelectCards: turnSystemController.canPlayerAct &&
                ((gameController.gamePhase == 'look_at_cards' && gameController.cardsLookedAt < 2) ||
                    (gameController.gamePhase == 'playing' && gameController.drawnCard != null)),
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