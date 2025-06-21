// lib/widgets/animations/card_animation_widget.dart
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/card.dart';
import '../../utils/constants.dart';

class CardAnimationWidget extends StatefulWidget {
  final GameState gameState;
  final Widget child;

  const CardAnimationWidget({
    super.key,
    required this.gameState,
    required this.child,
  });

  @override
  State<CardAnimationWidget> createState() => _CardAnimationWidgetState();
}

class _CardAnimationWidgetState extends State<CardAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _discardDrawController;
  late Animation<double> _drawAnimation;
  late Animation<Offset> _discardMoveAnimation;
  late Animation<double> _discardFlipAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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
  void didUpdateWidget(CardAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Starte Animationen basierend auf GameState Änderungen
    if (widget.gameState.showDrawnCard && !oldWidget.gameState.showDrawnCard) {
      _drawController.forward();
    }

    if (widget.gameState.isDrawingFromDiscard &&
        !oldWidget.gameState.isDrawingFromDiscard) {
      _discardDrawController.forward();
    }
  }

  @override
  void dispose() {
    _drawController.dispose();
    _discardDrawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [widget.child, _buildAnimationOverlay()]);
  }

  Widget _buildAnimationOverlay() {
    return Stack(
      children: [
        if (widget.gameState.showDrawnCard &&
            widget.gameState.drawnCard != null &&
            !widget.gameState.isDrawingFromDiscard)
          _buildDrawnCardAnimation(),
        if (widget.gameState.isDrawingFromDiscard &&
            widget.gameState.drawnCard != null)
          _buildDiscardDrawAnimation(),
      ],
    );
  }

  Widget _buildDrawnCardAnimation() {
    return AnimatedBuilder(
      animation: _drawAnimation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 - 50,
          top: MediaQuery.of(context).size.height / 2 - 75,
          child: Transform.scale(
            scale: 0.8 + (_drawAnimation.value * 0.4),
            child: _buildAnimatedCard(
              widget.gameState.drawnCard!,
              CardSizes.drawnWidth,
              CardSizes.drawnHeight,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscardDrawAnimation() {
    return AnimatedBuilder(
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
            child: _buildFlippingCard(),
          ),
        );
      },
    );
  }

  Widget _buildFlippingCard() {
    bool showFront = _discardFlipAnimation.value < 0.5;
    GameCard cardToShow = showFront
        ? widget.gameState.discardPile!
        : widget.gameState.drawnCard!;

    Widget cardContent = showFront
        ? _buildCardFace(cardToShow)
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(3.14159),
            child: _buildCardFace(cardToShow),
          );

    return Container(
      width: CardSizes.drawnWidth,
      height: CardSizes.drawnHeight,
      decoration: BoxDecoration(
        color: cardToShow.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.interactiveCard, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(child: cardContent),
    );
  }

  Widget _buildAnimatedCard(GameCard card, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.interactiveCard, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(child: _buildCardFace(card)),
    );
  }

  Widget _buildCardFace(GameCard card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${card.value}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (card.isActionCard)
          Text(
            card.actionName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
