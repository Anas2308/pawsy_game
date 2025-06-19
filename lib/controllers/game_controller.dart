// lib/controllers/game_controller.dart
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../utils/constants.dart';
import 'deck_controller.dart';

class GameController extends ChangeNotifier {
  GameState _gameState = const GameState(players: [], deck: []);

  GameState get gameState => _gameState;

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

    _gameState = GameState(
      players: players,
      deck: deck,
      phase: GamePhase.dealing,
      currentPlayerIndex: 0,
      currentDealingCard: 0,
      dealingToPlayerIndex: 0,
    );

    print('🎮 Neues Spiel gestartet mit $playerCount Spielern');
    notifyListeners();
  }

  void dealNextCard() {
    if (_gameState.currentDealingCard >=
        _gameState.playerCount * GameConstants.maxCardsPerPlayer) {
      int? discardCard = DeckController.drawCard(_gameState.deck);
      if (discardCard != null) {
        _gameState = _gameState.copyWith(
          phase: GamePhase.lookingAtCards,
          discardPile: GameCard(value: discardCard, isVisible: true),
        );
        print('✅ Alle Karten ausgeteilt! Ablagestapel: $discardCard');
        print('👀 Schaue dir 2 deiner Karten an!');
      }
    } else {
      int? card = DeckController.drawCard(_gameState.deck);
      if (card != null) {
        List<Player> updatedPlayers = List.from(_gameState.players);
        Player currentPlayer = updatedPlayers[_gameState.dealingToPlayerIndex];

        List<GameCard> updatedCards = List.from(currentPlayer.cards);
        updatedCards.add(GameCard(value: card, isVisible: false));

        updatedPlayers[_gameState.dealingToPlayerIndex] = currentPlayer
            .copyWith(cards: updatedCards);

        _gameState = _gameState.copyWith(
          players: updatedPlayers,
          currentDealingCard: _gameState.currentDealingCard + 1,
          dealingToPlayerIndex:
              (_gameState.dealingToPlayerIndex + 1) % _gameState.playerCount,
        );
      }
    }

    notifyListeners();
  }

  void lookAtStartCard(int cardIndex) {
    if (!_gameState.isLookingAtCards || _gameState.cardsLookedAt >= 2) {
      return;
    }

    List<Player> updatedPlayers = List.from(_gameState.players);
    Player humanPlayer = updatedPlayers[0];

    if (cardIndex >= humanPlayer.cards.length) {
      return;
    }

    List<GameCard> updatedCards = List.from(humanPlayer.cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isVisible: true);

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    _gameState = _gameState.copyWith(
      players: updatedPlayers,
      cardsLookedAt: _gameState.cardsLookedAt + 1,
    );

    print(
      '👀 Karte ${cardIndex + 1} angeschaut: ${updatedCards[cardIndex].value}',
    );

    if (_gameState.cardsLookedAt >= 2) {
      Future.delayed(const Duration(seconds: 2), () {
        _startPlayingPhase();
      });
    }

    notifyListeners();
  }

  void _hideAllPlayerCards() {
    List<Player> updatedPlayers = List.from(_gameState.players);
    Player humanPlayer = updatedPlayers[0];

    List<GameCard> updatedCards = humanPlayer.cards
        .map((card) => card.copyWith(isVisible: false))
        .toList();

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    _gameState = _gameState.copyWith(players: updatedPlayers);
  }

  void _startPlayingPhase() {
    _hideAllPlayerCards();

    _gameState = _gameState.copyWith(
      phase: GamePhase.playing,
      hasDrawnCardThisTurn: false,
    );

    print('🎮 Spielphase gestartet! Du bist dran.');
    notifyListeners();
  }

  void drawCardFromDeck() {
    if (!_gameState.canDrawCard) {
      return;
    }

    int? card = DeckController.drawCard(_gameState.deck);
    if (card != null) {
      _gameState = _gameState.copyWith(
        drawnCard: GameCard(value: card, isVisible: true),
        showDrawnCard: true,
        hasDrawnCardThisTurn: true,
      );

      print('🎴 Karte vom Deck gezogen: $card');
      notifyListeners();
    }
  }

  void drawCardFromDiscard() {
    if (_gameState.showDrawnCard ||
        _gameState.isDrawingFromDiscard ||
        _gameState.discardPile == null) {
      return;
    }

    _gameState = _gameState.copyWith(
      drawnCard: GameCard(
        value: _gameState.discardPile!.value,
        isVisible: true,
      ),
      isDrawingFromDiscard: true,
      hasDrawnCardThisTurn: true,
    );

    print(
      '🎴 Karte vom Ablagestapel gezogen: ${_gameState.discardPile!.value}',
    );
    notifyListeners();
  }

  void finishDrawingFromDiscard() {
    _gameState = _gameState.copyWith(
      showDrawnCard: true,
      isDrawingFromDiscard: false,
    );
    notifyListeners();
  }

  void discardDrawnCard() {
    if (_gameState.drawnCard == null) {
      return;
    }

    _gameState = _gameState.copyWith(
      discardPile: _gameState.drawnCard,
      drawnCard: null,
      showDrawnCard: false,
      hasDrawnCardThisTurn: false,
    );

    print('🗂️ Karte ${_gameState.discardPile?.value} auf Ablagestapel gelegt');
    notifyListeners();
  }

  void swapWithPlayerCard(int cardIndex) {
    if (_gameState.drawnCard == null ||
        cardIndex >= GameConstants.maxCardsPerPlayer) {
      return;
    }

    List<Player> updatedPlayers = List.from(_gameState.players);
    Player humanPlayer = updatedPlayers[0];

    if (cardIndex >= humanPlayer.cards.length) {
      return;
    }

    List<GameCard> updatedCards = List.from(humanPlayer.cards);
    GameCard oldCard = updatedCards[cardIndex];

    updatedCards[cardIndex] = _gameState.drawnCard!.copyWith(isVisible: false);

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    _gameState = _gameState.copyWith(
      players: updatedPlayers,
      discardPile: oldCard.copyWith(isVisible: true),
      drawnCard: null,
      showDrawnCard: false,
      hasDrawnCardThisTurn: false,
    );

    print(
      '🔄 Karte ${_gameState.drawnCard?.value} mit Spielerkarte ${oldCard.value} getauscht',
    );

    if (updatedCards[cardIndex].isActionCard) {
      _handleActionCard(updatedCards[cardIndex].value);
    }

    notifyListeners();
  }

  void callPawsy() {
    if (!_gameState.canCallPawsy) {
      return;
    }

    _gameState = _gameState.copyWith(phase: GamePhase.gameOver);

    print('🐾 PAWSY gerufen! Spiel beendet.');
    _calculateFinalScores();
    notifyListeners();
  }

  void _handleActionCard(int cardValue) {
    if (cardValue >= 6 && cardValue <= 7) {
      print('👁️ PEEK-Karte gespielt - schaue dir eine deiner Karten an!');
    } else if (cardValue >= 8 && cardValue <= 9) {
      print('🕵️ SPY-Karte gespielt - schaue dir eine Gegnerkarte an!');
    } else if (cardValue >= 10 && cardValue <= 11) {
      print('🔄 SWAP-Karte gespielt - tausche Karten!');
    } else if (cardValue == 12) {
      print('🃏 WILD-Karte gespielt - spezielle Aktion!');
    }
  }

  void _calculateFinalScores() {
    for (int i = 0; i < _gameState.players.length; i++) {
      Player player = _gameState.players[i];
      int score = player.totalScore;
      print('${player.name}: $score Punkte');
    }
  }

  void revealPlayerCard(int playerIndex, int cardIndex) {
    if (playerIndex >= _gameState.players.length) {
      return;
    }

    List<Player> updatedPlayers = List.from(_gameState.players);
    Player player = updatedPlayers[playerIndex];

    if (cardIndex >= player.cards.length) {
      return;
    }

    List<GameCard> updatedCards = List.from(player.cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isVisible: true);

    updatedPlayers[playerIndex] = player.copyWith(cards: updatedCards);

    _gameState = _gameState.copyWith(players: updatedPlayers);
    notifyListeners();
  }

  void debugRevealHumanCards() {
    if (_gameState.players.isEmpty) {
      return;
    }

    List<Player> updatedPlayers = List.from(_gameState.players);
    Player humanPlayer = updatedPlayers[0];

    List<GameCard> updatedCards = humanPlayer.cards
        .map((card) => card.copyWith(isVisible: true))
        .toList();

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    _gameState = _gameState.copyWith(players: updatedPlayers);
    notifyListeners();
  }
}
