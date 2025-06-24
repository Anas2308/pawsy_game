import 'package:flutter/foundation.dart';
import 'game_state_manager.dart';
import 'pawsy_manager.dart';
import 'card_operations.dart';
import 'action_card_manager.dart';
import 'action_card_controller.dart';
import 'smart_ai_controller.dart';
import 'multi_swap_controller.dart';

class GameController {
  final GameStateManager state = GameStateManager();
  final PawsyManager pawsy = PawsyManager();
  final CardOperations cards = CardOperations();
  final ActionCardManager actions = ActionCardManager();
  final SmartAIController smartAI = SmartAIController();

  // Getters für Kompatibilität
  String get gamePhase => state.gamePhase;
  set gamePhase(String value) => state.gamePhase = value;

  List<bool> get playerCardsVisible => state.playerCardsVisible;
  List<bool> get aiCardsVisible => state.aiCardsVisible;
  List<String> get playerCards => state.playerCards;
  List<String> get aiCards => state.aiCards;
  String get currentPlayer => state.currentPlayer;

  int get cardsLookedAt => state.cardsLookedAt;
  set cardsLookedAt(int value) => state.cardsLookedAt = value;

  String? get drawnCard => state.drawnCard;
  String get topDiscardCard => state.topDiscardCard;
  bool get hasDrawnThisTurn => state.hasDrawnThisTurn;
  bool get hasUsedActionCard => actions.hasUsedActionCard;
  bool get isPlayerTurn => state.isPlayerTurn;
  bool get isAITurn => state.isAITurn;

  void restartGame() {
    state.resetState();
    pawsy.reset();
    actions.reset();
    smartAI.reset();
    smartAI.setInitialCards(state.aiCards);
  }

  void drawRandomCard() => cards.drawRandomCard(state);
  void drawFromDiscard() => cards.drawFromDiscard(state);

  void discardDrawnCard() {
    if (state.drawnCard != null) {
      final hasAction = actions.checkForActionCard(state);
      state.topDiscardCard = state.drawnCard!;
      state.drawnCard = null;
      state.drawnFromDeck = false;

      if (!hasAction) {
        _endTurn();
      } else if (state.currentPlayer == 'ai') {
        _executeAIActionCard();
      }
    }
  }

  void swapCard(int cardIndex) {
    cards.swapCard(state, cardIndex);
    smartAI.updateCard(cardIndex, state.drawnCard!);
    _endTurn();
  }

  MultiSwapResult executeMultiSwap(List<int> selectedIndices) {
    final result = cards.executeMultiSwap(state, selectedIndices);
    if (result.isSuccess) {
      for (int i = 1; i < selectedIndices.length; i++) {
        smartAI.setCardEmpty(selectedIndices[i]);
      }
      smartAI.updateCard(selectedIndices.first, state.drawnCard!);
      _endTurn();
    }
    return result;
  }

  void callPawsy() {
    pawsy.callPawsy(state);
    _endTurn();
  }

  bool canCallPawsy() => pawsy.canCallPawsy(state);

  ActionCardType getPendingActionCard() => actions.getPendingActionCard(state);

  void executeActionCard(ActionCardResult result) {
    actions.executeActionCard(state, result);
    if (result.tradePlayerIndex != null && result.tradeAIIndex != null) {
      smartAI.updateCard(result.tradeAIIndex!, result.tradeAICard!);
      smartAI.observePlayerReveal(result.tradePlayerIndex!, result.tradePlayerCard!);
    }
    _endTurn();
  }

  void skipActionCard() {
    actions.skipActionCard();
    _endTurn();
  }

  // AI-Methoden
  Future<AIDecision> getAIDecision() async {
    return smartAI.makeDecision(
      drawnCard: state.drawnCard,
      topDiscardCard: state.topDiscardCard,
      canDrawFromDeck: !state.hasDrawnThisTurn,
      canDrawFromDiscard: !state.hasDrawnThisTurn,
      canCallPawsy: canCallPawsy(),
    );
  }

  void executeAIDecision(AIDecision decision) {
    if (decision.isDrawFromDeck) {
      drawRandomCard();
    } else if (decision.isDrawFromDiscard) {
      drawFromDiscard();
    } else if (decision.isSwap) {
      if (decision.cardIndex != null && decision.cardIndex! >= 0 && decision.cardIndex! < 4) {
        swapCard(decision.cardIndex!);
      } else {
        debugPrint('❌ KI: Ungültiger Swap-Index ${decision.cardIndex}');
        discardDrawnCard();
      }
    } else if (decision.isMultiSwap) {
      if (decision.cardIndices != null && decision.cardIndices!.length >= 2) {
        final result = executeMultiSwap(decision.cardIndices!);
        if (result.isPenalty) {
          debugPrint('🤖 KI lernt von Fehler: ${result.message}');
        } else if (!result.isSuccess) {
          debugPrint('🤖 KI Multi-Swap Fehler: ${result.message}');
          discardDrawnCard();
        }
      } else {
        debugPrint('❌ KI: Ungültiger Multi-Swap mit ${decision.cardIndices?.length ?? 0} Karten');
        discardDrawnCard();
      }
    } else if (decision.isDiscard) {
      discardDrawnCard();
    } else if (decision.isPawsy) {
      callPawsy();
    } else {
      debugPrint('❌ KI: Unbekannte Aktion ${decision.action}');
      discardDrawnCard();
    }
  }

