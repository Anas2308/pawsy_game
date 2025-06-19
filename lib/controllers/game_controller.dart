// lib/controllers/game_controller.dart
class GameController extends ChangeNotifier {
  GameState _gameState;

  void startNewGame() {}
  void drawCard() {}
  void playCard() {}
  void nextPlayer() {}
}

// lib/controllers/deck_controller.dart
class DeckController {
  static List<int> createCaboDeck() {}
  static void shuffle(List<int> deck) {}
  static int drawCard(List<int> deck) {}
}
