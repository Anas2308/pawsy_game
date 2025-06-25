// lib/main.dart - Minimal PAWSY Version mit Karten ziehen
import 'package:flutter/material.dart';

void main() {
  runApp(const MinimalPawsyApp());
}

class MinimalPawsyApp extends StatelessWidget {
  const MinimalPawsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAWSY - Minimal Test',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MinimalGameScreen(),
    );
  }
}

// Minimal Game Logic with Card Drawing
class MinimalGameController {
  String gamePhase = 'look_at_cards';  // Neue Phase am Start
  String currentPlayer = 'player';
  String? pawsyCaller;
  int remainingTurnsAfterPawsy = 0;
  List<String> playerCards = ['7', '3', '9', '1'];
  List<String> aiCards = ['2', '8', '5', '11'];
  int turnCounter = 0;

  // Card-Drawing Variablen
  String? drawnCard;
  String topDiscardCard = '10';
  bool hasDrawnThisTurn = false;
  final List<String> deckCards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '0'];

  // Look-at-Cards Variablen
  int cardsLookedAt = 0;
  List<bool> playerCardsVisible = [false, false, false, false];
  List<bool> aiCardsVisible = [false, false, false, false];

  void resetGame() {
    gamePhase = 'look_at_cards';
    currentPlayer = 'player';
    pawsyCaller = null;
    remainingTurnsAfterPawsy = 0;
    turnCounter = 0;
    playerCards = ['7', '3', '9', '1'];
    aiCards = ['2', '8', '5', '11'];
    drawnCard = null;
    topDiscardCard = '10';
    hasDrawnThisTurn = false;
    cardsLookedAt = 0;
    playerCardsVisible = [false, false, false, false];
    aiCardsVisible = [false, false, false, false];
    debugPrint('🔄 Game reset');
  }

  bool canCallPawsy() {
    return gamePhase == 'playing' && pawsyCaller == null && drawnCard == null;
  }

  // Look-at-Cards Methoden
  void lookAtCard(int cardIndex) {
    if (gamePhase != 'look_at_cards' || cardsLookedAt >= 2) return;

    if (currentPlayer == 'player') {
      playerCardsVisible[cardIndex] = true;
      debugPrint('👁️ Player schaut sich Karte $cardIndex an: ${playerCards[cardIndex]}');
    } else {
      aiCardsVisible[cardIndex] = true;
      debugPrint('👁️ KI schaut sich Karte $cardIndex an: ${aiCards[cardIndex]}');
    }

    cardsLookedAt++;

    if (cardsLookedAt >= 2) {
      debugPrint('✅ $currentPlayer hat 2 Karten angeschaut');

      // Nach 2 Sekunden Karten wieder verstecken und ggf. zum anderen Spieler
      Future.delayed(const Duration(seconds: 2), () {
        if (currentPlayer == 'player') {
          playerCardsVisible = [false, false, false, false];

          if (gamePhase == 'look_at_cards') {
            // Wechsel zur KI für ihre 2 Karten
            currentPlayer = 'ai';
            cardsLookedAt = 0;
            debugPrint('🔄 Wechsel zu KI für Karten anschauen');

            // KI schaut sich automatisch 2 zufällige Karten an
            _aiLookAtCards();
          }
        } else {
          aiCardsVisible = [false, false, false, false];

          // Beide Spieler fertig → Spiel startet mit Player
          gamePhase = 'playing';
          currentPlayer = 'player';  // WICHTIG: Player startet!
          debugPrint('🎮 Spiel startet! Player beginnt');
        }
      });
    }
  }

  void _aiLookAtCards() {
    final availableIndices = [0, 1, 2, 3];
    availableIndices.shuffle();

    // KI schaut sich erste 2 Karten an
    for (int i = 0; i < 2; i++) {
      Future.delayed(Duration(milliseconds: 800 * (i + 1)), () {
        if (gamePhase == 'look_at_cards') {
          lookAtCard(availableIndices[i]);
        }
      });
    }
  }

  void callPawsy() {
    if (!canCallPawsy()) return;

    pawsyCaller = currentPlayer;
    gamePhase = 'pawsy_called';
    remainingTurnsAfterPawsy = 1;

    debugPrint('🐾 PAWSY gerufen von $currentPlayer! Noch $remainingTurnsAfterPawsy Zug(e)');

    // Nach PAWSY automatisch zum nächsten Spieler wechseln
    currentPlayer = currentPlayer == 'player' ? 'ai' : 'player';
    debugPrint('🔄 Automatischer Wechsel nach PAWSY zu: $currentPlayer');
  }

  void nextTurn() {
    turnCounter++;
    debugPrint('🔄 Turn $turnCounter: $currentPlayer beendet Zug');

    // Reset turn state
    hasDrawnThisTurn = false;
    drawnCard = null;

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

  // Card-Drawing Methoden
  void drawFromDeck() {
    if (hasDrawnThisTurn || drawnCard != null) return;

    final random = DateTime.now().millisecondsSinceEpoch % deckCards.length;
    drawnCard = deckCards[random];
    hasDrawnThisTurn = true;
    debugPrint('🎴 $currentPlayer zieht vom Deck: $drawnCard');
  }

  void drawFromDiscard() {
    if (hasDrawnThisTurn || drawnCard != null) return;

    drawnCard = topDiscardCard;
    hasDrawnThisTurn = true;
    debugPrint('🎴 $currentPlayer zieht vom Discard: $drawnCard');
  }

  void discardDrawnCard() {
    if (drawnCard == null) return;

    topDiscardCard = drawnCard!;
    drawnCard = null;
    debugPrint('🗑️ $currentPlayer legt ab: $topDiscardCard');

    nextTurn();
  }

  void swapWithSelectedCard(int cardIndex) {
    if (drawnCard == null) return;

    if (currentPlayer == 'player') {
      final oldCard = playerCards[cardIndex];
      playerCards[cardIndex] = drawnCard!;
      topDiscardCard = oldCard;
      debugPrint('🔄 $currentPlayer tauscht: Position $cardIndex ($oldCard → ${drawnCard!})');
    } else {
      final oldCard = aiCards[cardIndex];
      aiCards[cardIndex] = drawnCard!;
      topDiscardCard = oldCard;
      debugPrint('🔄 $currentPlayer tauscht: Position $cardIndex ($oldCard → ${drawnCard!})');
    }

    drawnCard = null;
    nextTurn();
  }

  String executeMultiSwap(List<int> selectedIndices) {
    if (drawnCard == null || selectedIndices.isEmpty) return 'Fehler: Keine Karte oder Auswahl';

    final currentCards = currentPlayer == 'player' ? playerCards : aiCards;

    // Prüfen ob alle ausgewählten Karten den gleichen Wert haben
    final firstValue = currentCards[selectedIndices.first];
    final allSame = selectedIndices.every((index) => currentCards[index] == firstValue);

    if (allSame) {
      // ERFOLG: Multi-Swap durchführen
      currentCards[selectedIndices.first] = drawnCard!;

      // Restliche Positionen werden leer
      for (int i = 1; i < selectedIndices.length; i++) {
        currentCards[selectedIndices[i]] = 'LEER';
      }

      topDiscardCard = firstValue;
      drawnCard = null;

      debugPrint('✅ MULTI-SWAP: ${selectedIndices.length} × $firstValue → ${currentCards[selectedIndices.first]}');
      nextTurn();
      return 'DUETT/TRIPLETT! ${selectedIndices.length} × $firstValue → ${currentCards[selectedIndices.first]}';

    } else {
      // FEHLER: Karten sind nicht gleich - Penalty
      final selectedValues = selectedIndices.map((i) => currentCards[i]).toList();
      debugPrint('❌ MULTI-SWAP FEHLER: ${selectedValues.join(", ")} sind nicht gleich');
      return 'FEHLER! Karten sind nicht gleich: ${selectedValues.join(", ")}';
    }
  }

  String getStatusText() {
    if (gamePhase == 'look_at_cards') {
      if (currentPlayer == 'player') {
        return 'Schaue dir 2 deiner Karten an! (${cardsLookedAt}/2)';
      } else {
        return 'KI schaut sich ihre Karten an... (${cardsLookedAt}/2)';
      }
    } else if (gamePhase == 'game_ended') {
      final caller = pawsyCaller == 'player' ? 'Du' : 'KI';
      final playerScore = _calculateScore(playerCards);
      final aiScore = _calculateScore(aiCards);
      final winner = playerScore <= aiScore ? 'Du' : 'KI';
      return 'Spiel beendet! PAWSY von $caller. $winner gewinnst! (Du: $playerScore, KI: $aiScore)';
    } else if (gamePhase == 'pawsy_called') {
      final caller = pawsyCaller == 'player' ? 'Dir' : 'KI';
      final nextPlayer = currentPlayer == 'player' ? 'Du' : 'KI';
      return 'PAWSY gerufen von $caller! $nextPlayer: Noch $remainingTurnsAfterPawsy Zug(e)';
    } else if (drawnCard != null) {
      return 'Gezogene Karte: $drawnCard - Ablegen oder Tauschen?';
    } else if (hasDrawnThisTurn) {
      return 'Karte bereits gezogen - warte auf Aktion';
    } else {
      final currentPlayerName = currentPlayer == 'player' ? 'Du' : 'KI';
      return '$currentPlayerName ${currentPlayer == 'player' ? 'bist' : 'ist'} am Zug! Karte ziehen oder PAWSY! (Turn $turnCounter)';
    }
  }

  int _calculateScore(List<String> cards) {
    return cards.fold(0, (sum, card) {
      if (card == '0') return sum + 0;
      if (card == '13') return sum + 13;
      return sum + (int.tryParse(card) ?? 0);
    });
  }

  // Getters
  bool get isPlayerTurn => currentPlayer == 'player';
  bool get isAITurn => currentPlayer == 'ai';
  bool get isGameEnded => gamePhase == 'game_ended';
  bool get isPawsyPhase => gamePhase == 'pawsy_called';
  bool get canDrawCards => !hasDrawnThisTurn && drawnCard == null && !isGameEnded && gamePhase == 'playing';
}

