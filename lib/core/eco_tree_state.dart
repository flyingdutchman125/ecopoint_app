import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/api_constants.dart';
import '../services/api_service.dart';
import 'notification_state.dart';

/// Central singleton state for EcoTree progress.
/// Holds current XP and computed level, persisted in SharedPreferences & synced with backend API.
class EcoTreeState {
  EcoTreeState._internal() {
    init();
  }
  static final EcoTreeState instance = EcoTreeState._internal();

  // Increased XP thresholds per level (Level 1 to Level 9)
  final List<int> xpThresholds = [
    0,
    0,
    100,
    500,
    1500,
    3500,
    7000,
    12000,
    20000,
    35000,
  ];

  final ValueNotifier<int> xp = ValueNotifier<int>(0);
  final ValueNotifier<String> name = ValueNotifier<String>('');

  ValueNotifier<int> get notifier => xp;
  ValueNotifier<String> get nameNotifier => name;

  int get currentXp => xp.value;

  double get carbonReductionKg => xp.value * 0.41;

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

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedXp = prefs.getInt('ecopoint_ecotree_xp_v1');
      if (savedXp != null) {
        xp.value = savedXp;
      }
      await syncFromApi();
    } catch (_) {}
  }

  Future<void> syncFromApi() async {
    try {
      final res = await ApiService.get('${ApiConstants.baseUrl}/dashboard');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          final totalCarbon = (data['total_carbon_reduction'] as num?)?.toDouble() ?? 0.0;
          final completedOrders = (data['completed_orders'] as num?)?.toInt() ?? 0;
          
          // XP formula: (total carbon reduction * 10) + (completed orders * 50)
          final apiXp = (totalCarbon * 10).round() + (completedOrders * 50);
          if (apiXp > xp.value) {
            setXp(apiXp);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveXp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ecopoint_ecotree_xp_v1', xp.value);
    } catch (_) {}
  }

  void addXp(int amount) {
    final oldLevel = level;
    xp.value = xp.value + amount;
    _saveXp();
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
    _saveXp();
  }

  void setName(String newName) {
    name.value = newName;
  }

  void addProcessedWasteKg(double kg) {
    final gain = (kg * 10).round();
    if (gain <= 0) return;
    addXp(gain);
  }
}
