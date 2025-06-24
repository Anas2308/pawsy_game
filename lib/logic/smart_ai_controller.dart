import 'ai_decision_maker.dart';

class SmartAIController {
  final AIDecisionMaker decisionMaker = AIDecisionMaker();

  AIDecision makeDecision({
    required String? drawnCard,
    required String topDiscardCard,
    required bool canDrawFromDeck,
    required bool canDrawFromDiscard,
    required bool canCallPawsy,
  }) {
    return decisionMaker.makeDecision(
      drawnCard: drawnCard,
      topDiscardCard: topDiscardCard,
      canDrawFromDeck: canDrawFromDeck,
      canDrawFromDiscard: canDrawFromDiscard,
      canCallPawsy: canCallPawsy,
    );
  }

  void setInitialCards(List<String> cards) {
    decisionMaker.setInitialCards(cards);
  }

  void observePlayerReveal(int cardIndex, String cardValue) {
    decisionMaker.observePlayerReveal(cardIndex, cardValue);
  }

  void updateCard(int index, String newCard) {
    decisionMaker.updateCard(index, newCard);
  }

  void setCardEmpty(int index) {
    decisionMaker.setCardEmpty(index);
  }

  void reset() {
    decisionMaker.reset();
  }

  // Getters für Kompatibilität
  List<String?> get knownCards => decisionMaker.knownCards;
  List<String> get playerRevealedCards => decisionMaker.playerRevealedCards;
}

class AIDecision {
  final String action;
  final int? cardIndex;
  final List<int>? cardIndices;

  AIDecision._(this.action, {this.cardIndex, this.cardIndices});

  factory AIDecision.drawFromDeck() => AIDecision._('draw_deck');
  factory AIDecision.drawFromDiscard() => AIDecision._('draw_discard');
  factory AIDecision.swap(int index) => AIDecision._('swap', cardIndex: index);
  factory AIDecision.multiSwap(List<int> indices) => AIDecision._('multi_swap', cardIndices: indices);
  factory AIDecision.discard() => AIDecision._('discard');
  factory AIDecision.pawsy() => AIDecision._('pawsy');

  bool get isDrawFromDeck => action == 'draw_deck';
  bool get isDrawFromDiscard => action == 'draw_discard';
  bool get isSwap => action == 'swap';
  bool get isMultiSwap => action == 'multi_swap';
  bool get isDiscard => action == 'discard';
  bool get isPawsy => action == 'pawsy';
}