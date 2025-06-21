// lib/controllers/game_controller.dart - REFACTORED VERSION
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../utils/constants.dart';
import '../services/card_service.dart';
import '../services/turn_service.dart';
import '../services/animation_service.dart';
import '../controllers/action_controller.dart';
import '../controllers/deck_controller.dart';
import '../controllers/ai_controller.dart';

class GameController extends ChangeNotifier {
  GameState _gameState = const GameState(players: [], deck: []);

  GameState get gameState => _gameState;

  // =============================================================================
  // GAME INITIALIZATION
  // =============================================================================

  void startNewGame(int playerCount) {
    List<int> deck = DeckController.createCaboDeck();

    List<Player> players = [];
    for (int i = 0; i < playerCount; i++) {
      players.add(
        Player(
          name: i == 0 ? GameStrings.humanPlayer : GameStrings.aiPlayer(i + 1),
          cards: [],
          playerIndex: i,
          isHuman: i == 0,
        ),
      );
    }

    _gameState = TurnService.initializeNewGame(players, deck);

    print('🎮 Neues Spiel gestartet mit $playerCount Spielern');
    notifyListeners();
  }

  // =============================================================================
  // DEALING PHASE
  // =============================================================================

  void dealNextCard() {
    if (_gameState.currentDealingCard >=
        _gameState.playerCount * GameConstants.maxCardsPerPlayer) {
      _finishDealing();
    } else {
      _dealSingleCard();
    }
    notifyListeners();
  }

  void _finishDealing() {
    int? discardCard = DeckController.drawCard(_gameState.deck);
    if (discardCard != null) {
      _gameState = _gameState.copyWith(
        phase: GamePhase.lookingAtCards,
        discardPile: GameCard(value: discardCard, isVisible: true),
      );
      print('✅ Alle Karten ausgeteilt! Ablagestapel: $discardCard');
    }
  }

  void _dealSingleCard() {
    int? card = DeckController.drawCard(_gameState.deck);
    if (card != null) {
      List<Player> updatedPlayers = List.from(_gameState.players);
      Player currentPlayer = updatedPlayers[_gameState.dealingToPlayerIndex];

      List<GameCard> updatedCards = List.from(currentPlayer.cards);
      updatedCards.add(GameCard(value: card, isVisible: false));

      updatedPlayers[_gameState.dealingToPlayerIndex] = currentPlayer.copyWith(
        cards: updatedCards,
      );

      _gameState = _gameState.copyWith(
        players: updatedPlayers,
        currentDealingCard: _gameState.currentDealingCard + 1,
        dealingToPlayerIndex:
            (_gameState.dealingToPlayerIndex + 1) % _gameState.playerCount,
      );
    }
  }

  // =============================================================================
  // LOOKING AT CARDS PHASE
  // =============================================================================

  void lookAtStartCard(int cardIndex) {
    _gameState = CardService.lookAtStartCard(_gameState, cardIndex);

    if (_gameState.cardsLookedAt >= 2) {
      Future.delayed(const Duration(seconds: 2), () {
        _startPlayingPhase();
      });
    }
    notifyListeners();
  }

  void _startPlayingPhase() {
    _gameState = CardService.hideAllPlayerCards(_gameState);
    _gameState = TurnService.startPlayingPhase(_gameState);

    print(
      '🎮 Spielphase gestartet! ${_gameState.currentPlayer.name} ist dran.',
    );
    notifyListeners();

    if (!_gameState.currentPlayer.isHuman) {
      _handleAITurn();
    }
  }

  // =============================================================================
  // HUMAN PLAYER ACTIONS
  // =============================================================================

  void drawCardFromDeck() {
    _gameState = CardService.drawCardFromDeck(_gameState);
    print('🎴 Karte vom Deck gezogen: ${_gameState.drawnCard?.value}');
    notifyListeners();
  }

  void drawCardFromDiscard() {
    _gameState = CardService.drawCardFromDiscard(_gameState);
    print('🎴 Karte vom Ablagestapel gezogen: ${_gameState.drawnCard?.value}');
    notifyListeners();
  }

  void finishDrawingFromDiscard() {
    _gameState = CardService.finishDrawingFromDiscard(_gameState);
    notifyListeners();
  }

  void swapWithPlayerCard(int cardIndex) {
    GameCard? drawnCard = _gameState.drawnCard;
    _gameState = CardService.swapWithPlayerCard(_gameState, cardIndex);

    if (drawnCard?.isActionCard == true) {
      _handleActionCard(
        drawnCard!.value,
        false,
      ); // Nicht aktivierbar wenn getauscht
    } else {
      _nextPlayerTurn();
    }

    print('🔄 Karte ${drawnCard?.value} mit Spielerkarte getauscht');
    notifyListeners();
  }

  void discardDrawnCard() {
    GameCard? drawnCard = _gameState.drawnCard;
    bool wasDrawnFromDeck = !_gameState.isDrawingFromDiscard;

    _gameState = CardService.discardDrawnCard(_gameState);

    if (drawnCard?.isActionCard == true && wasDrawnFromDeck) {
      _handleActionCard(
        drawnCard!.value,
        true,
      ); // Aktivierbar wenn direkt abgelegt
    } else {
      _nextPlayerTurn();
    }

    print('🗂️ Karte ${drawnCard?.value} auf Ablagestapel gelegt');
    notifyListeners();
  }

  void callPawsy() {
    _gameState = TurnService.callPawsy(_gameState);
    print('🐾 PAWSY gerufen! Spiel beendet.');
    _calculateFinalScores();
    notifyListeners();
  }

