// lib/models/player.dart
import 'card.dart';

class Player {
  final String name;
  final List<GameCard> cards;
  final bool isCurrentPlayer;
  final bool isHuman;
  final int playerIndex;

  const Player({
    required this.name,
    required this.cards,
    required this.playerIndex,
    this.isCurrentPlayer = false,
    this.isHuman = false,
  });

  // Spieler-Hilfsmethoden
  int get totalScore => cards.fold(0, (sum, card) => sum + card.value);

  int get visibleCardsCount => cards.where((card) => card.isVisible).length;

  bool get hasCards => cards.isNotEmpty;

  List<GameCard> get visibleCards =>
      cards.where((card) => card.isVisible).toList();

  List<GameCard> get hiddenCards =>
      cards.where((card) => !card.isVisible).toList();

  Player copyWith({
    String? name,
    List<GameCard>? cards,
    bool? isCurrentPlayer,
    bool? isHuman,
    int? playerIndex,
  }) {
    return Player(
      name: name ?? this.name,
      cards: cards ?? this.cards,
      isCurrentPlayer: isCurrentPlayer ?? this.isCurrentPlayer,
      isHuman: isHuman ?? this.isHuman,
      playerIndex: playerIndex ?? this.playerIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          playerIndex == other.playerIndex;

  @override
  int get hashCode => name.hashCode ^ playerIndex.hashCode;
}
