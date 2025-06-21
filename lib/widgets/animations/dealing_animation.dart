// lib/widgets/animations/dealing_animation.dart
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../utils/constants.dart';
import '../../services/animation_service.dart';

class DealingAnimation extends StatefulWidget {
  final GameState gameState;
  final int playerCount;
  final VoidCallback? onAnimationComplete;

  const DealingAnimation({
    super.key,
    required this.gameState,
    required this.playerCount,
    this.onAnimationComplete,
  });

  @override
  State<DealingAnimation> createState() => _DealingAnimationState();
}

class _DealingAnimationState extends State<DealingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _dealingController;
  late Animation<Offset> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
          CurvedAnimation(
            parent: _dealingController,
            curve: AnimationService.getDealingCurve(),
          ),
        );
  }

  @override
  void didUpdateWidget(DealingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Starte Animation wenn Dealing beginnt
    if (widget.gameState.isDealing && !oldWidget.gameState.isDealing) {
      _startDealingAnimation();
    }

    // Update Animation target wenn sich der Spieler ändert
    if (widget.gameState.dealingToPlayerIndex !=
        oldWidget.gameState.dealingToPlayerIndex) {
      _updateCardTarget();
    }
  }

  void _startDealingAnimation() {
    _updateCardTarget();
    _dealingController.reset();
    _dealingController.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  void _updateCardTarget() {
    Offset targetPosition = AnimationService.calculateDealingTarget(
      widget.gameState.dealingToPlayerIndex,
      widget.playerCount,
    );

    _cardAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: targetPosition).animate(
          CurvedAnimation(
            parent: _dealingController,
            curve: AnimationService.getDealingCurve(),
          ),
        );
  }

  @override
  void dispose() {
    _dealingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.gameState.isDealing) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
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
          child: _buildDealingCard(),
        );
      },
    );
  }

  Widget _buildDealingCard() {
    return Container(
      width: CardSizes.normalWidth,
      height: CardSizes.normalHeight,
      decoration: BoxDecoration(
        color: AppColors.deckCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.pets, color: AppColors.textPrimary, size: 30),
      ),
    );
  }
}
