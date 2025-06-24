import 'dart:async';

class MultiSwapController {

  static MultiSwapResult executeMultiSwap({
    required List<String> playerCards,
    required List<int> selectedIndices,
    required String drawnCard,
  }) {
    if (selectedIndices.isEmpty) {
      return MultiSwapResult.failure('Keine Karten ausgewählt');
    }

    // Prüfen ob alle ausgewählten Karten den gleichen Wert haben
    final selectedValues = selectedIndices.map((i) => playerCards[i]).toList();
    final firstValue = selectedValues.first;
    final allSame = selectedValues.every((value) => value == firstValue);

    if (allSame) {
      return _executeSuccessfulSwap(playerCards, selectedIndices, drawnCard, firstValue);
    } else {
      return _executeFailedSwap(selectedIndices, selectedValues);
    }
  }

  static MultiSwapResult _executeSuccessfulSwap(
      List<String> playerCards,
      List<int> selectedIndices,
      String drawnCard,
      String oldValue,
      ) {
    final newPlayerCards = List<String>.from(playerCards);

    // Erste Position bekommt neue Karte
    newPlayerCards[selectedIndices.first] = drawnCard;

    // Restliche Positionen werden leer
    for (int i = 1; i < selectedIndices.length; i++) {
      newPlayerCards[selectedIndices[i]] = 'LEER';
    }

    return MultiSwapResult.success(
      newPlayerCards: newPlayerCards,
      discardedCard: oldValue,
      message: 'DUETT/TRIPLETT! ${selectedIndices.length} × $oldValue → $drawnCard',
    );
  }

  static MultiSwapResult _executeFailedSwap(
      List<int> selectedIndices,
      List<String> selectedValues,
      ) {
    return MultiSwapResult.penalty(
      revealedIndices: selectedIndices,
      revealedValues: selectedValues,
      message: 'FEHLER! Karten sind nicht gleich: ${selectedValues.join(", ")}',
    );
  }
}

class MultiSwapResult {
  final bool isSuccess;
  final bool isPenalty;
  final List<String>? newPlayerCards;
  final String? discardedCard;
  final List<int>? revealedIndices;
  final List<String>? revealedValues;
  final String message;

  MultiSwapResult._({
    required this.isSuccess,
    required this.isPenalty,
    this.newPlayerCards,
    this.discardedCard,
    this.revealedIndices,
    this.revealedValues,
    required this.message,
  });

  factory MultiSwapResult.success({
    required List<String> newPlayerCards,
    required String discardedCard,
    required String message,
  }) {
    return MultiSwapResult._(
      isSuccess: true,
      isPenalty: false,
      newPlayerCards: newPlayerCards,
      discardedCard: discardedCard,
      message: message,
    );
  }

  factory MultiSwapResult.penalty({
    required List<int> revealedIndices,
    required List<String> revealedValues,
    required String message,
  }) {
    return MultiSwapResult._(
      isSuccess: false,
      isPenalty: true,
      revealedIndices: revealedIndices,
      revealedValues: revealedValues,
      message: message,
    );
  }

  factory MultiSwapResult.failure(String message) {
    return MultiSwapResult._(
      isSuccess: false,
      isPenalty: false,
      message: message,
    );
  }
}