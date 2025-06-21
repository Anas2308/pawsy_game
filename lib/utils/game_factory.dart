// lib/utils/game_factory.dart
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../controllers/game_controller.dart';
import '../screens/layouts/two_player_layout.dart';
import '../screens/layouts/three_player_layout.dart';
import '../screens/layouts/four_player_layout.dart';
import '../screens/layouts/five_player_layout.dart';

class GameFactory {
  /// Erstellt das passende Layout basierend auf der Spieleranzahl
  static Widget createGameLayout({
    required int playerCount,
    required GameState gameState,
    required GameController gameController,
    required Function(int) onPlayerTap,
    required Function(int, int) onOpponentCardTap,
    required Function(int) onHumanCardTap,
  }) {
    switch (playerCount) {
      case 2:
        return TwoPlayerLayout(
          gameState: gameState,
          gameController: gameController,
          onPlayerTap: onPlayerTap,
          onOpponentCardTap: onOpponentCardTap,
          onHumanCardTap: onHumanCardTap,
        );

      case 3:
        return ThreePlayerLayout(
          gameState: gameState,
          gameController: gameController,
          onPlayerTap: onPlayerTap,
          onOpponentCardTap: onOpponentCardTap,
          onHumanCardTap: onHumanCardTap,
        );

      case 4:
        return FourPlayerLayout(
          gameState: gameState,
          gameController: gameController,
          onPlayerTap: onPlayerTap,
          onOpponentCardTap: onOpponentCardTap,
          onHumanCardTap: onHumanCardTap,
        );

      case 5:
        return FivePlayerLayout(
          gameState: gameState,
          gameController: gameController,
          onPlayerTap: onPlayerTap,
          onOpponentCardTap: onOpponentCardTap,
          onHumanCardTap: onHumanCardTap,
        );

      default:
        return FourPlayerLayout(
          gameState: gameState,
          gameController: gameController,
          onPlayerTap: onPlayerTap,
          onOpponentCardTap: onOpponentCardTap,
          onHumanCardTap: onHumanCardTap,
        );
    }
  }

  /// Erstellt eine Liste von Spielern für ein neues Spiel
  static List<Player> createPlayers(int playerCount) {
    List<Player> players = [];

    for (int i = 0; i < playerCount; i++) {
      players.add(
        Player(
          name: i == 0 ? 'Du' : 'Spieler ${i + 1}',
          cards: [],
          playerIndex: i,
          isHuman: i == 0,
        ),
      );
    }

    return players;
  }

  /// Validiert die Spieleranzahl
  static bool isValidPlayerCount(int playerCount) {
    return playerCount >= 2 && playerCount <= 5;
  }

  /// Gibt die empfohlene Spieleranzahl zurück
  static int getRecommendedPlayerCount() {
    return 4;
  }

  /// Gibt die minimale Spieleranzahl zurück
  static int getMinPlayerCount() {
    return 2;
  }

  /// Gibt die maximale Spieleranzahl zurück
  static int getMaxPlayerCount() {
    return 5;
  }

  /// Erstellt Spieler-Namen basierend auf der Anzahl
  static List<String> generatePlayerNames(int playerCount) {
    List<String> names = ['Du'];

    for (int i = 1; i < playerCount; i++) {
      names.add('Spieler ${i + 1}');
    }

    return names;
  }

  /// Berechnet die optimale Kartengröße basierend auf Bildschirmgröße
  static Map<String, double> calculateCardSizes(
    Size screenSize,
    int playerCount,
  ) {
    // Anpassung basierend auf Spieleranzahl
    double scaleFactor = switch (playerCount) {
      2 => 1.0,
      3 => 0.9,
      4 => 0.8,
      5 => 0.7,
      _ => 0.8,
    };

    return {
      'normalWidth': 60 * scaleFactor,
      'normalHeight': 90 * scaleFactor,
      'compactWidth': 35 * scaleFactor,
      'compactHeight': 50 * scaleFactor,
      'centerWidth': 80 * scaleFactor,
      'centerHeight': 120 * scaleFactor,
    };
  }

  /// Berechnet die optimalen Abstände basierend auf Bildschirmgröße
  static EdgeInsets calculateLayoutPadding(Size screenSize, int playerCount) {
    double padding = switch (playerCount) {
      2 => 20.0,
      3 => 16.0,
      4 => 12.0,
      5 => 8.0,
      _ => 12.0,
    };

    return EdgeInsets.all(padding);
  }
}
