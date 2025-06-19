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
    } else if (value == 12) {
      return Colors.pink[700]!; // WILD Karte
    } else if (value == 13) {
      return Colors.red[800]!; // Hohe Karte
    } else if (value == 0) {
      return Colors.green[700]!; // Niedrigste Karte
    }
    return Colors.orange[700]!; // Normale Karten (1-5)
  }

  String get description {
    if (value >= 6 && value <= 7)
      return "PEEK: Schaue dir eine eigene Karte an";
    if (value >= 8 && value <= 9) return "SPY: Schaue dir eine Gegnerkarte an";
    if (value >= 10 && value <= 11) return "SWAP: Tausche Karten";
    if (value == 12) return "WILD: Spezielle Aktion";
    if (value == 13) return "Hohe Karte (13 Punkte)";
    if (value == 0) return "Beste Karte (0 Punkte)";
    return "Normale Karte ($value Punkte)";
  }

  bool get isActionCard => value >= 6 && value <= 12;

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
