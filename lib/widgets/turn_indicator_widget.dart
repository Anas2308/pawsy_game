import 'package:flutter/material.dart';

class TurnIndicatorWidget extends StatelessWidget {
  final String currentPlayer;
  final String turnInfo;
  final bool isProcessing;

  const TurnIndicatorWidget({
    super.key,
    required this.currentPlayer,
    required this.turnInfo,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isProcessing) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            _getPlayerIcon(),
            color: _getTextColor(),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            turnInfo,
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (currentPlayer == 'Du') return Colors.green.withValues(alpha: 0.2);
    if (currentPlayer == 'KI') return Colors.blue.withValues(alpha: 0.2);
    return Colors.grey.withValues(alpha: 0.2);
  }

  Color _getBorderColor() {
    if (currentPlayer == 'Du') return Colors.green;
    if (currentPlayer == 'KI') return Colors.blue;
    return Colors.grey;
  }

  Color _getTextColor() {
    if (currentPlayer == 'Du') return Colors.green[700]!;
    if (currentPlayer == 'KI') return Colors.blue[700]!;
    return Colors.grey[700]!;
  }

  IconData _getPlayerIcon() {
    if (currentPlayer == 'Du') return Icons.person;
    if (currentPlayer == 'KI') return Icons.computer;
    return Icons.help;
  }
}