// lib/models/game_state.dart
import 'player.dart';
import 'card.dart';

enum GamePhase { dealing, lookingAtCards, playing, gameOver }

enum ActionCardPhase {
  none,
  scoutSelectCard,
  stalkSelectPlayer,
  stalkSelectCard,
  switchSelectPlayer,
  switchSelectOwnCard,
  switchSelectOpponentCard,
}

enum AnimationPhase { none, highlighting, switching }

class GameState {
  final List<Player> players;
  final List<int> deck;
  final GameCard? discardPile;
  final GameCard? drawnCard;
  final GamePhase phase;
  final int currentPlayerIndex;
  final bool showDrawnCard;
  final bool isDrawingFromDiscard;
  final bool hasDrawnCardThisTurn;
  final int cardsLookedAt;
  final int currentDealingCard;
  final int dealingToPlayerIndex;

  // Aktionskarten-Status
  final ActionCardPhase actionPhase;
  final int? activeActionCard;
  final bool canActivateAction;
  final int? selectedPlayerIndex;
  final int? selectedCardIndex;

  // Temporäre Karten-Aufdeckung (playerIndex, cardIndex)
  final int? revealedPlayerIndex;
  final int? revealedCardIndex;

  // Animation States
  final AnimationPhase animationPhase;
  final int? highlightedPlayerIndex;
  final int? highlightedCardIndex;
  final List<(int, int)> switchingCards; // (playerIndex, cardIndex) pairs
  final bool isAnimating;

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
    this.actionPhase = ActionCardPhase.none,
    this.activeActionCard,
    this.canActivateAction = false,
    this.selectedPlayerIndex,
    this.selectedCardIndex,
    this.revealedPlayerIndex,
    this.revealedCardIndex,
    this.animationPhase = AnimationPhase.none,
    this.highlightedPlayerIndex,
    this.highlightedCardIndex,
    this.switchingCards = const [],
    this.isAnimating = false,
  });

  Player get currentPlayer => players[currentPlayerIndex];

  Player get humanPlayer => players.firstWhere((p) => p.isHuman);

  bool get isDealing => phase == GamePhase.dealing;

  bool get isLookingAtCards => phase == GamePhase.lookingAtCards;

  bool get isPlaying => phase == GamePhase.playing;

  bool get isGameOver => phase == GamePhase.gameOver;

  bool get isHumanTurn => currentPlayer.isHuman;

  int get playerCount => players.length;

  bool get canDrawCard =>
      isPlaying &&
      !showDrawnCard &&
      !isDrawingFromDiscard &&
      actionPhase == ActionCardPhase.none;

  bool get canCallPawsy =>
      isPlaying && !hasDrawnCardThisTurn && actionPhase == ActionCardPhase.none;

  bool get isInActionPhase => actionPhase != ActionCardPhase.none;

  String get actionPhaseDescription {
    switch (actionPhase) {
      case ActionCardPhase.scoutSelectCard:
        return "SCOUT: Wähle eine deiner Karten zum Erkunden";
      case ActionCardPhase.stalkSelectPlayer:
        return "STALK: Wähle einen Gegner";
      case ActionCardPhase.stalkSelectCard:
        return "STALK: Wähle eine Karte des Gegners";
      case ActionCardPhase.switchSelectPlayer:
        return "SWITCH: Wähle einen Gegner";
      case ActionCardPhase.switchSelectOwnCard:
        return "SWITCH: Wähle eine deiner Karten";
      case ActionCardPhase.switchSelectOpponentCard:
        return "SWITCH: Wähle eine Gegnerkarte";
      default:
        return "";
    }
  }

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
    ActionCardPhase? actionPhase,
    int? activeActionCard,
    bool? canActivateAction,
    int? selectedPlayerIndex,
    int? selectedCardIndex,
    int? revealedPlayerIndex,
    int? revealedCardIndex,
    AnimationPhase? animationPhase,
    int? highlightedPlayerIndex,
    int? highlightedCardIndex,
    List<(int, int)>? switchingCards,
    bool? isAnimating,
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
      actionPhase: actionPhase ?? this.actionPhase,
      activeActionCard: activeActionCard ?? this.activeActionCard,
      canActivateAction: canActivateAction ?? this.canActivateAction,
      selectedPlayerIndex: selectedPlayerIndex ?? this.selectedPlayerIndex,
      selectedCardIndex: selectedCardIndex ?? this.selectedCardIndex,
      revealedPlayerIndex: revealedPlayerIndex ?? this.revealedPlayerIndex,
      revealedCardIndex: revealedCardIndex ?? this.revealedCardIndex,
      animationPhase: animationPhase ?? this.animationPhase,
      highlightedPlayerIndex:
          highlightedPlayerIndex ?? this.highlightedPlayerIndex,
      highlightedCardIndex: highlightedCardIndex ?? this.highlightedCardIndex,
      switchingCards: switchingCards ?? this.switchingCards,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}
