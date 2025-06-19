class GameCard {
  final int value;
  final bool isVisible;
  final bool isSelected;
  
  // Hilfsmethoden für Kartenfarben, Aktionen etc.
}

// lib/models/player.dart  
class Player {
  final String name;
  final List<GameCard> cards;
  final bool isCurrentPlayer;
  final bool isHuman;
}

// lib/models/game_state.dart
class GameState {
  final List<Player> players;
  final List<int> deck;
  final int discardPile;
  final GameCard? drawnCard;
  final bool isDealing;
}