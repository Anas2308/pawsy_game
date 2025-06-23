import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String cardValue;
  final bool isVisible;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.cardValue,
    required this.isVisible,
    this.isSelectable = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black;
    double borderWidth = 1;
    List<BoxShadow>? shadows;

    if (isSelected) {
      borderColor = Colors.purple;
      borderWidth = 4;
      shadows = [
        BoxShadow(
          color: Colors.purple.withValues(alpha: 0.6),
          blurRadius: 12,
          spreadRadius: 3,
        ),
      ];
    } else if (isSelectable) {
      borderColor = Colors.yellow;
      borderWidth = 3;
      shadows = [
        BoxShadow(
          color: Colors.yellow.withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ];
    }

    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          color: isVisible ? Colors.white : Colors.blue[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: shadows,
        ),
        child: Center(
          child: Text(
            isVisible ? cardValue : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isVisible ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}