  void _executeAIActionCard() {
    final actionType = getPendingActionCard();
    debugPrint('🤖 KI verwendet Aktionskarte: $actionType');

    ActionCardResult result;

    switch (actionType) {
      case ActionCardType.look:
        final unknownIndices = <int>[];
        for (int i = 0; i < 4; i++) {
          if (smartAI.knownCards[i] == null && state.aiCards[i] != 'LEER') {
            unknownIndices.add(i);
          }
        }

        if (unknownIndices.isNotEmpty) {
          final randomIndex = unknownIndices[DateTime.now().millisecondsSinceEpoch % unknownIndices.length];
          result = ActionCardController.executeLookAction(state.aiCards, randomIndex);
          smartAI.updateCard(randomIndex, state.aiCards[randomIndex]);
          debugPrint('🤖 LOOK: KI lernt eigene Karte $randomIndex = ${state.aiCards[randomIndex]}');
        } else {
          result = ActionCardResult.failure('Keine unbekannten Karten');
        }
        break;

      case ActionCardType.spy:
        final validIndices = <int>[];
        for (int i = 0; i < 4; i++) {
          if (state.playerCards[i] != 'LEER') {
            validIndices.add(i);
          }
        }

        if (validIndices.isNotEmpty) {
          final randomIndex = validIndices[DateTime.now().millisecondsSinceEpoch % validIndices.length];
          result = ActionCardController.executeSpyAction(state.playerCards, randomIndex);
          smartAI.observePlayerReveal(randomIndex, state.playerCards[randomIndex]);
          debugPrint('🤖 SPY: KI spioniert Player Karte $randomIndex = ${state.playerCards[randomIndex]}');
        } else {
          result = ActionCardResult.failure('Keine gültigen Player-Karten');
        }
        break;

      case ActionCardType.trade:
        final aiWorstIndex = _findAIWorstCard();
        final playerBestIndex = _findPlayerBestCard();

        if (aiWorstIndex != -1 && playerBestIndex != -1) {
          result = ActionCardController.executeTradeAction(
              state.aiCards, state.playerCards, aiWorstIndex, playerBestIndex
          );
          debugPrint('🤖 TRADE: KI tauscht AI[$aiWorstIndex] mit Player[$playerBestIndex]');
        } else {
          result = ActionCardResult.failure('Keine gültigen Tauschkarten');
        }
        break;

      case ActionCardType.none:
        result = ActionCardResult.failure('Keine Aktionskarte');
        break;
    }

    executeActionCard(result);
  }

  int _findAIWorstCard() {
    int worstIndex = -1;
    double worstValue = -1;

    for (int i = 0; i < 4; i++) {
      if (smartAI.knownCards[i] != null && state.aiCards[i] != 'LEER') {
        final value = cards.getCardValueAsDouble(smartAI.knownCards[i]!);
        if (value > worstValue) {
          worstValue = value;
          worstIndex = i;
        }
      }
    }

    return worstIndex;
  }

  int _findPlayerBestCard() {
    int bestIndex = -1;
    double bestValue = 100;

    for (int i = 0; i < 4; i++) {
      if (state.playerCards[i] != 'LEER') {
        final knownPlayerCards = smartAI.playerRevealedCards;
        double estimatedValue = 6.5;

        if (knownPlayerCards.isNotEmpty) {
          final values = knownPlayerCards.map((c) => cards.getCardValueAsDouble(c));
          estimatedValue = values.reduce((a, b) => a + b) / knownPlayerCards.length;
        }

        if (estimatedValue < bestValue) {
          bestValue = estimatedValue;
          bestIndex = i;
        }
      }
    }

    return bestIndex;
  }

  void _endTurn() {
    state.endTurn();

    final gameEnded = pawsy.processTurnEnd(state);
    if (gameEnded) return;

    state.switchPlayer();
  }

  void nextTurn() => _endTurn();
  void revealCards(List<int> indices) => state.revealCards(indices);
  void hideCards(List<int> indices) => state.hideCards(indices);
  void endGame() => state.endGame();
  void endTurnAfterPenalty() {
    cards.endTurnAfterPenalty(state);
    _endTurn();
  }

  int calculatePlayerScore() => state.calculatePlayerScore();
  int calculateAIScore() => state.calculateAIScore();

  String getStatusText() {
    if (state.gamePhase == 'look_at_cards') {
      return 'Schaue dir 2 Karten an (${state.cardsLookedAt}/2)';
    } else if (state.gamePhase == 'pawsy_called') {
      return pawsy.getStatusText(state);
    } else if (state.gamePhase == 'game_ended') {
      final winner = state.getWinner();
      return 'Spiel beendet! $winner gewinnst! (Du: ${calculatePlayerScore()}, KI: ${calculateAIScore()})';
    } else if (actions.hasUsedActionCard) {
      final actionType = getPendingActionCard();
      return 'Aktionskarte ${ActionCardController.getActionName(actionType)} verfügbar!';
    } else if (state.currentPlayer == 'ai') {
      return 'KI ist am Zug...';
    } else if (state.drawnCard != null) {
      return 'Gezogene Karte: ${state.drawnCard}\nKarten wählen → Tausch-Button klicken';
    } else {
      return 'Du bist dran! Ziehe eine Karte oder rufe PAWSY!';
    }
  }
}