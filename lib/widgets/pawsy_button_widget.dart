import 'package:flutter/material.dart';

class PawsyButtonWidget extends StatelessWidget {
  final VoidCallback onPawsy;
  final bool canCallPawsy;

  const PawsyButtonWidget({
    super.key,
    required this.onPawsy,
    required this.canCallPawsy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: canCallPawsy ? onPawsy : null,
        icon: const Icon(Icons.pets, size: 20),
        label: const Text('PAWSY!'),
        style: ElevatedButton.styleFrom(
          backgroundColor: canCallPawsy ? Colors.orange[700] : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: canCallPawsy ? 8 : 0,
          shadowColor: canCallPawsy ? Colors.orange.withValues(alpha: 0.5) : null,
        ),
      ),
    );
  }
}