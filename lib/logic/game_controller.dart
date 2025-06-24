import 'package:flutter/foundation.dart';
import 'multi_swap_controller.dart';
import 'smart_ai_controller.dart';
import 'action_card_controller.dart';

class GameController {
  String gamePhase = 'look_at_cards';
  List<bool> playerCardsVisible = [false, false, false, false];
  List<bool> aiCardsVisible = [false, false, false, false];
  List<String> playerCards = ['7', '3', '9', '1'];
  List<String> aiCards = ['2', '8', '5', '11'];
  String currentPlayer = 'player';
  int cardsLookedAt = 0;
  String? drawnCard;
  String topDiscardCard = '7';
  bool hasDrawnThisTurn = false;
  bool hasPerformedActionThisTurn = false;
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;
  bool hasUsedActionCard = false;

  // NEU: Flag um zu tracken ob Karte vom Deck kam
  bool drawnFromDeck = false;

  final SmartAIController smartAI = SmartAIController();

  final List<String> deckCards = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '0'
  ];

  void restartGame() {
    gamePhase = 'look_at_cards';
    playerCardsVisible = [false, false, false, false];
    aiCardsVisible = [false, false, false, false];
    playerCards = ['7', '3', '9', '1'];
    aiCards = ['2', '8', '5', '11'];
    currentPlayer = 'player';
    cardsLookedAt = 0;
    drawnCard = null;
    hasDrawnThisTurn = false;
    hasPerformedActionThisTurn = false;
    pawsyCaller = null;
    remainingTurnsAfterPawsy = 0;
    hasUsedActionCard = false;
    drawnFromDeck = false; // NEU
    topDiscardCard = '7';

    smartAI.reset();
    smartAI.setInitialCards(aiCards);
  }

  void drawRandomCard() {
    if (gamePhase == 'playing' && !hasDrawnThisTurn) {
      final random = DateTime.now().millisecondsSinceEpoch % deckCards.length;
      drawnCard = deckCards[random];
      hasDrawnThisTurn = true;
      drawnFromDeck = true; // NEU: Markiere als vom Deck gezogen
      debugPrint('🎴 Karte vom DECK gezogen: $drawnCard');
    }
  }

  void drawFromDiscard() {
    if (gamePhase == 'playing' && !hasDrawnThisTurn) {
      drawnCard = topDiscardCard;
      hasDrawnThisTurn = true;
      drawnFromDeck = false; // NEU: Markiere als vom Discard gezogen
      debugPrint('🎴 Karte vom DISCARD gezogen: $drawnCard');
    }
  }

  void discardDrawnCard() {
    if (drawnCard != null) {
      // Prüfe ob Aktionskarte verfügbar wird
      // FÜR BEIDE: Deck + Aktionskarte (Player UND KI)
      final canUseAction = drawnFromDeck && // War vom Deck
          ActionCardController.isActionCard(drawnCard!);

      debugPrint('🔍 Aktionskarten-Check: drawnFromDeck=$drawnFromDeck, isActionCard=${ActionCardController.isActionCard(drawnCard!)}, player=$currentPlayer');

      topDiscardCard = drawnCard!;

      if (canUseAction) {
        hasUsedActionCard = true;
        debugPrint('✅ Aktionskarte verfügbar: ${drawnCard!} für $currentPlayer');
      } else {
        hasUsedActionCard = false;
        debugPrint('❌ Keine Aktionskarte verfügbar');
      }

      drawnCard = null;
      drawnFromDeck = false; // Reset flag

      if (!hasUsedActionCard) {
        _endTurn(); // Nur Zug beenden wenn keine Aktionskarte verwendet
      } else if (currentPlayer == 'ai') {
        // KI führt Aktionskarte automatisch aus
        _executeAIActionCard();
      }
      // Bei Player wird das Popup in GameScreen gezeigt
    }
  }

  void swapCard(int cardIndex) {
    if (drawnCard != null) {
      if (currentPlayer == 'player') {
        final oldCard = playerCards[cardIndex];
        playerCards[cardIndex] = drawnCard!;
        topDiscardCard = oldCard;
      } else {
        final oldCard = aiCards[cardIndex];
        aiCards[cardIndex] = drawnCard!;
        smartAI.updateCard(cardIndex, drawnCard!);
        topDiscardCard = oldCard;
      }
      drawnCard = null;
      drawnFromDeck = false; // Reset flag
      _endTurn();
    }
  }

  MultiSwapResult executeMultiSwap(List<int> selectedIndices) {
    if (drawnCard == null) {
      return MultiSwapResult.failure('Keine Karte gezogen');
    }

    final result = MultiSwapController.executeMultiSwap(
      playerCards: currentPlayer == 'player' ? playerCards : aiCards,
      selectedIndices: selectedIndices,
      drawnCard: drawnCard!,
    );

    if (result.isSuccess) {
      if (currentPlayer == 'player') {
        playerCards = result.newPlayerCards!;
      } else {
        aiCards = result.newPlayerCards!;
        for (int i = 1; i < selectedIndices.length; i++) {
          smartAI.setCardEmpty(selectedIndices[i]);
        }
        smartAI.updateCard(selectedIndices.first, drawnCard!);
      }
      topDiscardCard = result.discardedCard!;
      drawnCard = null;
      drawnFromDeck = false; // Reset flag
      _endTurn();
    }

    return result;
  }

  void callPawsy() {
    if (canCallPawsy()) {
      pawsyCaller = currentPlayer;
      gamePhase = 'pawsy_called';

      // WICHTIG: Der andere Spieler bekommt noch EINEN Zug
      if (currentPlayer == 'player') {
        remainingTurnsAfterPawsy = 1; // KI bekommt noch 1 Zug
      } else {
        remainingTurnsAfterPawsy = 1; // Player bekommt noch 1 Zug
      }

      debugPrint('🐾 PAWSY gerufen von $currentPlayer! Noch $remainingTurnsAfterPawsy Zug(e) für den anderen Spieler');
      _endTurn();
    }
  }

  bool canCallPawsy() {
    return gamePhase == 'playing' && // Nur in normaler Spielphase, nicht nach PAWSY
        !hasPerformedActionThisTurn &&
        drawnCard == null &&
        pawsyCaller == null; // NEU: Nicht wenn bereits PAWSY gerufen wurde
  }

  // Aktionskarten-Methoden
  ActionCardType getPendingActionCard() {
    if (hasUsedActionCard) {
      return ActionCardController.getActionType(topDiscardCard);
    }
    return ActionCardType.none;
  }

  void executeActionCard(ActionCardResult result) {
    if (result.isSuccess) {
      if (result.revealedIndex != null) {
        final actionType = getPendingActionCard();

        if (actionType == ActionCardType.look) {
          // LOOK: NUR der aktuelle Spieler sieht seine eigene Karte
          if (currentPlayer == 'player') {
            if (result.revealedIndex! < playerCardsVisible.length) {
              playerCardsVisible[result.revealedIndex!] = true;
              debugPrint('👁️ LOOK: Player Karte ${result.revealedIndex!} für Player aufgedeckt');
            }

            // Nach 3 Sekunden wieder verdecken
            Future.delayed(const Duration(seconds: 3), () {
              if (result.revealedIndex! < playerCardsVisible.length) {
                playerCardsVisible[result.revealedIndex!] = false;
                debugPrint('👁️ LOOK: Player Karte ${result.revealedIndex!} wieder verdeckt');
              }
            });
          } else {
            // KI LOOK: Keine visuelle Anzeige, KI hat intern gelernt
            debugPrint('👁️ LOOK: KI Karte ${result.revealedIndex!} intern von KI gelernt (Player sieht nichts)');
          }

        } else if (actionType == ActionCardType.spy) {
          // SPY: NUR der aktuelle Spieler sieht die Gegner-Karte
          if (currentPlayer == 'player') {
            // Player spioniert KI-Karte → Player sieht sie
            if (result.revealedIndex! < aiCardsVisible.length) {
              aiCardsVisible[result.revealedIndex!] = true;
              debugPrint('🕵️ SPY: KI Karte ${result.revealedIndex!} für Player aufgedeckt');
            }

            // Nach 3 Sekunden wieder verdecken
            Future.delayed(const Duration(seconds: 3), () {
              if (result.revealedIndex! < aiCardsVisible.length) {
                aiCardsVisible[result.revealedIndex!] = false;
                debugPrint('🕵️ SPY: KI Karte ${result.revealedIndex!} wieder verdeckt');
              }
            });
          } else {
            // KI spioniert Player-Karte → Player sieht sie NICHT
            debugPrint('🕵️ SPY: KI spioniert Player Karte ${result.revealedIndex!} (Player sieht nichts)');
            // KEINE visuelle Änderung für Player!
          }
        }
      }

      if (result.tradePlayerIndex != null && result.tradeAIIndex != null) {
        // TRADE: Karten zwischen Player und KI tauschen
        if (currentPlayer == 'player') {
          // Player TRADE: Player-Karte ↔ KI-Karte
          final tempCard = playerCards[result.tradePlayerIndex!];
          playerCards[result.tradePlayerIndex!] = aiCards[result.tradeAIIndex!];
          aiCards[result.tradeAIIndex!] = tempCard;

          // KI über Tausch informieren
          smartAI.updateCard(result.tradeAIIndex!, tempCard);
          smartAI.observePlayerReveal(result.tradePlayerIndex!, result.tradePlayerCard!);
          debugPrint('🔄 TRADE: Player tauscht Player[$result.tradePlayerIndex!] ↔ KI[${result.tradeAIIndex!}]');
        } else {
          // KI TRADE: KI-Karte ↔ Player-Karte
          final tempCard = aiCards[result.tradePlayerIndex!]; // Note: tradePlayerIndex ist hier KI-Index
          aiCards[result.tradePlayerIndex!] = playerCards[result.tradeAIIndex!]; // tradeAIIndex ist hier Player-Index
          playerCards[result.tradeAIIndex!] = tempCard;

          // KI über Tausch informieren
          smartAI.updateCard(result.tradePlayerIndex!, aiCards[result.tradePlayerIndex!]);
          debugPrint('🔄 TRADE: KI tauscht KI[${result.tradePlayerIndex!}] ↔ Player[${result.tradeAIIndex!}]');
        }
      }
    }

    hasUsedActionCard = false;
    _endTurn(); // Zug nach Aktionskarte beenden
  }

  void skipActionCard() {
    hasUsedActionCard = false;
    _endTurn();
  }

  // NEU: KI führt Aktionskarten automatisch aus
  void _executeAIActionCard() {
    final actionType = getPendingActionCard();
    debugPrint('🤖 KI verwendet Aktionskarte: $actionType');

    ActionCardResult result;

    switch (actionType) {
      case ActionCardType.look:
      // KI schaut sich zufällige eigene Karte an
        final unknownIndices = <int>[];
        for (int i = 0; i < 4; i++) {
          if (smartAI.knownCards[i] == null && aiCards[i] != 'LEER') {
            unknownIndices.add(i);
          }
        }

        if (unknownIndices.isNotEmpty) {
          final randomIndex = unknownIndices[DateTime.now().millisecondsSinceEpoch % unknownIndices.length];
          result = ActionCardController.executeLookAction(aiCards, randomIndex);

          // KI lernt ihre eigene Karte
          smartAI.updateCard(randomIndex, aiCards[randomIndex]);
          debugPrint('🤖 LOOK: KI lernt eigene Karte $randomIndex = ${aiCards[randomIndex]}');
        } else {
          result = ActionCardResult.failure('Keine unbekannten Karten');
        }
        break;

      case ActionCardType.spy:
      // KI schaut sich zufällige Player-Karte an
        final validIndices = <int>[];
        for (int i = 0; i < 4; i++) {
          if (playerCards[i] != 'LEER') {
            validIndices.add(i);
          }
        }

        if (validIndices.isNotEmpty) {
          final randomIndex = validIndices[DateTime.now().millisecondsSinceEpoch % validIndices.length];
          result = ActionCardController.executeSpyAction(playerCards, randomIndex);

          // KI merkt sich Player-Karte
          smartAI.observePlayerReveal(randomIndex, playerCards[randomIndex]);
          debugPrint('🤖 SPY: KI spioniert Player Karte $randomIndex = ${playerCards[randomIndex]}');
        } else {
          result = ActionCardResult.failure('Keine gültigen Player-Karten');
        }
        break;

      case ActionCardType.trade:
      // KI tauscht intelligently
        final aiWorstIndex = _findAIWorstCard();
        final playerBestIndex = _findPlayerBestCard();

        if (aiWorstIndex != -1 && playerBestIndex != -1) {
          result = ActionCardController.executeTradeAction(
              aiCards, playerCards, aiWorstIndex, playerBestIndex
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

    // Führe Ergebnis aus
    executeActionCard(result);
  }

  int _findAIWorstCard() {
    int worstIndex = -1;
    double worstValue = -1;

    for (int i = 0; i < 4; i++) {
      if (smartAI.knownCards[i] != null && aiCards[i] != 'LEER') {
        final value = _getCardValueAsDouble(smartAI.knownCards[i]!);
        if (value > worstValue) {
          worstValue = value;
          worstIndex = i;
        }
      }
    }

    return worstIndex;
  }

  int _findPlayerBestCard() {
    // KI schätzt welche Player-Karte am besten ist (niedrigste)
    int bestIndex = -1;
    double bestValue = 100;

    for (int i = 0; i < 4; i++) {
      if (playerCards[i] != 'LEER') {
        // Wenn KI diese Karte kennt, nutze echten Wert
        final knownPlayerCards = smartAI.playerRevealedCards;
        double estimatedValue = 6.5; // Default

        if (knownPlayerCards.isNotEmpty) {
          // Nutze Durchschnitt der bekannten Player-Karten
          final values = knownPlayerCards.map((c) => _getCardValueAsDouble(c));
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

  // Hilfsmethode für Kartenwerte als double
  double _getCardValueAsDouble(String card) {
    if (card == 'LEER') return 0.0;
    if (card == '0') return 0.0;
    if (card == '13') return 13.0;
    return double.tryParse(card) ?? 10.0;
  }

  void _endTurn() {
    hasDrawnThisTurn = false;
    hasPerformedActionThisTurn = false;
    drawnFromDeck = false; // Reset flag bei Zugwechsel

    // Spielerwechsel ZUERST
    final previousPlayer = currentPlayer;
    currentPlayer = currentPlayer == 'player' ? 'ai' : 'player';
    debugPrint('🔄 Spielerwechsel: $previousPlayer → $currentPlayer');

    if (pawsyCaller != null) {
      debugPrint('🐾 PAWSY aktiv: Noch $remainingTurnsAfterPawsy Züge übrig');

      // NUR reduzieren wenn der VORHERIGE Spieler NICHT der PAWSY-Caller war
      // Das bedeutet: Der andere Spieler hat gerade seinen Zug beendet
      if (previousPlayer != pawsyCaller) {
        remainingTurnsAfterPawsy--;
        debugPrint('🐾 Zug reduziert: Noch $remainingTurnsAfterPawsy Züge übrig');

        if (remainingTurnsAfterPawsy <= 0) {
          debugPrint('🏁 Spiel beendet - keine Züge mehr übrig');
          endGame();
          return;
        }
      } else {
        debugPrint('🐾 PAWSY-Caller hat Zug beendet - Zähler nicht reduziert');
      }
    }
  }

  void nextTurn() {
    _endTurn();
  }

  bool get isPlayerTurn => currentPlayer == 'player';
  bool get isAITurn => currentPlayer == 'ai';

  Future<AIDecision> getAIDecision() async {
    return smartAI.makeDecision(
      drawnCard: drawnCard,
      topDiscardCard: topDiscardCard,
      canDrawFromDeck: !hasDrawnThisTurn,
      canDrawFromDiscard: !hasDrawnThisTurn,
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
        discardDrawnCard(); // Fallback
      }
    } else if (decision.isMultiSwap) {
      if (decision.cardIndices != null && decision.cardIndices!.length >= 2) {
        final result = executeMultiSwap(decision.cardIndices!);
        if (result.isPenalty) {
          debugPrint('🤖 KI lernt von Fehler: ${result.message}');
          // Nach Penalty ist Zug automatisch beendet
        } else if (!result.isSuccess) {
          debugPrint('🤖 KI Multi-Swap Fehler: ${result.message}');
          discardDrawnCard(); // Fallback
        }
      } else {
        debugPrint('❌ KI: Ungültiger Multi-Swap mit ${decision.cardIndices?.length ?? 0} Karten');
        discardDrawnCard(); // Fallback
      }
    } else if (decision.isDiscard) {
      discardDrawnCard();
    } else if (decision.isPawsy) {
      callPawsy();
    } else {
      debugPrint('❌ KI: Unbekannte Aktion ${decision.action}');
      discardDrawnCard(); // Fallback
    }
  }

  void revealCards(List<int> indices) {
    for (int index in indices) {
      if (currentPlayer == 'player' && index < playerCardsVisible.length) {
        playerCardsVisible[index] = true;
        smartAI.observePlayerReveal(index, playerCards[index]);
      } else if (currentPlayer == 'ai' && index < aiCardsVisible.length) {
        aiCardsVisible[index] = true;
      }
    }
  }

  void hideCards(List<int> indices) {
    for (int index in indices) {
      if (currentPlayer == 'player' && index < playerCardsVisible.length) {
        playerCardsVisible[index] = false;
      } else if (currentPlayer == 'ai' && index < aiCardsVisible.length) {
        aiCardsVisible[index] = false;
      }
    }
  }

  void endTurnAfterPenalty() {
    if (drawnCard != null) {
      topDiscardCard = drawnCard!;
      drawnCard = null;
      drawnFromDeck = false; // Reset flag
    }
    _endTurn();
  }

  void endGame() {
    gamePhase = 'game_ended';
    for (int i = 0; i < playerCardsVisible.length; i++) {
      playerCardsVisible[i] = true;
      aiCardsVisible[i] = true;
    }
  }

  int calculateScore() {
    return calculatePlayerScore();
  }

  int calculatePlayerScore() {
    return _calculateScore(playerCards);
  }

  int calculateAIScore() {
    return _calculateScore(aiCards);
  }

  int _calculateScore(List<String> cards) {
    int score = 0;
    for (String card in cards) {
      if (card == 'LEER') continue;
      if (card == '0') {
        score += 0;
      } else if (card == '13') {
        score += 13;
      } else {
        score += int.tryParse(card) ?? 0;
      }
    }
    return score;
  }

  String getStatusText() {
    if (gamePhase == 'look_at_cards') {
      return 'Schaue dir 2 Karten an ($cardsLookedAt/2)';
    } else if (gamePhase == 'pawsy_called') {
      final caller = pawsyCaller == 'player' ? 'Dir' : 'KI';
      final nextPlayer = currentPlayer == 'player' ? 'Du' : 'KI';
      return 'PAWSY gerufen von $caller! $nextPlayer: Noch $remainingTurnsAfterPawsy Zug(e)';
    } else if (gamePhase == 'game_ended') {
      final playerScore = calculatePlayerScore();
      final aiScore = calculateAIScore();
      final winner = playerScore <= aiScore ? 'Du' : 'KI';
      return 'Spiel beendet! $winner gewinnst! (Du: $playerScore, KI: $aiScore)';
    } else if (hasUsedActionCard) {
      final actionType = getPendingActionCard();
      return 'Aktionskarte ${ActionCardController.getActionName(actionType)} verfügbar!';
    } else if (currentPlayer == 'ai') {
      return 'KI ist am Zug...';
    } else if (drawnCard != null) {
      return 'Gezogene Karte: $drawnCard\nKarten wählen → Tausch-Button klicken';
    } else if (hasPerformedActionThisTurn) {
      return 'Zug beendet - KI ist dran';
    } else {
      return 'Du bist dran! Ziehe eine Karte oder rufe PAWSY!';
    }
  }
}