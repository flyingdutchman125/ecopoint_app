import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'eco_tree_state.dart';
import 'notification_state.dart';
import 'history_state.dart';
import '../providers/user_provider.dart';

class MissionState {
  MissionState._internal();
  static final MissionState instance = MissionState._internal();

  static const String _keyClaimedCheckin = 'ecopoint_claimed_checkin_days_v2';
  static const String _keyLastCheckinTime = 'ecopoint_last_checkin_time_v2';
  static const String _keyAiScanCount = 'ecopoint_ai_scan_count_v2';
  static const String _keyAiScanClaimed = 'ecopoint_ai_scan_claimed_v2';
  static const String _keyWeeklyWeightKg = 'ecopoint_weekly_weight_kg_v2';
  static const String _keyWeightClaimed = 'ecopoint_weekly_weight_claimed_v2';
  static const String _keyMasterCategoryClaimed = 'ecopoint_master_category_claimed_v2';
  static const String _keyConsistentOrdersClaimed = 'ecopoint_consistent_orders_claimed_v2';

  final ValueNotifier<List<int>> claimedCheckinDays = ValueNotifier<List<int>>([]);
  final ValueNotifier<DateTime?> lastCheckInTime = ValueNotifier<DateTime?>(null);
  final ValueNotifier<int> aiScanCount = ValueNotifier<int>(1);
  final ValueNotifier<bool> isAiScanClaimed = ValueNotifier<bool>(false);

  final ValueNotifier<double> weeklyWeightKg = ValueNotifier<double>(2.5);
  final ValueNotifier<bool> isWeightClaimed = ValueNotifier<bool>(false);

  final ValueNotifier<int> scannedCategoriesCount = ValueNotifier<int>(1);
  final ValueNotifier<bool> isCategoryClaimed = ValueNotifier<bool>(false);

  final ValueNotifier<int> completedOrdersCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> isConsistentOrderClaimed = ValueNotifier<bool>(false);

  bool _initialized = false;

  /// Get start of current 6 AM cycle (today at 06:00 if now >= 6:00 AM, else yesterday at 06:00)
  DateTime getCurrentCycleStartTime() {
    final now = DateTime.now();
    final today6am = DateTime(now.year, now.month, now.day, 6, 0, 0);
    return now.isBefore(today6am) ? today6am.subtract(const Duration(days: 1)) : today6am;
  }

  /// Get next 6 AM reset target time
  DateTime getNextResetTime() {
    final now = DateTime.now();
    final today6am = DateTime(now.year, now.month, now.day, 6, 0, 0);
    return now.isBefore(today6am) ? today6am : today6am.add(const Duration(days: 1));
  }

