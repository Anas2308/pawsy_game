// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../widgets/player_area.dart';
import '../widgets/center_stacks.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _dealingController;
  late Animation<Offset> _cardAnimation;
  late AnimationController _drawController;
  late Animation<double> _drawAnimation;
  late AnimationController _discardDrawController;
  late Animation<Offset> _discardMoveAnimation;
  late Animation<double> _discardFlipAnimation;

  int playerCount = 4;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().startNewGame(playerCount);
      _startDealingAnimation();
    });
  }

  void _initializeAnimations() {
    _dealingController = AnimationController(
      duration: GameConstants.dealingDuration,
      vsync: this,
    );

    _cardAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(parent: _dealingController, curve: Curves.easeInOut),
        );

    _drawController = AnimationController(
      duration: GameConstants.drawDuration,
      vsync: this,
    );

    _drawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: Curves.easeInOut),
    );

    _discardDrawController = AnimationController(
      duration: GameConstants.discardFlipDuration,
      vsync: this,
    );

    _discardMoveAnimation =
        Tween<Offset>(
          begin: const Offset(0.3, 0.2),
          end: const Offset(0, -0.1),
        ).animate(
          CurvedAnimation(
            parent: _discardDrawController,
            curve: Curves.easeInOut,
          ),
        );

    _discardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _discardDrawController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dealingController.dispose();
    _drawController.dispose();
    _discardDrawController.dispose();
    super.dispose();
  }

  void _startDealingAnimation() {
    _dealCardWithAnimation();
  }

  void _dealCardWithAnimation() {
    final gameController = context.read<GameController>();
    final gameState = gameController.gameState;

    if (gameState.isDealing &&
        gameState.currentDealingCard <
            gameState.playerCount * GameConstants.maxCardsPerPlayer) {
      _cardAnimation =
          Tween<Offset>(
            begin: const Offset(0, 0),
            end: _getPlayerCardPosition(gameState.dealingToPlayerIndex),
          ).animate(
            CurvedAnimation(
              parent: _dealingController,
              curve: Curves.easeInOut,
            ),
          );

      _dealingController.reset();
      _dealingController.forward().then((_) {
        gameController.dealNextCard();

        Future.delayed(GameConstants.betweenCardDelay, () {
          if (mounted && gameController.gameState.isDealing) {
            _dealCardWithAnimation();
          }
        });
      });
    } else {
      gameController.dealNextCard();
    }
  }

  Offset _getPlayerCardPosition(int player) {
    switch (playerCount) {
      case 2:
        return player == 0 ? const Offset(0, 1.5) : const Offset(0, -1.5);
      case 3:
        if (player == 0) return const Offset(0, 1.5);
        if (player == 1) return const Offset(-1, -1);
        return const Offset(1, -1);
      case 4:
        if (player == 0) return const Offset(0, 1.5);
        if (player == 1) return const Offset(-1.5, 0);
        if (player == 2) return const Offset(0, -1.5);
        return const Offset(1.5, 0);
      case 5:
        if (player == 0) return const Offset(0, 1.5);
        if (player == 1) return const Offset(-1.5, 0);
        if (player == 2) return const Offset(-0.8, -1.2);
        if (player == 3) return const Offset(0.8, -1.2);
        return const Offset(1.5, 0);
      default:
        return const Offset(0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(GameStrings.appTitle),
        backgroundColor: Colors.green[800]?.withValues(alpha: 0.9),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameController>().startNewGame(playerCount);
              _startDealingAnimation();
            },
            tooltip: GameStrings.newGame,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.people),
            onSelected: (value) {
              setState(() {
                playerCount = value;
              });
              context.read<GameController>().startNewGame(playerCount);
              _startDealingAnimation();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 2, child: Text('2 Spieler')),
              const PopupMenuItem(value: 3, child: Text('3 Spieler')),
              const PopupMenuItem(value: 4, child: Text('4 Spieler')),
              const PopupMenuItem(value: 5, child: Text('5 Spieler')),
            ],
          ),
        ],
      ),
      body: Consumer<GameController>(
        builder: (context, gameController, child) {
          final gameState = gameController.gameState;

          return Column(
            children: [
              _buildGameInfo(gameState),
              Expanded(
                child: Stack(
                  children: [
                    _buildGameLayout(gameState, gameController),
                    _buildAnimations(gameState),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameInfo(GameState gameState) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$playerCount Spieler',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Deck: ${gameState.deck.length} Karten',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (gameState.isLookingAtCards)
            const Text(
              GameStrings.lookAtCards,
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (gameState.isDealing)
            Text(
              'Teile Karte ${gameState.currentDealingCard + 1} an ${gameState.players.isNotEmpty ? gameState.players[gameState.dealingToPlayerIndex].name : 'Spieler'} aus...',
              style: const TextStyle(color: Colors.yellow, fontSize: 12),
            ),
          if (gameState.showDrawnCard && gameState.drawnCard != null)
            Text(
              '${GameStrings.cardDrawn} ${gameState.drawnCard!.value} - ${GameStrings.clickToInteract}',
              style: const TextStyle(color: Colors.lightBlue, fontSize: 12),
            ),
          if (gameState.isDrawingFromDiscard)
            const Text(
              GameStrings.drawingFromDiscard,
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildGameLayout(GameState gameState, GameController gameController) {
    if (playerCount == 2) {
      return _buildTwoPlayerLayout(gameState, gameController);
    } else if (playerCount == 3) {
      return _buildThreePlayerLayout(gameState, gameController);
    } else if (playerCount == 4) {
      return _buildFourPlayerLayout(gameState, gameController);
    } else {
      return _buildFivePlayerLayout(gameState, gameController);
    }
  }

  Widget _buildTwoPlayerLayout(
    GameState gameState,
    GameController gameController,
  ) {
    return Column(
      children: [
        if (gameState.players.length > 1)
          PlayerArea(
            player: gameState.players[1],
            showDrawnCard: gameState.showDrawnCard,
            isLookingAtCards: gameState.isLookingAtCards,
          ),
        const Spacer(),
        CenterStacks(
          deckSize: gameState.deck.length,
          discardCard: gameState.discardPile,
          showDrawnCard: gameState.showDrawnCard,
          isDealing: gameState.isDealing,
          isDrawingFromDiscard: gameState.isDrawingFromDiscard,
          onDrawFromDeck: () => gameController.drawCardFromDeck(),
          onDrawFromDiscard: () {
            gameController.drawCardFromDiscard();
            _discardDrawController.forward().then((_) {
              gameController.finishDrawingFromDiscard();
              _drawController.forward();
            });
          },
          onDiscardDrawnCard: () => gameController.discardDrawnCard(),
        ),
        const Spacer(),
        if (gameState.players.isNotEmpty)
          PlayerArea(
            player: gameState.players[0],
            showDrawnCard: gameState.showDrawnCard,
            isLookingAtCards: gameState.isLookingAtCards,
            onCardTap: (index) {
              if (gameState.isLookingAtCards) {
                gameController.lookAtStartCard(index);
              } else {
                gameController.swapWithPlayerCard(index);
              }
            },
          ),
        if (gameState.isPlaying)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: gameState.canCallPawsy
                  ? () => gameController.callPawsy()
                  : null,
              icon: const Icon(Icons.pets),
              label: Text(GameStrings.pawsyButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.canCallPawsy
                    ? Colors.orange[600]
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThreePlayerLayout(
    GameState gameState,
    GameController gameController,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (gameState.players.length > 1)
              PlayerArea(
                player: gameState.players[1],
                isCompact: true,
                showDrawnCard: gameState.showDrawnCard,
                isLookingAtCards: gameState.isLookingAtCards,
              ),
            if (gameState.players.length > 2)
              PlayerArea(
                player: gameState.players[2],
                isCompact: true,
                showDrawnCard: gameState.showDrawnCard,
                isLookingAtCards: gameState.isLookingAtCards,
              ),
          ],
        ),
        const Spacer(),
        CenterStacks(
          deckSize: gameState.deck.length,
          discardCard: gameState.discardPile,
          showDrawnCard: gameState.showDrawnCard,
          isDealing: gameState.isDealing,
          isDrawingFromDiscard: gameState.isDrawingFromDiscard,
          onDrawFromDeck: () => gameController.drawCardFromDeck(),
          onDrawFromDiscard: () {
            gameController.drawCardFromDiscard();
            _discardDrawController.forward().then((_) {
              gameController.finishDrawingFromDiscard();
              _drawController.forward();
            });
          },
          onDiscardDrawnCard: () => gameController.discardDrawnCard(),
        ),
        const Spacer(),
        if (gameState.players.isNotEmpty)
          PlayerArea(
            player: gameState.players[0],
            showDrawnCard: gameState.showDrawnCard,
            isLookingAtCards: gameState.isLookingAtCards,
            onCardTap: (index) {
              if (gameState.isLookingAtCards) {
                gameController.lookAtStartCard(index);
              } else {
                gameController.swapWithPlayerCard(index);
              }
            },
          ),
        if (gameState.isPlaying)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: gameState.canCallPawsy
                  ? () => gameController.callPawsy()
                  : null,
              icon: const Icon(Icons.pets),
              label: Text(GameStrings.pawsyButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.canCallPawsy
                    ? Colors.orange[600]
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFourPlayerLayout(
    GameState gameState,
    GameController gameController,
  ) {
    return Column(
      children: [
        if (gameState.players.length > 2)
          PlayerArea(
            player: gameState.players[2],
            showDrawnCard: gameState.showDrawnCard,
            isLookingAtCards: gameState.isLookingAtCards,
          ),
        Expanded(
          child: Row(
            children: [
              if (gameState.players.length > 1)
                RotatedBox(
                  quarterTurns: 1,
                  child: PlayerArea(
                    player: gameState.players[1],
                    isCompact: true,
                    showDrawnCard: gameState.showDrawnCard,
                    isLookingAtCards: gameState.isLookingAtCards,
                  ),
                ),
              Expanded(
                child: CenterStacks(
                  deckSize: gameState.deck.length,
                  discardCard: gameState.discardPile,
                  showDrawnCard: gameState.showDrawnCard,
                  isDealing: gameState.isDealing,
                  isDrawingFromDiscard: gameState.isDrawingFromDiscard,
                  onDrawFromDeck: () => gameController.drawCardFromDeck(),
                  onDrawFromDiscard: () {
                    gameController.drawCardFromDiscard();
                    _discardDrawController.forward().then((_) {
                      gameController.finishDrawingFromDiscard();
                      _drawController.forward();
                    });
                  },
                  onDiscardDrawnCard: () => gameController.discardDrawnCard(),
                ),
              ),
              if (gameState.players.length > 3)
                RotatedBox(
                  quarterTurns: 3,
                  child: PlayerArea(
                    player: gameState.players[3],
                    isCompact: true,
                    showDrawnCard: gameState.showDrawnCard,
                    isLookingAtCards: gameState.isLookingAtCards,
                  ),
                ),
            ],
          ),
        ),
        if (gameState.players.isNotEmpty)
          PlayerArea(
            player: gameState.players[0],
            showDrawnCard: gameState.showDrawnCard,
            isLookingAtCards: gameState.isLookingAtCards,
            onCardTap: (index) {
              if (gameState.isLookingAtCards) {
                gameController.lookAtStartCard(index);
              } else {
                gameController.swapWithPlayerCard(index);
              }
            },
          ),
        if (gameState.isPlaying)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: gameState.canCallPawsy
                  ? () => gameController.callPawsy()
                  : null,
              icon: const Icon(Icons.pets),
              label: Text(GameStrings.pawsyButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.canCallPawsy
                    ? Colors.orange[600]
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFivePlayerLayout(
    GameState gameState,
    GameController gameController,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (gameState.players.length > 2)
              PlayerArea(
                player: gameState.players[2],
                isCompact: true,
                showDrawnCard: gameState.showDrawnCard,
                isLookingAtCards: gameState.isLookingAtCards,
              ),
            if (gameState.players.length > 3)
              PlayerArea(
                player: gameState.players[3],
                isCompact: true,
                showDrawnCard: gameState.showDrawnCard,
                isLookingAtCards: gameState.isLookingAtCards,
              ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              if (gameState.players.length > 1)
                RotatedBox(
                  quarterTurns: 1,
                  child: PlayerArea(
                    player: gameState.players[1],
                    isCompact: true,
                    showDrawnCard: gameState.showDrawnCard,
                    isLookingAtCards: gameState.isLookingAtCards,
                  ),
                ),
              Expanded(
                child: CenterStacks(
                  deckSize: gameState.deck.length,
                  discardCard: gameState.discardPile,
                  showDrawnCard: gameState.showDrawnCard,
                  isDealing: gameState.isDealing,
                  isDrawingFromDiscard: gameState.isDrawingFromDiscard,
                  onDrawFromDeck: () => gameController.drawCardFromDeck(),
                  onDrawFromDiscard: () {
                    gameController.drawCardFromDiscard();
                    _discardDrawController.forward().then((_) {
                      gameController.finishDrawingFromDiscard();
                      _drawController.forward();
                    });
                  },
                  onDiscardDrawnCard: () => gameController.discardDrawnCard(),
                ),
              ),
              if (gameState.players.length > 4)
                RotatedBox(
                  quarterTurns: 3,
                  child: PlayerArea(
                    player: gameState.players[4],
                    isCompact: true,
                    showDrawnCard: gameState.showDrawnCard,
                    isLookingAtCards: gameState.isLookingAtCards,
                  ),
                ),
            ],
          ),
        ),
        if (gameState.players.isNotEmpty)
          PlayerArea(
            player: gameState.players[0],
            showDrawnCard: gameState.showDrawnCard,
            isLookingAtCards: gameState.isLookingAtCards,
            onCardTap: (index) {
              if (gameState.isLookingAtCards) {
                gameController.lookAtStartCard(index);
              } else {
                gameController.swapWithPlayerCard(index);
              }
            },
          ),
        if (gameState.isPlaying)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: gameState.canCallPawsy
                  ? () => gameController.callPawsy()
                  : null,
              icon: const Icon(Icons.pets),
              label: Text(GameStrings.pawsyButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.canCallPawsy
                    ? Colors.orange[600]
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnimations(GameState gameState) {
    return Stack(
      children: [
        if (gameState.isDealing)
          AnimatedBuilder(
            animation: _cardAnimation,
            builder: (context, child) {
              return Positioned(
                left:
                    MediaQuery.of(context).size.width / 2 -
                    40 +
                    _cardAnimation.value.dx * 100,
                top:
                    MediaQuery.of(context).size.height / 2 -
                    60 +
                    _cardAnimation.value.dy * 100,
                child: Container(
                  width: CardSizes.normalWidth,
                  height: CardSizes.normalHeight,
                  decoration: BoxDecoration(
                    color: AppColors.deckCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.textPrimary, width: 2),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: AppColors.textPrimary,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        if (gameState.isDrawingFromDiscard && gameState.drawnCard != null)
          AnimatedBuilder(
            animation: _discardDrawController,
            builder: (context, child) {
              return Positioned(
                left:
                    MediaQuery.of(context).size.width / 2 -
                    50 +
                    _discardMoveAnimation.value.dx * 100,
                top:
                    MediaQuery.of(context).size.height / 2 -
                    75 +
                    _discardMoveAnimation.value.dy * 100,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_discardFlipAnimation.value * 3.14159),
                  child: Container(
                    width: CardSizes.drawnWidth,
                    height: CardSizes.drawnHeight,
                    decoration: BoxDecoration(
                      color: _discardFlipAnimation.value < 0.5
                          ? gameState.discardPile?.color ?? AppColors.emptyCard
                          : gameState.drawnCard!.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.interactiveCard,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _discardFlipAnimation.value < 0.5
                          ? Text(
                              '${gameState.discardPile?.value ?? 0}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: Text(
                                '${gameState.drawnCard!.value}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        if (gameState.showDrawnCard &&
            gameState.drawnCard != null &&
            !gameState.isDrawingFromDiscard)
          AnimatedBuilder(
            animation: _drawAnimation,
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width / 2 - 50,
                top: MediaQuery.of(context).size.height / 2 - 75,
                child: Transform.scale(
                  scale: 0.8 + (_drawAnimation.value * 0.4),
                  child: Container(
                    width: CardSizes.drawnWidth,
                    height: CardSizes.drawnHeight,
                    decoration: BoxDecoration(
                      color: gameState.drawnCard!.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.interactiveCard,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${gameState.drawnCard!.value}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
