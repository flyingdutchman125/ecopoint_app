import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_state.dart';
import 'notification_state.dart';

class PriceLockState {
  PriceLockState._internal();
  static final PriceLockState instance = PriceLockState._internal();

  static const String _storageKey = 'ecopoint_price_locks_v1';

  // Map of normalized commodity key -> DateTime lockedUntil
  final ValueNotifier<Map<String, String>> lockedPrices =
      ValueNotifier<Map<String, String>>({});

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await loadFromPrefs();
  }

  /// Maps alias names to canonical keys so Dashboard and AI Price Page share state
  String _normalizeKey(String rawName) {
    final lower = rawName.trim().toLowerCase();
    if (lower.contains('kardus') || lower.contains('cardboard'))
      return 'cardboard';
    if (lower.contains('logam') ||
        lower.contains('besi') ||
        lower.contains('metal'))
      return 'metal';
    if (lower.contains('plastik') || lower.contains('pet'))
      return 'pet_plastic';
    if (lower.contains('minyak') ||
        lower.contains('jelantah') ||
        lower.contains('cooking'))
      return 'cooking_oil';
    return lower.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        final Map<String, String> loadedMap = {};
        decoded.forEach((key, value) {
          loadedMap[key] = value.toString();
        });
        lockedPrices.value = loadedMap;
      }
    } catch (e) {
      debugPrint('Error loading price locks: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(lockedPrices.value));
    } catch (e) {
      debugPrint('Error saving price locks: $e');
    }
  }

  bool isLocked(String commodityName) {
    final key = _normalizeKey(commodityName);
    final isoStr = lockedPrices.value[key];
    if (isoStr == null) return false;
    final until = DateTime.tryParse(isoStr);
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      // Expired lock
      return false;
    }
    return true;
  }

  DateTime? getLockedUntil(String commodityName) {
    final key = _normalizeKey(commodityName);
    final isoStr = lockedPrices.value[key];
    if (isoStr == null) return null;
    final until = DateTime.tryParse(isoStr);
    if (until == null || DateTime.now().isAfter(until)) return null;
    return until;
  }

  Duration? getRemainingDuration(String commodityName) {
    final until = getLockedUntil(commodityName);
    if (until == null) return null;
    final diff = until.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  Future<bool> lockCommodity(String commodityName, {double? price}) async {
    final key = _normalizeKey(commodityName);
    final until = DateTime.now().add(const Duration(hours: 24));

    final currentMap = Map<String, String>.from(lockedPrices.value);
    currentMap[key] = until.toIso8601String();
    lockedPrices.value = currentMap;
    await _saveToPrefs();

    // Log history and notification
    final priceStr = price != null ? ' (Rp ${price.toInt()}/kg)' : '';
    HistoryState.instance.addHistory(
      title: 'Kunci Harga Komoditas',
      description: 'Mengunci harga "$commodityName"$priceStr selama 24 jam',
      category: 'Kunci Harga',
      valueChange: 'Terkunci 24 Jam',
    );

    NotificationState.instance.addNotification(
      category: 'Kunci Harga',
      title: 'Harga $commodityName Berhasil Dikunci!',
      subtitle:
          'Harga $commodityName terjamin tidak akan turun selama 24 jam ke depan.',
    );

    return true;
  }

  Future<void> unlockCommodity(String commodityName) async {
    final key = _normalizeKey(commodityName);
    final currentMap = Map<String, String>.from(lockedPrices.value);
    currentMap.remove(key);
    lockedPrices.value = currentMap;
    await _saveToPrefs();
  }
}
