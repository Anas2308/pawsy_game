import 'package:flutter/material.dart';
import 'action_buttons_widget.dart';

class DrawnCardWidget extends StatelessWidget {
  final String drawnCard;
  final VoidCallback onDiscard;
  final VoidCallback? onSwap;
  final int selectedCount;

  const DrawnCardWidget({
    super.key,
    required this.drawnCard,
    required this.onDiscard,
    this.onSwap,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Column(
        children: [
          _buildCardDisplay(),
          const SizedBox(height: 12),
          ActionButtonsWidget(
            onDiscard: onDiscard,
            onSwap: onSwap,
            selectedCount: selectedCount,
          ),
        ],
      ),
    );
  }

  Widget _buildCardDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Gezogen: ', style: TextStyle(color: Colors.white, fontSize: 16)),
        Container(
          width: 40,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              drawnCard,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}