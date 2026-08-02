import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String id;
  final String title;
  final String description;
  final String category; // 'Jemput', 'Tukar Point', 'Withdraw', 'EcoTree', 'EcoBook', 'Kunci Harga', 'Alamat', 'Rating'
  final DateTime timestamp;
  final String? valueChange; // e.g. '+500 Pts', '-50 Pts', 'Rp 50.000'
  final String status;

  HistoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    this.valueChange,
    this.status = 'Selesai',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'timestamp': timestamp.toIso8601String(),
        'valueChange': valueChange,
        'status': status,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title']?.toString() ?? 'Aktivitas',
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? 'Lainnya',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
        valueChange: json['valueChange']?.toString(),
        status: json['status']?.toString() ?? 'Selesai',
      );

  IconData get icon {
    switch (category) {
      case 'Jemput':
        return Icons.local_shipping;
      case 'Tukar Point':
        return Icons.sync_alt;
      case 'Withdraw':
        return Icons.account_balance_wallet;
      case 'EcoTree':
        return Icons.eco;
      case 'EcoBook':
        return Icons.menu_book;
      case 'Kunci Harga':
        return Icons.lock_clock;
      case 'Alamat':
        return Icons.location_on;
      case 'Rating':
        return Icons.star;
      default:
        return Icons.history;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'Jemput':
        return const Color(0xFFE53935);
      case 'Tukar Point':
        return const Color(0xFFFB8C00);
      case 'Withdraw':
        return const Color(0xFF8E24AA);
      case 'EcoTree':
        return const Color(0xFF4CAF50);
      case 'EcoBook':
        return const Color(0xFF3F51B5);
      case 'Kunci Harga':
        return const Color(0xFF009688);
      case 'Alamat':
        return const Color(0xFF0288D1);
      case 'Rating':
        return const Color(0xFFFFB300);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String get dateFormatted {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}';
  }

  String get timeFormatted {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Central Persistent State for Real User Activity History
class HistoryState {
  HistoryState._internal();
  static final HistoryState instance = HistoryState._internal();

  static const String _storageKey = 'ecopoint_user_history_v3';

  final ValueNotifier<List<HistoryItem>> historyList = ValueNotifier<List<HistoryItem>>([]);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final List<HistoryItem> loaded = decoded
            .map((item) => HistoryItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        historyList.value = loaded;
        return;
      }

      // Default real initial user activity log if clean
      historyList.value = [
        HistoryItem(
          id: 'hist_init_1',
          title: 'Membuka Akun EcoPoint',
          description: 'Aplikasi EcoPoint berhasil diaktifkan untuk transaksi pemilahan sampah.',
          category: 'Alamat',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          valueChange: 'Akun Aktif',
          status: 'Sukses',
        ),
      ];
      await _saveToPrefs();
    } catch (e) {
      debugPrint('Error loading user history: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = historyList.value.map((h) => h.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(listMap));
    } catch (e) {
      debugPrint('Error saving user history: $e');
    }
  }

  Future<void> addHistory({
    required String title,
    required String description,
    required String category,
    String? valueChange,
    String status = 'Sukses',
  }) async {
    final newItem = HistoryItem(
      id: 'HIS_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      category: category,
      timestamp: DateTime.now(),
      valueChange: valueChange,
      status: status,
    );

    final current = List<HistoryItem>.from(historyList.value);
    current.insert(0, newItem);
    historyList.value = current;
    await _saveToPrefs();
  }

  Future<void> clearHistory() async {
    historyList.value = [];
    await _saveToPrefs();
  }
}
