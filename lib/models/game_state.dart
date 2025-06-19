// lib/models/game_state.dart
import 'player.dart';
import 'card.dart';

enum GamePhase { dealing, playing, gameOver }

class GameState {
  final List<Player> players;
  final List<int> deck;
  final GameCard? discardPile;
  final GameCard? drawnCard;
  final GamePhase phase;
  final int currentPlayerIndex;
  final bool showDrawnCard;
  final bool isDrawingFromDiscard;

  // Dealing Animation State
  final int currentDealingCard;
  final int dealingToPlayerIndex;

  const GameState({
    required this.players,
    required this.deck,
    this.discardPile,
    this.drawnCard,
    this.phase = GamePhase.dealing,
    this.currentPlayerIndex = 0,
    this.showDrawnCard = false,
    this.isDrawingFromDiscard = false,
    this.currentDealingCard = 0,
    this.dealingToPlayerIndex = 0,
  });

  // Getter für einfachen Zugriff
  Player get currentPlayer => players[currentPlayerIndex];

  Player get humanPlayer => players.firstWhere((p) => p.isHuman);

  bool get isDealing => phase == GamePhase.dealing;

  bool get isPlaying => phase == GamePhase.playing;

  bool get isGameOver => phase == GamePhase.gameOver;

  bool get isHumanTurn => currentPlayer.isHuman;

  int get playerCount => players.length;

  bool get canDrawCard => isPlaying && !showDrawnCard && !isDrawingFromDiscard;

  GameState copyWith({
    List<Player>? players,
    List<int>? deck,
    GameCard? discardPile,
    GameCard? drawnCard,
    GamePhase? phase,
    int? currentPlayerIndex,
    bool? showDrawnCard,
    bool? isDrawingFromDiscard,
    int? currentDealingCard,
    int? dealingToPlayerIndex,
  }) {
    return GameState(
      players: players ?? this.players,
      deck: deck ?? this.deck,
      discardPile: discardPile ?? this.discardPile,
      drawnCard: drawnCard ?? this.drawnCard,
      phase: phase ?? this.phase,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      showDrawnCard: showDrawnCard ?? this.showDrawnCard,
      isDrawingFromDiscard: isDrawingFromDiscard ?? this.isDrawingFromDiscard,
      currentDealingCard: currentDealingCard ?? this.currentDealingCard,
      dealingToPlayerIndex: dealingToPlayerIndex ?? this.dealingToPlayerIndex,
    );
  }
}
