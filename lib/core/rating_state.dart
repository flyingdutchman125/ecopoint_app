import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'constants/api_constants.dart';

class RatingState {
  RatingState._internal();
  static final RatingState instance = RatingState._internal();

  static const String _unreviewedKey = 'ecopoint_unreviewed_orders_v1';
  static const String _reviewedKey = 'ecopoint_reviewed_orders_v1';

  final ValueNotifier<List<Map<String, dynamic>>> unreviewedOrders =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<List<Map<String, dynamic>>> reviewedOrders =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? unrevStr = prefs.getString(_unreviewedKey);
      final String? revStr = prefs.getString(_reviewedKey);

      if (unrevStr != null && unrevStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(unrevStr);
        unreviewedOrders.value = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        unreviewedOrders.value = [
          {
            'id': 'r1',
            'orderId': 'EP_0003',
            'name': 'Bapak Sutarjo Sangar',
            'detail': 'Kardus, 12kg',
            'time': '14.50',
            'date': '03 Agustus 2026',
            'orderCode': 'EP 0003',
            'avatar': null,
          },
          {
            'id': 'r4',
            'orderId': 'EP_0004',
            'name': 'Pak Anto Pengepul Sukorejo',
            'detail': 'Minyak Jelantah, 5 Liter',
            'time': '10.15',
            'date': '02 Agustus 2026',
            'orderCode': 'EP 0004',
            'avatar': null,
          },
        ];
      }

      if (revStr != null && revStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(revStr);
        reviewedOrders.value = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        reviewedOrders.value = [
          {
            'id': 'r2',
            'orderId': 'EP_0002',
            'name': 'Hendra Pengepul gantenk',
            'detail': 'Kardus, 2kg',
            'rating': 5,
            'time': '12.20',
            'date': '21 Juli 2026',
            'avatar': null,
            'text':
                'Pelayanan bagus, orangnya ramah top markotop pokonya buat Bang Hendra!',
            'orderCode': 'EP 0002',
          },
          {
            'id': 'r3',
            'orderId': 'EP_0001',
            'name': 'Bapak Muftar',
            'detail': 'Botol Plastik, 2kg',
            'rating': 4,
            'time': '14.20',
            'date': '20 Juli 2026',
            'avatar': null,
            'text': 'Cepat dan rapi, recommended banget!',
            'orderCode': 'EP 0001',
          },
        ];
      }
      await _saveToPrefs();
    } catch (e) {
      debugPrint('Error loading rating state: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_unreviewedKey, jsonEncode(unreviewedOrders.value));
      await prefs.setString(_reviewedKey, jsonEncode(reviewedOrders.value));
    } catch (e) {
      debugPrint('Error saving rating state: $e');
    }
  }

  Future<bool> submitReview({
    required Map<String, dynamic> item,
    required int rating,
    required String text,
  }) async {
    await init();
    final String orderId = item['orderId'] ?? item['id'] ?? 'order_${DateTime.now().millisecondsSinceEpoch}';

    // Try posting to backend API if orderId is valid
    try {
      if (!orderId.startsWith('r')) {
        await ApiService.post('${ApiConstants.order}/$orderId/review', {
          'reviewee_id': item['collector_id'] ?? 'c1',
          'rating': rating,
          'comment': text,
        });
      }
    } catch (_) {
      // Continue offline saving
    }

    final newReviewedItem = {
      'id': item['id'] ?? 'r_${DateTime.now().millisecondsSinceEpoch}',
      'orderId': orderId,
      'name': item['name'] ?? 'Kolektor Daur Ulang',
      'detail': item['detail'] ?? 'Sampah Daur Ulang',
      'rating': rating,
      'time': item['time'] ?? 'Hari ini',
      'date': item['date'] ?? '03 Agustus 2026',
      'text': text.isNotEmpty ? text : 'Penjemputan sangat memuaskan!',
      'orderCode': item['orderCode'] ?? 'EP ${orderId.replaceAll(RegExp(r'[^0-9]'), '')}',
      'avatar': item['avatar'],
    };

    // Add to reviewed list
    final List<Map<String, dynamic>> revList = List.from(reviewedOrders.value);
    revList.insert(0, newReviewedItem);
    reviewedOrders.value = revList;

    // Remove from unreviewed list
    final List<Map<String, dynamic>> unrevList = List.from(unreviewedOrders.value);
    unrevList.removeWhere((e) => e['id'] == item['id'] || e['orderId'] == orderId);
    unreviewedOrders.value = unrevList;

    await _saveToPrefs();
    return true;
  }
}