  // =============================================================================
  // ACTION CARDS - Delegiert an ActionController
  // =============================================================================

  void _handleActionCard(int cardValue, bool canActivate) {
    if (canActivate && _gameState.currentPlayer.isHuman) {
      _gameState = ActionController.startActionCard(_gameState, cardValue);
      print('🎯 Aktionskarte ${cardValue} aktiviert');
    } else {
      _nextPlayerTurn();
    }
    notifyListeners();
  }

  void selectCardForScout(int cardIndex) {
    _gameState = ActionController.selectCardForScout(_gameState, cardIndex);

    Future.delayed(const Duration(seconds: 2), () {
      _gameState = ActionController.finishScoutAction(_gameState);
      _nextPlayerTurn();
      notifyListeners();
    });

    print('🔍 SCOUT: Karte ${cardIndex + 1} erkundet');
    notifyListeners();
  }

  void selectPlayerForStalk(int playerIndex) {
    _gameState = ActionController.selectPlayerForStalk(_gameState, playerIndex);
    print('👁️ STALK: Spieler ${_gameState.players[playerIndex].name} gewählt');
    notifyListeners();
  }

  void selectCardForStalk(int cardIndex) {
    _gameState = ActionController.selectCardForStalk(_gameState, cardIndex);

    Future.delayed(const Duration(seconds: 2), () {
      _gameState = ActionController.finishStalkAction(_gameState);
      _nextPlayerTurn();
      notifyListeners();
    });

    print('👁️ STALK: Karte ${cardIndex + 1} verfolgt');
    notifyListeners();
  }

  void selectPlayerForSwitch(int playerIndex) {
    _gameState = ActionController.selectPlayerForSwitch(
      _gameState,
      playerIndex,
    );
    print('🔄 SWITCH: Spieler ${_gameState.players[playerIndex].name} gewählt');
    notifyListeners();
  }

  void selectOwnCardForSwitch(int cardIndex) {
    _gameState = ActionController.selectOwnCardForSwitch(_gameState, cardIndex);
    print('🔄 SWITCH: Eigene Karte ${cardIndex + 1} gewählt');
    notifyListeners();
  }

  void selectOpponentCardForSwitch(int cardIndex) {
    _gameState = ActionController.selectOpponentCardForSwitch(
      _gameState,
      cardIndex,
    );

    Future.delayed(const Duration(milliseconds: 2200), () {
      _gameState = ActionController.finishSwitchAction(_gameState, cardIndex);
      _nextPlayerTurn();
      notifyListeners();
    });

    print('🔄 SWITCH: Animation gestartet');
    notifyListeners();
  }

  void cancelActionCard() {
    _gameState = ActionController.cancelActionCard(_gameState);
    _nextPlayerTurn();
    notifyListeners();
  }

  // =============================================================================
  // AI PLAYER ACTIONS
  // =============================================================================

  void _handleAITurn() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!_gameState.isPlaying || _gameState.hasDrawnCardThisTurn) return;

      AIDecision decision = AIController.makeDecision(_gameState);
      _executeAIDecision(decision);
    });
  }

  void _executeAIDecision(AIDecision decision) {
    switch (decision.action) {
      case AIAction.callPawsy:
        callPawsy();
        break;
      case AIAction.drawFromDeck:
        _aiDrawFromDeck();
        break;
      case AIAction.drawFromDiscard:
        _aiDrawFromDiscard();
        break;
      default:
        _nextPlayerTurn();
        break;
    }
  }

  void _aiDrawFromDeck() {
    _gameState = CardService.aiDrawFromDeck(_gameState);
    print('🤖 KI zog vom Deck: ${_gameState.drawnCard?.value}');

    Future.delayed(const Duration(milliseconds: 1000), () {
      _handleAIDrawnCard();
    });
    notifyListeners();
  }

  void _aiDrawFromDiscard() {
    _gameState = CardService.aiDrawFromDiscard(_gameState);
    print('🤖 KI zog vom Ablagestapel: ${_gameState.drawnCard?.value}');

    Future.delayed(const Duration(milliseconds: 1000), () {
      _handleAIDrawnCard();
    });
    notifyListeners();
  }

  void _handleAIDrawnCard() {
    AIDecision decision = AIController.makeDiscardDecision(_gameState);

    switch (decision.action) {
      case AIAction.swapCard:
        _gameState = CardService.aiSwapCard(_gameState, decision.cardIndex!);
        print('🤖 KI tauschte Karte ${decision.cardIndex! + 1}');
        break;
      case AIAction.discardCard:
        _gameState = CardService.aiDiscardCard(_gameState);
        print('🤖 KI legte Karte ab');
        break;
      default:
        _gameState = CardService.aiDiscardCard(_gameState);
        break;
    }

    _nextPlayerTurn();
    notifyListeners();
  }

  // =============================================================================
  // TURN MANAGEMENT
  // =============================================================================

  void _nextPlayerTurn() {
    _gameState = TurnService.nextPlayerTurn(_gameState);
    print('🔄 ${_gameState.currentPlayer.name} ist dran');

    if (!_gameState.currentPlayer.isHuman) {
      _handleAITurn();
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  void _calculateFinalScores() {
    Map<String, int> scores = TurnService.calculateFinalScores(_gameState);
    for (String player in scores.keys) {
      print('$player: ${scores[player]} Punkte');
    }
  }

  void debugRevealHumanCards() {
    _gameState = CardService.debugRevealHumanCards(_gameState);
    notifyListeners();
  }
}
