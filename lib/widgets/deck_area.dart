import 'package:flutter/material.dart';
import 'card_widget.dart';

class DeckArea extends StatelessWidget {
  final String? topDiscardCard;
  final Function()? onDrawFromDeck;
  final Function()? onDrawFromDiscard;
  final bool canDraw;

  const DeckArea({
    super.key,
    this.topDiscardCard,
    this.onDrawFromDeck,
    this.onDrawFromDiscard,
    this.canDraw = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ziehstapel (verdeckt)
        Column(
          children: [
            const Text(
              'Deck',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: canDraw ? onDrawFromDeck : null,
              child: Container(
                width: 60,
                height: 84,
                decoration: BoxDecoration(
                  color: canDraw ? Colors.blue[800] : Colors.blue[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canDraw ? Colors.yellow : Colors.black,
                    width: canDraw ? 3 : 1,
                  ),
                  boxShadow: canDraw ? [
                    BoxShadow(
                      color: Colors.yellow.withValues(alpha: 0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                child: const Center(
                  child: Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 40),

        // Ablagestapel (aufgedeckt)
        Column(
          children: [
            const Text(
              'Discard',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: canDraw ? onDrawFromDiscard : null,
              child: CardWidget(
                cardValue: topDiscardCard ?? '7',
                isVisible: true,
                isSelectable: canDraw,
                onTap: canDraw ? onDrawFromDiscard : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}