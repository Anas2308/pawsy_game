// lib/widgets/player_area.dart
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class PlayerArea extends StatefulWidget {
  final Player player;
  final bool isCompact;
  final bool showDrawnCard;
  final bool isLookingAtCards;
  final ActionCardPhase actionPhase;
  final AnimationPhase animationPhase;
  final int? selectedPlayerIndex;
  final int? selectedCardIndex;
  final int? revealedPlayerIndex;
  final int? revealedCardIndex;
  final int? highlightedPlayerIndex;
  final int? highlightedCardIndex;
  final List<(int, int)> switchingCards;
  final Function(int)? onCardTap;
  final Function(int)? onPlayerTap;

  const PlayerArea({
    super.key,
    required this.player,
    this.isCompact = false,
    this.showDrawnCard = false,
    this.isLookingAtCards = false,
    this.actionPhase = ActionCardPhase.none,
    this.animationPhase = AnimationPhase.none,
    this.selectedPlayerIndex,
    this.selectedCardIndex,
    this.revealedPlayerIndex,
    this.revealedCardIndex,
    this.highlightedPlayerIndex,
    this.highlightedCardIndex,
    this.switchingCards = const [],
    this.onCardTap,
    this.onPlayerTap,
  });

  @override
  State<PlayerArea> createState() => _PlayerAreaState();
}

class _PlayerAreaState extends State<PlayerArea> with TickerProviderStateMixin {
  late AnimationController _highlightController;
  late AnimationController _switchController;
  late Animation<double> _highlightAnimation;
  late Animation<Offset> _switchAnimation;

