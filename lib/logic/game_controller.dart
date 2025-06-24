import 'package:flutter/foundation.dart';
import 'game_state_manager.dart';
import 'pawsy_manager.dart';
import 'card_operations.dart';
import 'action_card_manager.dart';
import 'action_card_controller.dart';
import 'smart_ai_controller.dart';

class GameController {
  final GameStateManager state = GameStateManager();
  final PawsyManager pawsy = PawsyManager();
  final CardOperations cards = CardOperations();
  final ActionCardManager actions = ActionCardManager();
  final SmartAIController smartAI = SmartAIController();

  // Getters für Kompatibilität
  String get gamePhase => state.gamePhase;
  List<bool> get playerCardsVisible => state.playerCardsVisible;
  List<bool> get aiCardsVisible => state.aiCardsVisible;
  List<String> get playerCards => state.playerCards;
  List<String> get aiCards => state.aiCards;
  String get currentPlayer => state.currentPlayer;
  int get cardsLookedAt => state.cardsLookedAt;
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
      }
    }
  }

  void swapCard(int cardIndex) {
    cards.swapCard(state, cardIndex);
    _endTurn();
  }

  void callPawsy() {
    pawsy.callPawsy(state);
    _endTurn();
  }

  bool canCallPawsy() => pawsy.canCallPawsy(state);

  ActionCardType getPendingActionCard() => actions.getPendingActionCard(state);

  void executeActionCard(ActionCardResult result) {
    actions.executeActionCard(state, result);
    _endTurn();
  }

  void skipActionCard() {
    actions.skipActionCard();
    _endTurn();
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