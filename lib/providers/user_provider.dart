import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/wallet_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class UserProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  WalletModel? _wallet;
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderRes = await ApiService.get(ApiConstants.orders);
      final walletRes = await ApiService.get(ApiConstants.wallet);

      if (orderRes.statusCode == 200) {
        final data = jsonDecode(orderRes.body);
        if (data['success'] == true) {
          _orders = (data['data'] as List).map((o) => OrderModel.fromJson(o)).toList();
        }
      }

      if (walletRes.statusCode == 200) {
        final data = jsonDecode(walletRes.body);
        if (data['success'] == true) {
          _wallet = WalletModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required String photoUrl,
    required String category,
    required double weightKg,
    required double lat,
    required double lng,
    required String address,
  }) async {
    try {
      final res = await ApiService.post(ApiConstants.order, {
        'photo_url': photoUrl,
        'item_type': category,
        'weight_kg': weightKg,
        'pickup_lat': lat,
        'pickup_lng': lng,
        'pickup_address': address,
      });

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        await fetchDashboardData();
        return true;
      }
      _error = data['message'] ?? 'Failed to create order';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }
}
