import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class AdminProvider with ChangeNotifier {
  Map<String, dynamic> _statistics = {};
  List<UserModel> _users = [];
  List<OrderModel> _adminOrders = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get statistics => _statistics;
  List<UserModel> get users => _users;
  List<OrderModel> get adminOrders => _adminOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAdminOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get(ApiConstants.adminOrders);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          _adminOrders = (data['data'] as List)
              .map((o) => OrderModel.fromJson(o))
              .toList();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserBalance(String userId, double newBalance) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiConstants.adminUserBalance, {
        'user_id': userId,
        'amount': newBalance,
        'operation': 'add',
      });
      if (res.statusCode == 200) {
        await fetchDashboardData();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetUserPassword(String userId, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiConstants.adminResetPassword, {
        'user_id': userId,
        'new_password': newPassword,
      });
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return true;
      }
      _error = data['message'] ?? 'Gagal reset password';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.delete(ApiConstants.adminDeleteUser(userId));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        await fetchDashboardData();
        return true;
      }
      _error = data['message'] ?? 'Gagal menghapus pengguna';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOrderMessage(String messageId) async {
    try {
      final res = await ApiService.delete(
        ApiConstants.deleteMessage(messageId),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final statRes = await ApiService.get(ApiConstants.statistics);
      if (statRes.statusCode == 200) {
        final data = jsonDecode(statRes.body);
        if (data['success'] == true && data['data'] != null) {
          _statistics = data['data'];
        }
      }

      final users = <UserModel>[];
      var page = 1;
      var totalPages = 1;
      while (page <= totalPages) {
        final usersRes = await ApiService.get(
          '${ApiConstants.adminUsers}?page=$page&limit=1000',
        );
        if (usersRes.statusCode != 200) break;

        final data = jsonDecode(usersRes.body);
        if (data['success'] != true || data['data'] is! List) break;

        users.addAll(
          (data['data'] as List).map((u) => UserModel.fromJson(u)),
        );
        totalPages = (data['pagination']?['total_pages'] as num?)?.toInt() ?? 1;
        page++;
      }
      _users = users;

      final ordersRes = await ApiService.get(ApiConstants.adminOrders);
      if (ordersRes.statusCode == 200) {
        final data = jsonDecode(ordersRes.body);
        if (data['success'] == true && data['data'] is List) {
          _adminOrders = (data['data'] as List)
              .map((o) => OrderModel.fromJson(o))
              .toList();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> scrapePrices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiConstants.scrapePrices, {});
      if (res.statusCode == 200) {
        return true;
      }
      _error = 'Failed to scrape prices';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
