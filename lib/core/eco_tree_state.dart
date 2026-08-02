import 'package:flutter/material.dart';
import 'notification_state.dart';

/// Simple in-memory singleton state for EcoTree progress.
/// Holds current XP and computed level. Other widgets can listen to "notifier" to update UI.
class EcoTreeState {
  EcoTreeState._internal();
  static final EcoTreeState instance = EcoTreeState._internal();

  // Increased XP thresholds per level (Level 1 to Level 9)
  // Index 0 unused, Index 1: Lvl 1 (0 XP), Index 2: Lvl 2 (100 XP), ..., Index 9: Lvl 9 (35.000 XP)
  final List<int> xpThresholds = [0, 0, 100, 500, 1500, 3500, 7000, 12000, 20000, 35000];

  final ValueNotifier<int> xp = ValueNotifier<int>(0); // starting XP: 0

  // User display name for the EcoTree card
  final ValueNotifier<String> name = ValueNotifier<String>('');

  ValueNotifier<int> get notifier => xp;
  ValueNotifier<String> get nameNotifier => name;

  int get currentXp => xp.value;

  double get carbonReductionKg => xp.value * 0.41; // formula: XP * 0.41 = kg CO2 reduced

  int get level {
    final v = xp.value;
    for (var i = 9; i >= 1; i--) {
      if (v >= xpThresholds[i]) return i;
    }
    return 1;
  }

  String get levelTitle {
    switch (level) {
      case 1:
        return 'Bibit Kecil';
      case 2:
        return 'Kecambah Tunas';
      case 3:
        return 'Tunas Muda';
      case 4:
        return 'Tanaman Kecil';
      case 5:
        return 'Pohon Muda';
      case 6:
        return 'Pohon Sedang';
      case 7:
        return 'Pohon Rimbun';
      case 8:
        return 'Pohon Berbunga';
      case 9:
        return 'Pohon Abadi EcoPoint';
      default:
        return 'Bibit Kecil';
    }
  }

  void addXp(int amount) {
    final oldLevel = level;
    xp.value = xp.value + amount;
    final newLevel = level;
    if (newLevel > oldLevel) {
      NotificationState.instance.addNotification(
        category: 'EcoTree',
        title: 'Berhasil Meningkatkan Level!',
        subtitle: 'Selamat! Kamu berhasil mencapai EcoTree Level $newLevel.',
      );
    }
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

