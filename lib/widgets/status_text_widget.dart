import 'package:flutter/material.dart';

class StatusTextWidget extends StatelessWidget {
  final String statusText;

  const StatusTextWidget({
    super.key,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}