import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final String id;
  final String
  category; // 'Jemput', 'Order', 'Chat', 'EcoTree', 'Withdraw', 'Convert', 'EcoBook', 'Mission'
  final String title;
  final String subtitle;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'title': title,
    'subtitle': subtitle,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id:
            json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        category: json['category']?.toString() ?? 'EcoPoint',
        title: json['title']?.toString() ?? 'Notifikasi',
        subtitle: json['subtitle']?.toString() ?? '',
        timestamp:
            DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
        isRead: json['isRead'] == true,
      );

  IconData get icon {
    switch (category) {
      case 'Jemput':
        return Icons.local_shipping;
      case 'Order':
        return Icons.receipt_long;
      case 'Chat':
        return Icons.chat_bubble_outline;
      case 'EcoTree':
        return Icons.eco;
      case 'Withdraw':
        return Icons.account_balance_wallet;
      case 'Convert':
        return Icons.sync_alt;
      case 'EcoBook':
        return Icons.menu_book;
      case 'Mission':
        return Icons.stars;
      default:
        return Icons.notifications_active;
    }
  }

  Color get iconColor {
    switch (category) {
      case 'Jemput':
        return const Color(0xFFE53935);
      case 'Order':
        return const Color(0xFFFFC107);
      case 'Chat':
        return const Color(0xFF0288D1);
      case 'EcoTree':
        return const Color(0xFF4CAF50);
      case 'Withdraw':
        return const Color(0xFF8E24AA);
      case 'Convert':
        return const Color(0xFFFB8C00);
      case 'EcoBook':
        return const Color(0xFF3F51B5);
      case 'Mission':
        return const Color(0xFF009688);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String get timeFormatted {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  String get dateFormatted {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}';
  }
}

/// Central Singleton Manager for Real Persistent Smart Notifications
class NotificationState {
  NotificationState._internal();
  static final NotificationState instance = NotificationState._internal();

  static const String _storageKey = 'ecopoint_user_notifications_v3';

  final ValueNotifier<List<NotificationItem>> notifications =
      ValueNotifier<List<NotificationItem>>([]);
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

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
        final List<NotificationItem> loaded = decoded
            .map(
              (item) => NotificationItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        notifications.value = loaded;
        _updateUnreadCount();
        return;
      }

      // Initial welcome notification if clean
      notifications.value = [
        NotificationItem(
          id: 'welcome_1',
          category: 'EcoPoint',
          title: 'Selamat Datang di EcoPoint!',
          subtitle: 'Mulai kumpulkan point dan tukar dengan saldo nyata.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];
      _updateUnreadCount();
      await _saveToPrefs();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = notifications.value.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(listMap));
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.value.where((n) => !n.isRead).length;
  }

  Future<void> addNotification({
    required String category,
    required String title,
    required String subtitle,
  }) async {
    final newItem = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final currentList = List<NotificationItem>.from(notifications.value);
    currentList.insert(0, newItem); // Put latest at top
    notifications.value = currentList;
    await _saveToPrefs();
  }

  Future<void> markAllAsRead() async {
    final currentList = List<NotificationItem>.from(notifications.value);
    for (var item in currentList) {
      item.isRead = true;
    }
    notifications.value = currentList;
    await _saveToPrefs();
  }

  Future<void> clearAll() async {
    notifications.value = [];
    await _saveToPrefs();
  }

  Future<void> deleteNotification(String id) async {
    final currentList = List<NotificationItem>.from(notifications.value);
    currentList.removeWhere((n) => n.id == id);
    notifications.value = currentList;
    await _saveToPrefs();
  }
}