  /// Remaining duration until 6 AM reset
  Duration getRemainingTimeToReset() {
    final target = getNextResetTime();
    final diff = target.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Check if user can check in during the current 6 AM cycle
  bool canCheckInToday() {
    if (lastCheckInTime.value == null) return true;
    final cycleStart = getCurrentCycleStartTime();
    return lastCheckInTime.value!.isBefore(cycleStart);
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String? checkinStr = prefs.getString(_keyClaimedCheckin);
      if (checkinStr != null && checkinStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(checkinStr);
        claimedCheckinDays.value = list.map((e) => e as int).toList();
      }

      final String? timeStr = prefs.getString(_keyLastCheckinTime);
      if (timeStr != null && timeStr.isNotEmpty) {
        lastCheckInTime.value = DateTime.tryParse(timeStr);
      }

      // Reset cycle if all 6 days claimed and new cycle arrives
      if (canCheckInToday() && claimedCheckinDays.value.length >= 6) {
        claimedCheckinDays.value = [];
      }

      aiScanCount.value = prefs.getInt(_keyAiScanCount) ?? 1;
      isAiScanClaimed.value = prefs.getBool(_keyAiScanClaimed) ?? false;

      weeklyWeightKg.value = prefs.getDouble(_keyWeeklyWeightKg) ?? 2.5;
      isWeightClaimed.value = prefs.getBool(_keyWeightClaimed) ?? false;

      isCategoryClaimed.value = prefs.getBool(_keyMasterCategoryClaimed) ?? false;
      isConsistentOrderClaimed.value = prefs.getBool(_keyConsistentOrdersClaimed) ?? false;
    } catch (e) {
      debugPrint('Error loading MissionState: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyClaimedCheckin, jsonEncode(claimedCheckinDays.value));
      if (lastCheckInTime.value != null) {
        await prefs.setString(_keyLastCheckinTime, lastCheckInTime.value!.toIso8601String());
      }
      await prefs.setInt(_keyAiScanCount, aiScanCount.value);
      await prefs.setBool(_keyAiScanClaimed, isAiScanClaimed.value);
      await prefs.setDouble(_keyWeeklyWeightKg, weeklyWeightKg.value);
      await prefs.setBool(_keyWeightClaimed, isWeightClaimed.value);
      await prefs.setBool(_keyMasterCategoryClaimed, isCategoryClaimed.value);
      await prefs.setBool(_keyConsistentOrdersClaimed, isConsistentOrderClaimed.value);
    } catch (e) {
      debugPrint('Error saving MissionState: $e');
    }
  }

  /// Triggered whenever user scans waste using AI Pilah
  Future<void> incrementAiScan() async {
    await init();
    aiScanCount.value++;
    await _saveToPrefs();
  }

  /// Triggered whenever user sets waste weight
  Future<void> addSetorWeight(double kg) async {
    await init();
    weeklyWeightKg.value += kg;
    await _saveToPrefs();
  }

  /// Calculates Luck Rate (Tingkat Kehokian) based on User EcoTree Level
  Map<String, dynamic> calculateGoldenChestReward() {
    final int level = EcoTreeState.instance.level;
    
    // Level 1: 25% luck -> 50 base points
    // Level 2: 45% luck -> 100 base points
    // Level 3: 65% luck -> 180 base points
    // Level 4: 80% luck -> 300 base points
    // Level 5+: 95% luck -> 500 base points
    int luckPercent = 25;
    int baseReward = 50;

    if (level == 2) {
      luckPercent = 45;
      baseReward = 100;
    } else if (level == 3) {
      luckPercent = 65;
      baseReward = 180;
    } else if (level == 4) {
      luckPercent = 80;
      baseReward = 300;
    } else if (level >= 5) {
      luckPercent = 95;
      baseReward = 500;
    }

    final double roll = Random().nextDouble() * 100;
    final bool isLucky = roll <= luckPercent;
    final int bonus = isLucky ? (baseReward * 0.5).round() : 0;
    final int totalReward = baseReward + bonus;

    return {
      'level': level,
      'luck_percent': luckPercent,
      'base_reward': baseReward,
      'bonus': bonus,
      'total_reward': totalReward,
      'is_lucky': isLucky,
    };
  }

  /// Claim Daily Check-In
  Future<Map<String, dynamic>?> claimCheckInDay(int dayIndex, UserProvider userProv) async {
    await init();
    if (!canCheckInToday()) return null;
    if (claimedCheckinDays.value.contains(dayIndex)) return null;

    final newList = List<int>.from(claimedCheckinDays.value);
    newList.add(dayIndex);
    claimedCheckinDays.value = newList;
    lastCheckInTime.value = DateTime.now();

    Map<String, dynamic>? chestResult;
    int pointsEarned = 70;

    if (dayIndex == 4) {
      // Golden Chest Gacha
      chestResult = calculateGoldenChestReward();
      pointsEarned = chestResult['total_reward'] as int;
    } else {
      final rewardMap = {1: 70, 2: 80, 3: 90, 5: 70, 6: 80};
      pointsEarned = rewardMap[dayIndex] ?? 70;
    }

    // Add points to user provider
    userProv.addPoints(pointsEarned);
    await _saveToPrefs();

    // Smart Notification & History
    final titleNotification = dayIndex == 4 ? 'Hadiah Peti Emas Terbuka!' : 'Daily Check-in Berhasil!';
    final descNotification = dayIndex == 4
        ? 'Kamu membuka Peti Emas (Level ${chestResult!['level']}, Kehokian ${chestResult['luck_percent']}%) dan mendapatkan +$pointsEarned EcoPoints!'
        : 'Berhasil melakukan Check-in Hari ke-$dayIndex dan mengklaim +$pointsEarned EcoPoints!';

    NotificationState.instance.addNotification(
      category: 'Misi',
      title: titleNotification,
      subtitle: descNotification,
    );

    HistoryState.instance.addHistory(
      title: titleNotification,
      description: descNotification,
      category: 'Misi & Poin',
      valueChange: '+$pointsEarned Pts',
    );

    return chestResult;
  }

  /// Claim AI Scan Mission
  Future<bool> claimAiScanMission(UserProvider userProv) async {
    await init();
    if (isAiScanClaimed.value || aiScanCount.value < 1) return false;

    isAiScanClaimed.value = true;
    userProv.addPoints(300);
    await _saveToPrefs();

    NotificationState.instance.addNotification(
      category: 'Misi',
      title: 'Misi Detektif Sampah Selesai!',
      subtitle: 'Selamat! Kamu mendapatkan 300 EcoPoints dari memindai sampah dengan AI Pilah.',
    );

    HistoryState.instance.addHistory(
      title: 'Klaim Misi Detektif Sampah',
      description: 'Menyelesaikan scan sampah dengan AI Pilah.',
      category: 'Misi & Poin',
      valueChange: '+300 Pts',
    );

    return true;
  }

  /// Claim Weekly Weight Mission
  Future<bool> claimWeightMission(UserProvider userProv) async {
    await init();
    if (isWeightClaimed.value || weeklyWeightKg.value < 5.0) return false;

    isWeightClaimed.value = true;
    userProv.addPoints(1800);
    await _saveToPrefs();

    NotificationState.instance.addNotification(
      category: 'Misi',
      title: 'Misi Pahlawan Timbangan Selesai!',
      subtitle: 'Kamu berhasil menyetor 5Kg+ sampah dan mendapatkan 1.800 EcoPoints!',
    );

    HistoryState.instance.addHistory(
      title: 'Klaim Misi Pahlawan Timbangan',
      description: 'Mencapai target akumulasi setoran 5 Kg.',
      category: 'Misi & Poin',
      valueChange: '+1.800 Pts',
    );

    return true;
  }

  /// Sync weekly mission progress directly from real completed orders
  Future<void> syncFromOrders(List<dynamic> orders) async {
    await init();
    double totalKg = 0.0;
    final Set<String> categories = {};
    int completedCount = 0;

    for (var order in orders) {
      final dynamic statusVal = order.status;
      final String status = (statusVal ?? '').toString().toLowerCase();
      if (status == 'completed' || status == 'selesai') {
        completedCount++;
        final dynamic weightVal = order.weightKg;
        final double weight = double.tryParse((weightVal ?? 0).toString()) ?? 0.0;
        totalKg += weight;
        final dynamic itemTypeVal = order.itemType;
        final String cat = (itemTypeVal ?? '').toString();
        if (cat.isNotEmpty) {
          categories.add(cat);
        }
      }
    }

    completedOrdersCount.value = completedCount;
    weeklyWeightKg.value = totalKg;
    scannedCategoriesCount.value = categories.length;

    await _saveToPrefs();
  }
}
