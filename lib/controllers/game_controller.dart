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

  /// Startet ein neues Spiel
  void startNewGame(int playerCount) {
    // Deck erstellen
    List<int> deck = DeckController.createCaboDeck();

    // Spieler erstellen
    List<Player> players = [];
    for (int i = 0; i < playerCount; i++) {
      players.add(
        Player(
          name: i == 0 ? GameStrings.humanPlayer : GameStrings.aiPlayer(i + 1),
          cards: [],
          playerIndex: i,
          isHuman: i == 0, // Erster Spieler ist immer human
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

  /// Nächste Karte beim Austeilen
  void dealNextCard() {
    if (_gameState.currentDealingCard >=
        _gameState.playerCount * GameConstants.maxCardsPerPlayer) {
      // Alle Karten ausgeteilt - Ablagestapel initialisieren
      int? discardCard = DeckController.drawCard(_gameState.deck);
      if (discardCard != null) {
        _gameState = _gameState.copyWith(
          phase: GamePhase.playing,
          discardPile: GameCard(value: discardCard, isVisible: true),
        );
        print('✅ Alle Karten ausgeteilt! Ablagestapel: $discardCard');
      }
    } else {
      // Karte an aktuellen Spieler austeilen
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

  /// Karte vom Deck ziehen
  void drawCardFromDeck() {
    if (!_gameState.canDrawCard) return;

    int? card = DeckController.drawCard(_gameState.deck);
    if (card != null) {
      _gameState = _gameState.copyWith(
        drawnCard: GameCard(value: card, isVisible: true),
        showDrawnCard: true,
      );

      print('🎴 Karte vom Deck gezogen: $card');
      notifyListeners();
    }
  }

  /// Karte vom Ablagestapel ziehen
  void drawCardFromDiscard() {
    if (_gameState.showDrawnCard ||
        _gameState.isDrawingFromDiscard ||
        _gameState.discardPile == null)
      return;

    _gameState = _gameState.copyWith(
      drawnCard: GameCard(
        value: _gameState.discardPile!.value,
        isVisible: true,
      ),
      isDrawingFromDiscard: true,
    );

    print(
      '🎴 Karte vom Ablagestapel gezogen: ${_gameState.discardPile!.value}',
    );
    notifyListeners();
  }

  /// Animation für Ablagestapel-Ziehen beendet
  void finishDrawingFromDiscard() {
    _gameState = _gameState.copyWith(
      showDrawnCard: true,
      isDrawingFromDiscard: false,
    );
    notifyListeners();
  }

  /// Gezogene Karte auf Ablagestapel ablegen
  void discardDrawnCard() {
    if (_gameState.drawnCard == null) return;

    _gameState = _gameState.copyWith(
      discardPile: _gameState.drawnCard,
      drawnCard: null,
      showDrawnCard: false,
    );

    print('🗂️ Karte ${_gameState.discardPile?.value} auf Ablagestapel gelegt');
    notifyListeners();
  }

  /// Gezogene Karte mit Spielerkarte tauschen
  void swapWithPlayerCard(int cardIndex) {
    if (_gameState.drawnCard == null ||
        cardIndex >= GameConstants.maxCardsPerPlayer)
      return;

    List<Player> updatedPlayers = List.from(_gameState.players);
    Player humanPlayer = updatedPlayers[0]; // Erster Spieler ist immer human

    if (cardIndex >= humanPlayer.cards.length) return;

    List<GameCard> updatedCards = List.from(humanPlayer.cards);
    GameCard oldCard = updatedCards[cardIndex];

    // Neue Karte setzen (sichtbar machen)
    updatedCards[cardIndex] = _gameState.drawnCard!.copyWith(isVisible: true);

    updatedPlayers[0] = humanPlayer.copyWith(cards: updatedCards);

    _gameState = _gameState.copyWith(
      players: updatedPlayers,
      discardPile: oldCard.copyWith(isVisible: true),
      drawnCard: null,
      showDrawnCard: false,
    );

    print(
      '🔄 Karte ${_gameState.drawnCard?.value} mit Spielerkarte ${oldCard.value} getauscht',
    );
    notifyListeners();
  }

  /// Spieler-Karte sichtbar machen (für Peek-Aktionen)
  void revealPlayerCard(int playerIndex, int cardIndex) {
    if (playerIndex >= _gameState.players.length) return;

    List<Player> updatedPlayers = List.from(_gameState.players);
    Player player = updatedPlayers[playerIndex];

    if (cardIndex >= player.cards.length) return;

    List<GameCard> updatedCards = List.from(player.cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isVisible: true);

    updatedPlayers[playerIndex] = player.copyWith(cards: updatedCards);

    _gameState = _gameState.copyWith(players: updatedPlayers);
    notifyListeners();
  }

  /// Debug: Alle Human-Player Karten anzeigen
  void debugRevealHumanCards() {
    if (_gameState.players.isEmpty) return;

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
