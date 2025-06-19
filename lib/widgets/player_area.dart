// lib/widgets/player_area.dart
class PlayerArea extends StatelessWidget {
  final Player player;
  final bool isCompact;
  final VoidCallback? onCardTap;

  // Nur UI-Logic für Spielerbereich
}

// lib/widgets/center_stacks.dart
class CenterStacks extends StatelessWidget {
  final int deckSize;
  final GameCard discardCard;
  final VoidCallback onDrawTap;
  final VoidCallback onDiscardTap;

  // Nur Stapel-UI
}
