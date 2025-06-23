import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const PawsyApp());
}

class PawsyApp extends StatelessWidget {
  const PawsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAWSY Game',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const GameScreen(),
    );
  }
}