// Minimal Game Screen
class MinimalGameScreen extends StatefulWidget {
  const MinimalGameScreen({super.key});

  @override
  State<MinimalGameScreen> createState() => _MinimalGameScreenState();
}

class _MinimalGameScreenState extends State<MinimalGameScreen> {
  final MinimalGameController controller = MinimalGameController();
  bool isAIThinking = false;

  // Neue Variablen für Karten-Auswahl
  List<bool> selectedPlayerCards = [false, false, false, false];
  int selectedCardCount = 0;

  @override
  void initState() {
    super.initState();
    _startAIMonitoring();
  }

  void _startAIMonitoring() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1000));

      // NUR in Playing Phase UND wenn KI am Zug ist
      if (mounted &&
          controller.gamePhase == 'playing' &&
          controller.isAITurn &&
          !controller.isGameEnded &&
          !isAIThinking) {
        await _processAITurn();
      }

      return mounted;
    });
  }

  Future<void> _processAITurn() async {
    setState(() {
      isAIThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    // KI-Logik
    if (controller.drawnCard == null) {
      // Erste Aktion: Karte ziehen oder PAWSY
      if (controller.canCallPawsy() && DateTime.now().millisecond % 5 == 0) {
        controller.callPawsy();
        _showMessage('🐾 KI ruft PAWSY!');
      } else {
        // KI zieht zufällig vom Deck oder Discard
        if (DateTime.now().millisecond % 2 == 0) {
          controller.drawFromDeck();
        } else {
          controller.drawFromDiscard();
        }
      }
    } else {
      // Zweite Aktion: Mit gezogener Karte entscheiden
      await Future.delayed(const Duration(milliseconds: 1000));

      // KI entscheidet: 60% Tausch, 40% Ablegen
      if (DateTime.now().millisecond % 10 < 6) {
        controller.swapWithSelectedCard(0); // KI tauscht immer mit Position 0
        _showMessage('🔄 KI tauscht Karte');
      } else {
        controller.discardDrawnCard();
        _showMessage('🗑️ KI legt ab');
      }
    }

    if (mounted) {
      setState(() {
        isAIThinking = false;
      });
    }
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
    if (controller.isPlayerTurn && !controller.isGameEnded && controller.drawnCard == null) {
      setState(() {
        controller.nextTurn();
      });
    }
  }

  void _onDrawFromDeck() {
    if (controller.isPlayerTurn && controller.canDrawCards) {
      setState(() {
        controller.drawFromDeck();
      });
    }
  }

  void _onDrawFromDiscard() {
    if (controller.isPlayerTurn && controller.canDrawCards) {
      setState(() {
        controller.drawFromDiscard();
      });
    }
  }

  void _onDiscardCard() {
    if (controller.isPlayerTurn && controller.drawnCard != null) {
      setState(() {
        controller.discardDrawnCard();
      });
      _showMessage('🗑️ Karte abgelegt');
    }
  }

  void _onSwapCard() {
    if (controller.isPlayerTurn && controller.drawnCard != null) {
      final selectedIndices = _getSelectedIndices();

      if (selectedIndices.isEmpty) {
        _showMessage('❌ Keine Karte ausgewählt!');
        return;
      }

      if (selectedIndices.length == 1) {
        // Normaler Tausch
        setState(() {
          controller.swapWithSelectedCard(selectedIndices.first);
          _resetSelection();
        });
        _showMessage('🔄 Karte getauscht');
      } else {
        // Multi-Swap
        final result = controller.executeMultiSwap(selectedIndices);

        if (result.startsWith('DUETT') || result.startsWith('TRIPLETT')) {
          setState(() {
            _resetSelection();
          });
          _showMessage('✅ $result');
        } else {
          _showMessage('❌ $result');
          // Bei Fehler: Karten 3 Sekunden aufdecken
          setState(() {
            for (int index in selectedIndices) {
              // Hier würden wir die Karten aufdecken (später implementieren)
            }
          });

          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              controller.discardDrawnCard(); // Penalty: Karte ablegen
              _resetSelection();
            });
          });
        }
      }
    }
  }

  void _onCardTap(int cardIndex) {
    if (controller.gamePhase == 'look_at_cards' && controller.isPlayerTurn && controller.cardsLookedAt < 2) {
      // Look-at-Cards Phase
      setState(() {
        controller.lookAtCard(cardIndex);
      });
    } else if (controller.isPlayerTurn && controller.drawnCard != null && controller.playerCards[cardIndex] != 'LEER') {
      // Normale Karten-Auswahl Phase
      setState(() {
        selectedPlayerCards[cardIndex] = !selectedPlayerCards[cardIndex];
        selectedCardCount = selectedPlayerCards.where((selected) => selected).length;
      });
    }
  }

  void _resetSelection() {
    selectedPlayerCards = [false, false, false, false];
    selectedCardCount = 0;
  }

  List<int> _getSelectedIndices() {
    final indices = <int>[];
    for (int i = 0; i < selectedPlayerCards.length; i++) {
      if (selectedPlayerCards[i]) indices.add(i);
    }
    return indices;
  }

  void _restartGame() {
    setState(() {
      controller.resetGame();
      isAIThinking = false;
      _resetSelection();
    });
    _showMessage('🔄 Spiel neu gestartet!');
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildCard(String value, bool isVisible, {bool isSelected = false, bool isSelectable = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          color: value == 'LEER'
              ? Colors.grey[300]
              : (isVisible ? Colors.white : Colors.blue[900]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.purple
                : (isSelectable ? Colors.yellow : Colors.black),
            width: isSelected ? 4 : (isSelectable ? 3 : 1),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : (isSelectable ? [
            BoxShadow(
              color: Colors.yellow.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ] : null),
        ),
        child: Center(
          child: value == 'LEER'
              ? Icon(Icons.remove, color: Colors.grey[600], size: 24)
              : Text(
            isVisible ? value : '?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isVisible ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerArea(String playerName, List<String> cards, bool isCurrentPlayer, bool showCards, {bool canSelectCards = false}) {
    List<bool> cardVisibility;

    if (playerName == 'You') {
      cardVisibility = showCards ? [true, true, true, true] : controller.playerCardsVisible;
    } else {
      cardVisibility = showCards ? [true, true, true, true] : controller.aiCardsVisible;
    }

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
              final index = entry.key;
              final card = entry.value;
              final isVisible = cardVisibility[index];

              // Bestimme ob Karte auswählbar ist
              bool isSelectable = false;
              bool isSelected = false;

              if (controller.gamePhase == 'look_at_cards' && playerName == 'You' && controller.isPlayerTurn && controller.cardsLookedAt < 2) {
                isSelectable = !isVisible && card != 'LEER';
              } else if (canSelectCards && !isVisible && card != 'LEER') {
                isSelectable = true;
                isSelected = selectedPlayerCards[index];
              }

              return Padding(
                padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                child: _buildCard(
                  card,
                  isVisible,
                  isSelected: isSelected,
                  isSelectable: isSelectable,
                  onTap: () => _onCardTap(index),
                ),
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
        title: const Text('PAWSY - Mit Karten ziehen'),
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
                if (controller.drawnCard != null)
                  Text(
                    'Gezogene Karte: ${controller.drawnCard} | Ausgewählt: $selectedCardCount',
                    style: const TextStyle(color: Colors.yellow, fontSize: 12),
                  ),
                if (controller.pawsyCaller != null)
                  Text(
                    'PAWSY Caller: ${controller.pawsyCaller} | Remaining: ${controller.remainingTurnsAfterPawsy}',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Deck Area (nur in Playing Phase)
          if (controller.gamePhase == 'playing' && !controller.isGameEnded) ...[
            const Text(
              'Deck Area',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ziehstapel
                Column(
                  children: [
                    const Text('Deck', style: TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: controller.isPlayerTurn && controller.canDrawCards ? _onDrawFromDeck : null,
                      child: Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: controller.canDrawCards && controller.isPlayerTurn ? Colors.blue[700] : Colors.blue[900],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.canDrawCards && controller.isPlayerTurn ? Colors.yellow : Colors.black,
                            width: controller.canDrawCards && controller.isPlayerTurn ? 3 : 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.layers, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Ablagestapel
                Column(
                  children: [
                    const Text('Discard', style: TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: controller.isPlayerTurn && controller.canDrawCards ? _onDrawFromDiscard : null,
                      child: Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.canDrawCards && controller.isPlayerTurn ? Colors.yellow : Colors.black,
                            width: controller.canDrawCards && controller.isPlayerTurn ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            controller.topDiscardCard,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Gezogene Karte + Aktionen
          if (controller.drawnCard != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Gezogen: ', style: TextStyle(color: Colors.white, fontSize: 16)),
                      Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            controller.drawnCard!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (controller.isPlayerTurn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _onDiscardCard,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Ablegen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _onSwapCard,
                          icon: const Icon(Icons.swap_horiz, size: 16),
                          label: Text(selectedCardCount > 1 ? 'Multi-Swap ($selectedCardCount)' : 'Tausch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedCardCount > 1 ? Colors.purple : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Aktions-Buttons (nur in Playing Phase)
          if (controller.gamePhase == 'playing' && !controller.isGameEnded) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (controller.drawnCard == null) ...[
                  ElevatedButton.icon(
                    onPressed: controller.isPlayerTurn ? _onPlayerNextTurn : null,
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
              ],
            ),
            const SizedBox(height: 16),
          ],

          const Spacer(),

          // Player Bereich
          _buildPlayerArea(
            'You',
            controller.playerCards,
            controller.isPlayerTurn,
            controller.isGameEnded,
            canSelectCards: controller.drawnCard != null && controller.isPlayerTurn,
          ),

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