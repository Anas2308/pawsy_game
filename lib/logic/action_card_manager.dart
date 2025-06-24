import 'package:flutter/foundation.dart';
import 'game_state_manager.dart';
import 'action_card_controller.dart';
import 'card_operations.dart';

class ActionCardManager {
  bool hasUsedActionCard = false;
  final CardOperations cardOps = CardOperations();

  void reset() {
    hasUsedActionCard = false;
  }

  bool checkForActionCard(GameStateManager state) {
    if (state.drawnCard != null) {
      final canUseAction = state.drawnFromDeck &&
          ActionCardController.isActionCard(state.drawnCard!);

      debugPrint('🔍 Aktionskarten-Check: drawnFromDeck=${state.drawnFromDeck}, isActionCard=${ActionCardController.isActionCard(state.drawnCard!)}, player=${state.currentPlayer}');

      if (canUseAction) {
        hasUsedActionCard = true;
        debugPrint('✅ Aktionskarte verfügbar: ${state.drawnCard!} für ${state.currentPlayer}');
        return true;
      } else {
        hasUsedActionCard = false;
        debugPrint('❌ Keine Aktionskarte verfügbar');
        return false;
      }
    }
    return false;
  }

  ActionCardType getPendingActionCard(GameStateManager state) {
    if (hasUsedActionCard) {
      return ActionCardController.getActionType(state.topDiscardCard);
    }
    return ActionCardType.none;
  }

  void executeActionCard(GameStateManager state, ActionCardResult result) {
    if (result.isSuccess) {
      final actionType = getPendingActionCard(state);

      if (result.revealedIndex != null) {
        _handleRevealAction(state, actionType, result.revealedIndex!);
      }

      if (result.tradePlayerIndex != null && result.tradeAIIndex != null) {
        _handleTradeAction(state, result);
      }
    }

    hasUsedActionCard = false;
  }

  void _handleRevealAction(GameStateManager state, ActionCardType actionType, int revealedIndex) {
    if (actionType == ActionCardType.look) {
      if (state.currentPlayer == 'player') {
        if (revealedIndex < state.playerCardsVisible.length) {
          state.playerCardsVisible[revealedIndex] = true;
          debugPrint('👁️ LOOK: Player Karte $revealedIndex für Player aufgedeckt');
        }

        Future.delayed(const Duration(seconds: 3), () {
          if (revealedIndex < state.playerCardsVisible.length) {
            state.playerCardsVisible[revealedIndex] = false;
            debugPrint('👁️ LOOK: Player Karte $revealedIndex wieder verdeckt');
          }
        });
      } else {
        debugPrint('👁️ LOOK: KI Karte $revealedIndex intern von KI gelernt (Player sieht nichts)');
      }

    } else if (actionType == ActionCardType.spy) {
      if (state.currentPlayer == 'player') {
        if (revealedIndex < state.aiCardsVisible.length) {
          state.aiCardsVisible[revealedIndex] = true;
          debugPrint('🕵️ SPY: KI Karte $revealedIndex für Player aufgedeckt');
        }

        Future.delayed(const Duration(seconds: 3), () {
          if (revealedIndex < state.aiCardsVisible.length) {
            state.aiCardsVisible[revealedIndex] = false;
            debugPrint('🕵️ SPY: KI Karte $revealedIndex wieder verdeckt');
          }
        });
      } else {
        debugPrint('🕵️ SPY: KI spioniert Player Karte $revealedIndex (Player sieht nichts)');
      }
    }
  }

  void _handleTradeAction(GameStateManager state, ActionCardResult result) {
    if (state.currentPlayer == 'player') {
      final tempCard = state.playerCards[result.tradePlayerIndex!];
      state.playerCards[result.tradePlayerIndex!] = state.aiCards[result.tradeAIIndex!];
      state.aiCards[result.tradeAIIndex!] = tempCard;
      debugPrint('🔄 TRADE: Player tauscht Player[${result.tradePlayerIndex!}] ↔ KI[${result.tradeAIIndex!}]');
    } else {
      final tempCard = state.aiCards[result.tradePlayerIndex!];
      state.aiCards[result.tradePlayerIndex!] = state.playerCards[result.tradeAIIndex!];
      state.playerCards[result.tradeAIIndex!] = tempCard;
      debugPrint('🔄 TRADE: KI tauscht KI[${result.tradePlayerIndex!}] ↔ Player[${result.tradeAIIndex!}]');
    }
  }

  void skipActionCard() {
    hasUsedActionCard = false;
  }
}