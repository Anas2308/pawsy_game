// lib/models/card.dart
import 'package:flutter/material.dart';

class GameCard {
  final int value;
  final bool isVisible;
  final bool isSelected;

  const GameCard({
    required this.value,
    this.isVisible = false,
    this.isSelected = false,
  });

  // Karten-Hilfsmethoden
  Color get color {
    if (value >= 6 && value <= 11) {
      return Colors.purple[700]!; // Aktionskarten (6-11)
    } else if (value == 13) {
      return Colors.red[800]!; // Hohe Karte
    } else if (value == 0) {
      return Colors.green[700]!; // Niedrigste Karte
    }
    return Colors.orange[700]!; // Normale Karten (1-5, 12)
  }

  String get description {
    if (value >= 6 && value <= 7) return "SCOUT: Erkunde eine eigene Karte";
    if (value >= 8 && value <= 9) return "STALK: Verfolge eine Gegnerkarte";
    if (value >= 10 && value <= 11) return "SWITCH: Wechsle Karten mit Gegner";
    if (value == 13) return "Hohe Karte (13 Punkte)";
    if (value == 0) return "Beste Karte (0 Punkte)";
    return "Normale Karte ($value Punkte)";
  }

  String get actionName {
    if (value >= 6 && value <= 7) return "SCOUT";
    if (value >= 8 && value <= 9) return "STALK";
    if (value >= 10 && value <= 11) return "SWITCH";
    return "";
  }

  bool get isActionCard => value >= 6 && value <= 11;

  GameCard copyWith({int? value, bool? isVisible, bool? isSelected}) {
    return GameCard(
      value: value ?? this.value,
      isVisible: isVisible ?? this.isVisible,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameCard &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          isVisible == other.isVisible &&
          isSelected == other.isSelected;

  @override
  int get hashCode => value.hashCode ^ isVisible.hashCode ^ isSelected.hashCode;
}
