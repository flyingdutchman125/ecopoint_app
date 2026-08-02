import 'package:flutter/material.dart';

/// Simple in-memory singleton state for EcoTree progress.
/// Holds current XP and computed level. Other widgets can listen to "notifier" to update UI.
class EcoTreeState {
  EcoTreeState._internal();
  static final EcoTreeState instance = EcoTreeState._internal();

  // XP required per level (example)
  final List<int> xpThresholds = [0, 110, 220, 350, 550, 900, 3550, 10000];

  final ValueNotifier<int> xp = ValueNotifier<int>(0); // starting XP: 0

  // User display name for the EcoTree card
  final ValueNotifier<String> name = ValueNotifier<String>('');

  ValueNotifier<int> get notifier => xp;
  ValueNotifier<String> get nameNotifier => name;

  int get currentXp => xp.value;

  double get carbonReductionKg => xp.value * 0.41; // formula: XP * 0.41 = kg CO2 reduced

  int get level {
    final v = xp.value;
    for (var i = xpThresholds.length - 1; i >= 0; i--) {
      if (v >= xpThresholds[i]) return i; // level index matches threshold index
    }
    return 0;
  }

  void addXp(int amount) {
    xp.value = xp.value + amount;
  }

  void setXp(int value) {
    xp.value = value;
  }

  void setName(String newName) {
    name.value = newName;
  }

  /// When an order completes and AI sorting reports N kilograms processed,
  /// call this method to register processed waste. By design carbon reduction
  /// is (kg * 0.41) and XP is derived so that XP * 0.41 == carbonReduction.
  /// Therefore we add XP equal to the rounded kilograms processed.
  void addProcessedWasteKg(double kg) {
    final gain = kg.round();
    if (gain <= 0) return;
    addXp(gain);
  }
}

