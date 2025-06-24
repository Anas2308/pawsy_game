class ActionCardController {

  static bool isActionCard(String cardValue) {
    final value = int.tryParse(cardValue) ?? -1;
    return value >= 6 && value <= 11;
  }

  static ActionCardType getActionType(String cardValue) {
    final value = int.tryParse(cardValue) ?? -1;

    if (value == 6 || value == 7) return ActionCardType.look;
    if (value == 8 || value == 9) return ActionCardType.spy;
    if (value == 10 || value == 11) return ActionCardType.trade;

    return ActionCardType.none;
  }

  static String getActionName(ActionCardType type) {
    switch (type) {
      case ActionCardType.look:
        return 'LOOK - Eigene Karte anschauen';
      case ActionCardType.spy:
        return 'SPY - Gegnerkarte anschauen';
      case ActionCardType.trade:
        return 'TRADE - Karte mit Gegner tauschen';
      case ActionCardType.none:
        return '';
    }
  }

  static String getActionDescription(ActionCardType type) {
    switch (type) {
      case ActionCardType.look:
        return 'Wähle eine deiner verdeckten Karten zum Anschauen';
      case ActionCardType.spy:
        return 'Wähle eine Gegnerkarte zum Anschauen';
      case ActionCardType.trade:
        return 'Wähle eine deiner Karten und eine Gegnerkarte zum Tauschen';
      case ActionCardType.none:
        return '';
    }
  }

  static ActionCardResult executeLookAction(List<String> playerCards, int cardIndex) {
    if (cardIndex < 0 || cardIndex >= playerCards.length) {
      return ActionCardResult.failure('Ungültiger Kartenindex');
    }

    final cardValue = playerCards[cardIndex];

    return ActionCardResult.success(
      message: 'Du schaust dir Karte ${cardIndex + 1} an: $cardValue',
      revealedCard: cardValue,
      revealedIndex: cardIndex,
    );
  }

  static ActionCardResult executeSpyAction(List<String> aiCards, int cardIndex) {
    if (cardIndex < 0 || cardIndex >= aiCards.length) {
      return ActionCardResult.failure('Ungültiger Kartenindex');
    }

    final cardValue = aiCards[cardIndex];

    return ActionCardResult.success(
      message: 'Du schaust dir KI-Karte ${cardIndex + 1} an: $cardValue',
      revealedCard: cardValue,
      revealedIndex: cardIndex,
    );
  }

  static ActionCardResult executeTradeAction(
      List<String> playerCards,
      List<String> aiCards,
      int playerCardIndex,
      int aiCardIndex
      ) {
    if (playerCardIndex < 0 || playerCardIndex >= playerCards.length ||
        aiCardIndex < 0 || aiCardIndex >= aiCards.length) {
      return ActionCardResult.failure('Ungültige Kartenindizes');
    }

    final playerCard = playerCards[playerCardIndex];
    final aiCard = aiCards[aiCardIndex];

    return ActionCardResult.success(
      message: 'Getauscht: Deine Karte $playerCard ↔ KI-Karte $aiCard',
      tradePlayerIndex: playerCardIndex,
      tradeAIIndex: aiCardIndex,
      tradePlayerCard: playerCard,
      tradeAICard: aiCard,
    );
  }
}

enum ActionCardType {
  none,
  look,
  spy,
  trade,
}

class ActionCardResult {
  final bool isSuccess;
  final String message;
  final String? revealedCard;
  final int? revealedIndex;
  final int? tradePlayerIndex;
  final int? tradeAIIndex;
  final String? tradePlayerCard;
  final String? tradeAICard;

  ActionCardResult._({
    required this.isSuccess,
    required this.message,
    this.revealedCard,
    this.revealedIndex,
    this.tradePlayerIndex,
    this.tradeAIIndex,
    this.tradePlayerCard,
    this.tradeAICard,
  });

  factory ActionCardResult.success({
    required String message,
    String? revealedCard,
    int? revealedIndex,
    int? tradePlayerIndex,
    int? tradeAIIndex,
    String? tradePlayerCard,
    String? tradeAICard,
  }) {
    return ActionCardResult._(
      isSuccess: true,
      message: message,
      revealedCard: revealedCard,
      revealedIndex: revealedIndex,
      tradePlayerIndex: tradePlayerIndex,
      tradeAIIndex: tradeAIIndex,
      tradePlayerCard: tradePlayerCard,
      tradeAICard: tradeAICard,
    );
  }

  factory ActionCardResult.failure(String message) {
    return ActionCardResult._(
      isSuccess: false,
      message: message,
    );
  }
}