  @override
  void initState() {
    super.initState();

    _highlightController = AnimationController(
      duration: GameConstants.highlightAnimationDuration,
      vsync: this,
    );

    _switchController = AnimationController(
      duration: GameConstants.switchAnimationDuration,
      vsync: this,
    );

    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    _switchAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero, // Wird dynamisch gesetzt
        ).animate(
          CurvedAnimation(parent: _switchController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(PlayerArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Highlight Animation starten/stoppen
    if (widget.animationPhase == AnimationPhase.highlighting &&
        oldWidget.animationPhase != AnimationPhase.highlighting) {
      _highlightController.forward();
    } else if (widget.animationPhase != AnimationPhase.highlighting &&
        oldWidget.animationPhase == AnimationPhase.highlighting) {
      _highlightController.reverse();
    }

    // Switch Animation starten
    if (widget.animationPhase == AnimationPhase.switching &&
        oldWidget.animationPhase != AnimationPhase.switching) {
      _startSwitchAnimation();
    }
  }

  void _startSwitchAnimation() {
    // TODO: Implementiere komplexe Switch-Animation
    // Für jetzt: Einfache Animation
    _switchController.forward().then((_) {
      _switchController.reverse();
    });
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isInteractivePlayer = _isPlayerInteractive();

    return GestureDetector(
      onTap: isInteractivePlayer
          ? () => widget.onPlayerTap?.call(widget.player.playerIndex)
          : null,
      child: Container(
        padding: EdgeInsets.all(widget.isCompact ? 8 : 16),
        decoration: isInteractivePlayer
            ? BoxDecoration(
                border: Border.all(color: AppColors.interactiveCard, width: 3),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.interactiveCard.withOpacity(0.1),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.player.isHuman)
              Text(
                '${widget.player.name} (${widget.player.cards.length} Karten)',
                style: TextStyle(
                  color: isInteractivePlayer
                      ? AppColors.interactiveCard
                      : AppColors.textPrimary,
                  fontSize: widget.isCompact ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return _buildAnimatedCard(index);
              }),
            ),
            const SizedBox(height: 8),
            if (widget.player.isHuman)
              Text(
                '${widget.player.name} (${widget.player.cards.length} Karten)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isPlayerInteractive() {
    return (widget.actionPhase == ActionCardPhase.stalkSelectPlayer ||
            widget.actionPhase == ActionCardPhase.switchSelectPlayer) &&
        !widget.player.isHuman;
  }

  bool _isCardInteractive(int index) {
    bool hasCard = index < widget.player.cards.length;
    if (!hasCard) return false;

    GameCard card = widget.player.cards[index];

    // Standard-Interaktionen
    if (widget.isLookingAtCards && widget.player.isHuman && !card.isVisible)
      return true;
    if (widget.player.isHuman && widget.showDrawnCard) return true;

    // Aktionskarten-Interaktionen
    if (widget.actionPhase == ActionCardPhase.scoutSelectCard &&
        widget.player.isHuman)
      return true;
    if (widget.actionPhase == ActionCardPhase.stalkSelectCard &&
        widget.player.playerIndex == widget.selectedPlayerIndex)
      return true;
    if (widget.actionPhase == ActionCardPhase.switchSelectOwnCard &&
        widget.player.isHuman)
      return true;
    if (widget.actionPhase == ActionCardPhase.switchSelectOpponentCard &&
        widget.player.playerIndex == widget.selectedPlayerIndex)
      return true;

    return false;
  }

  bool _isCardHighlighted(int index) {
    return widget.highlightedPlayerIndex == widget.player.playerIndex &&
        widget.highlightedCardIndex == index;
  }

  bool _isCardSwitching(int index) {
    return widget.switchingCards.any(
      (card) => card.$1 == widget.player.playerIndex && card.$2 == index,
    );
  }

  bool _isCardRevealed(int index) {
    return widget.revealedPlayerIndex == widget.player.playerIndex &&
        widget.revealedCardIndex == index;
  }

  bool _isCardSelected(int index) {
    if (widget.actionPhase == ActionCardPhase.switchSelectOpponentCard &&
        widget.player.isHuman &&
        widget.selectedCardIndex == index)
      return true;

    if (widget.actionPhase == ActionCardPhase.switchSelectOwnCard &&
        !widget.player.isHuman &&
        widget.player.playerIndex == widget.selectedPlayerIndex)
      return true;

    return false;
  }

  Widget _buildAnimatedCard(int index) {
    bool hasCard = index < widget.player.cards.length;
    bool isInteractive = _isCardInteractive(index);
    bool isSelected = _isCardSelected(index);
    bool isRevealed = _isCardRevealed(index);
    bool isHighlighted = _isCardHighlighted(index);
    bool isSwitching = _isCardSwitching(index);
    GameCard? card = hasCard ? widget.player.cards[index] : null;

    return AnimatedBuilder(
      animation: Listenable.merge([_highlightController, _switchController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: isInteractive ? () => widget.onCardTap?.call(index) : null,
          child: Transform.translate(
            offset: _getCardOffset(index, isHighlighted, isSwitching),
            child: Transform.scale(
              scale: _getCardScale(isHighlighted, isSwitching),
              child: Container(
                width: widget.isCompact
                    ? CardSizes.compactWidth
                    : CardSizes.normalWidth,
                height: widget.isCompact
                    ? CardSizes.compactHeight
                    : CardSizes.normalHeight,
                margin: EdgeInsets.symmetric(
                  horizontal: widget.isCompact ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: _getCardBackgroundColor(
                    hasCard,
                    card,
                    isInteractive,
                    isRevealed,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getCardBorderColor(
                      hasCard,
                      isInteractive,
                      isSelected,
                      isHighlighted,
                    ),
                    width: _getCardBorderWidth(
                      hasCard,
                      isInteractive,
                      isSelected,
                      isHighlighted,
                    ),
                  ),
                  boxShadow: _getCardShadow(isHighlighted, isSwitching),
                ),
                child: Center(
                  child: _getCardContent(hasCard, card, isRevealed),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _getCardOffset(int index, bool isHighlighted, bool isSwitching) {
    if (isSwitching) {
      // Switch Animation - Karte zur Mitte bewegen
      return _switchAnimation.value;
    }

    if (isHighlighted) {
      // Highlight Animation - Karte nach vorne bewegen
      double progress = _highlightAnimation.value;
      return Offset(0, -GameConstants.highlightOffset * progress);
    }

    return Offset.zero;
  }

  double _getCardScale(bool isHighlighted, bool isSwitching) {
    if (isSwitching) {
      // Switch Animation - leichte Größenänderung
      double progress = _switchController.value;
      if (progress < 0.5) {
        return 1.0 + ((GameConstants.switchScale - 1.0) * progress * 2);
      } else {
        return GameConstants.switchScale -
            ((GameConstants.switchScale - 1.0) * (progress - 0.5) * 2);
      }
    }

    if (isHighlighted) {
      // Highlight Animation - leichte Vergrößerung
      return 1.0 +
          ((GameConstants.highlightScale - 1.0) * _highlightAnimation.value);
    }

    return 1.0;
  }

  List<BoxShadow> _getCardShadow(bool isHighlighted, bool isSwitching) {
    if (isHighlighted || isSwitching) {
      double opacity = isHighlighted
          ? _highlightAnimation.value
          : isSwitching
          ? _switchController.value
          : 0.0;

      return [
        BoxShadow(
          color: Colors.yellow.withOpacity(0.6 * opacity),
          blurRadius: 10 * opacity,
          spreadRadius: 2 * opacity,
          offset: Offset(0, 2 * opacity),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3 * opacity),
          blurRadius: 15 * opacity,
          offset: Offset(0, 5 * opacity),
        ),
      ];
    }

    return [];
  }

  Color _getCardBackgroundColor(
    bool hasCard,
    GameCard? card,
    bool isInteractive,
    bool isRevealed,
  ) {
    if (!hasCard) return AppColors.emptyCard;

    if (isInteractive) {
      return AppColors.interactiveCard;
    }

    if (widget.player.isHuman) {
      return (card?.isVisible == true || isRevealed)
          ? card!.color
          : AppColors.playerCard;
    }

    return (card?.isVisible == true || isRevealed)
        ? card!.color
        : AppColors.opponentCard;
  }

  Color _getCardBorderColor(
    bool hasCard,
    bool isInteractive,
    bool isSelected,
    bool isHighlighted,
  ) {
    if (isHighlighted) return Colors.yellow;
    if (isSelected) return Colors.orange;
    if (isInteractive) return AppColors.selectedCard;
    return hasCard ? AppColors.textPrimary : AppColors.border;
  }

  double _getCardBorderWidth(
    bool hasCard,
    bool isInteractive,
    bool isSelected,
    bool isHighlighted,
  ) {
    if (isHighlighted) return 4;
    if (isSelected) return 4;
    if (isInteractive) return 3;
    return hasCard ? 2 : 1;
  }

  Widget _getCardContent(bool hasCard, GameCard? card, bool isRevealed) {
    if (!hasCard) {
      return Icon(
        Icons.crop_portrait,
        color: AppColors.border,
        size: widget.isCompact ? 15 : 20,
      );
    }

    if ((widget.player.isHuman && card?.isVisible == true) || (isRevealed)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${card!.value}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: widget.isCompact ? 14 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (card.isActionCard && !widget.isCompact)
            Text(
              card.actionName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: widget.isCompact ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      );
    }

    // Zeige Kartenrücken mit Hintergrundbild
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/starter.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Center(
          child: Icon(
            Icons.pets,
            color: AppColors.textPrimary,
            size: widget.isCompact ? 20 : 30,
          ),
        ),
      ),
    );
  }
}
