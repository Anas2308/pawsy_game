// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF1B5E20);
  static const Color primary = Colors.green;

  // Karten-Farben
  static const Color playerCard = Colors.orange;
  static const Color opponentCard = Color(0xFF1565C0); // Colors.blue[900]
  static const Color emptyCard = Color(0xFF616161); // Colors.grey[600]
  static const Color deckCard = Color(0xFF4A148C); // Colors.purple[900]

  // Interaktion
  static const Color selectedCard = Colors.yellow;
  static const Color interactiveCard = Colors.yellow;

  // UI Elemente
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E0E0); // Colors.white70
  static const Color border = Color(0xFFBDBDBD); // Colors.grey[400]
}

class CardSizes {
  static const double normalWidth = 60;
  static const double normalHeight = 90;
  static const double compactWidth = 35;
  static const double compactHeight = 50;

  static const double centerWidth = 80;
  static const double centerHeight = 120;

  static const double drawnWidth = 100;
  static const double drawnHeight = 150;
}

class GameConstants {
  static const int maxCardsPerPlayer = 4;
  static const int cardsInDeck = 50;

  // Karten-Verteilung
  static const Map<int, int> cardCounts = {
    0: 2, // 2x Null
    13: 2, // 2x Dreizehn
    // 1-12: je 4x (wird in DeckController berechnet)
  };

  // Animationszeiten
  static const Duration dealingDuration = Duration(milliseconds: 500);
  static const Duration drawDuration = Duration(milliseconds: 300);
  static const Duration discardFlipDuration = Duration(milliseconds: 800);
  static const Duration betweenCardDelay = Duration(milliseconds: 200);
}

class GameStrings {
  static const String appTitle = '🐾 Pawsy';
  static const String newGame = 'Neues Spiel';
  static const String drawPile = 'ZIEHEN';
  static const String yourCards = 'Deine Karten';

  // Spieler-Namen
  static const String humanPlayer = 'Du';
  static String aiPlayer(int index) => 'Spieler $index';

  // Spielphasen
  static const String dealing = 'Teile Karten aus...';
  static const String lookAtCards = 'Schaue dir 2 deiner Karten an!';
  static const String yourTurn = 'Du bist dran!';
  static const String opponentTurn = 'Gegner ist dran...';
  static const String cardDrawn = 'Gezogene Karte:';
  static const String clickToInteract =
      'Klicke Ablagestapel oder deine Karten!';
  static const String drawingFromDiscard = 'Ziehe Karte vom Ablagestapel...';
  static const String pawsyButton = 'PAWSY!';
  static const String pawsyDisabled = 'Ziehe keine Karte um PAWSY zu rufen!';
}
