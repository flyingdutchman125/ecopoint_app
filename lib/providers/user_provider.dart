import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/price_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/mission_state.dart';
import '../core/wallet_state.dart';

class UserProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  List<PriceModel> _prices = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  List<PriceModel> get prices => _prices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void addPoints(int points) {
    if (_wallet != null) {
      _wallet = WalletModel(
        balance: _wallet!.balance,
        ecoPoints: _wallet!.ecoPoints + points,
      );
    } else {
      _wallet = WalletModel(balance: 0.0, ecoPoints: points);
    }
    WalletState.instance.addPoints(points);
    notifyListeners();
  }

  Future<void> fetchPrices() async {
    try {
      final res = await ApiService.get(ApiConstants.prices);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true || data['status'] == 'success') {
          _prices = (data['data'] as List)
              .map((p) => PriceModel.fromJson(p))
              .toList();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> fetchTransactions() async {
    try {
      final res = await ApiService.get(ApiConstants.transactions);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          _transactions = (data['data'] as List)
              .map((t) => TransactionModel.fromJson(t))
              .toList();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

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
          _orders = (data['data'] as List)
              .map((o) => OrderModel.fromJson(o))
              .toList();
          MissionState.instance.syncFromOrders(_orders);
        }
      }

      if (walletRes.statusCode == 200) {
        final data = jsonDecode(walletRes.body);
        if (data['success'] == true && data['data'] != null) {
          _wallet = WalletModel.fromJson(data['data']);
          if (_wallet != null) {
            if (_wallet!.balance > 0) {
              WalletState.instance.activeBalance.value = _wallet!.balance;
            }
            if (_wallet!.ecoPoints > 0) {
              WalletState.instance.points.value = _wallet!.ecoPoints;
            }
          }
        }
      }
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> topUp(double amount, String paymentMethod) async {
    try {
      final res = await ApiService.post(ApiConstants.walletTopup, {
        'amount': amount,
        'payment_method': paymentMethod,
      });
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchDashboardData();
        return true;
      }
      _error = data['message'] ?? 'Failed to top up';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> withdraw(
    double amount,
    String bankName,
    String accountNumber,
  ) async {
    try {
      final res = await ApiService.post(ApiConstants.walletWithdraw, {
        'amount': amount,
        'bank_name': bankName,
        'account_number': accountNumber,
      });
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchDashboardData();
        return true;
      }
      _error = data['message'] ?? 'Failed to withdraw';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String name, String phone) async {
    try {
      final res = await ApiService.put(ApiConstants.profile, {
        'name': name,
        'phone': phone,
      });
      if (res.statusCode == 200) {
        await fetchDashboardData();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final res = await ApiService.put(
        '${ApiConstants.order}/$orderId/cancel',
        {},
      );
      if (res.statusCode == 200) {
        await fetchDashboardData();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> redeemPoints(int points) async {
    // Check local points balance first
    if (WalletState.instance.currentPoints < points) {
      return false;
    }

    try {
      final res = await ApiService.post(ApiConstants.redeem, {
        'points': points,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        WalletState.instance.addPoints(-points);
        await fetchDashboardData();
        return true;
      }
      // If endpoint returns non-200, still deduct locally for offline/demo mode
      WalletState.instance.addPoints(-points);
      return true;
    } catch (_) {
      WalletState.instance.addPoints(-points);
      return true;
    }
  }

  Future<bool> createOrder({
    required String photoUrl,
    required String category,
    required double weightKg,
    required double lat,
    required double lng,
    required String address,
    String? itemType,
    double? estWeight,
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    String? notes,
  }) async {
    try {
      final res = await ApiService.post(ApiConstants.order, {
        'photo_url': photoUrl,
        'item_type': itemType ?? category,
        'weight_kg': weightKg != 0 ? weightKg : (estWeight ?? 0),
        'pickup_lat': lat != 0 ? lat : (pickupLat ?? 0),
        'pickup_lng': lng != 0 ? lng : (pickupLng ?? 0),
        'pickup_address': pickupAddress ?? address,
        'notes': ?notes,
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
