// lib/widgets/controls_area.dart
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../controllers/game_controller.dart';
import '../utils/constants.dart';

class ControlsArea extends StatelessWidget {
  final GameState gameState;
  final GameController gameController;
  final bool showDebugInfo;

  const ControlsArea({
    super.key,
    required this.gameState,
    required this.gameController,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (showDebugInfo) _buildDebugInfo(),
          const SizedBox(height: 8),
          _buildMainControls(),
          if (gameState.isInActionPhase) _buildActionControls(),
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Column(
      children: [
        Text(
          'Phase: ${gameState.phase}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Current Player: ${gameState.currentPlayer.name} (Human: ${gameState.currentPlayer.isHuman})',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Has Drawn: ${gameState.hasDrawnCardThisTurn}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Can Call PAWSY: ${gameState.canCallPawsy}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        if (gameState.isInActionPhase)
          Text(
            'Action Phase: ${gameState.actionPhase}',
            style: const TextStyle(color: Colors.purple, fontSize: 12),
          ),
        if (gameState.isAnimating)
          Text(
            'Animation: ${gameState.animationPhase}',
            style: const TextStyle(color: Colors.yellow, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildMainControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_buildPawsyButton(), if (showDebugInfo) _buildDebugButtons()],
    );
  }

  Widget _buildPawsyButton() {
    bool canCallPawsy =
        gameState.isPlaying && gameState.isHumanTurn && gameState.canCallPawsy;

    return ElevatedButton.icon(
      onPressed: canCallPawsy ? () => gameController.callPawsy() : null,
      icon: const Icon(Icons.pets),
      label: const Text(GameStrings.pawsyButton),
      style: ElevatedButton.styleFrom(
        backgroundColor: canCallPawsy ? Colors.orange[600] : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: canCallPawsy ? 8 : 2,
      ),
    );
  }

  Widget _buildDebugButtons() {
    return Row(
      children: [
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => gameController.debugRevealHumanCards(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
          child: const Text('Debug Cards'),
        ),
      ],
    );
  }

  Widget _buildActionControls() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => gameController.cancelActionCard(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel, size: 18),
                SizedBox(width: 8),
                Text('Abbrechen'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
