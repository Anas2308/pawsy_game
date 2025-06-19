// lib/models/game_state.dart
import 'player.dart';
import 'card.dart';

enum GamePhase {
  dealing,
  lookingAtCards, // Neue Phase: 2 Karten anschauen
  playing,
  gameOver,
}

class GameState {
  final List<Player> players;
  final List<int> deck;
  final GameCard? discardPile;
  final GameCard? drawnCard;
  final GamePhase phase;
  final int currentPlayerIndex;
  final bool showDrawnCard;
  final bool isDrawingFromDiscard;
  final bool hasDrawnCardThisTurn; // Neue Regel: Hat Karte gezogen diese Runde
  final int cardsLookedAt; // Anzahl angeschauter Karten beim Start

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
    this.hasDrawnCardThisTurn = false,
    this.cardsLookedAt = 0,
    this.currentDealingCard = 0,
    this.dealingToPlayerIndex = 0,
  });

  // Getter für einfachen Zugriff
  Player get currentPlayer => players[currentPlayerIndex];

  Player get humanPlayer => players.firstWhere((p) => p.isHuman);

  bool get isDealing => phase == GamePhase.dealing;

  bool get isLookingAtCards => phase == GamePhase.lookingAtCards;

  bool get isPlaying => phase == GamePhase.playing;

  bool get isGameOver => phase == GamePhase.gameOver;

  bool get isHumanTurn => currentPlayer.isHuman;

  int get playerCount => players.length;

  bool get canDrawCard => isPlaying && !showDrawnCard && !isDrawingFromDiscard;

  bool get canCallPawsy =>
      isPlaying && !hasDrawnCardThisTurn && humanPlayer.visibleCardsCount >= 2;

  GameState copyWith({
    List<Player>? players,
    List<int>? deck,
    GameCard? discardPile,
    GameCard? drawnCard,
    GamePhase? phase,
    int? currentPlayerIndex,
    bool? showDrawnCard,
    bool? isDrawingFromDiscard,
    bool? hasDrawnCardThisTurn,
    int? cardsLookedAt,
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
      hasDrawnCardThisTurn: hasDrawnCardThisTurn ?? this.hasDrawnCardThisTurn,
      cardsLookedAt: cardsLookedAt ?? this.cardsLookedAt,
      currentDealingCard: currentDealingCard ?? this.currentDealingCard,
      dealingToPlayerIndex: dealingToPlayerIndex ?? this.dealingToPlayerIndex,
    );
  }
}
