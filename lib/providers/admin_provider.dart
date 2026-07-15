import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class AdminProvider with ChangeNotifier {
  Map<String, dynamic> _statistics = {};
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get statistics => _statistics;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final statRes = await ApiService.get(ApiConstants.statistics);
      if (statRes.statusCode == 200) {
        final data = jsonDecode(statRes.body);
        if (data['success'] == true) {
          _statistics = data['data'];
        }
      }

      final usersRes = await ApiService.get(ApiConstants.adminUsers);
      if (usersRes.statusCode == 200) {
        final data = jsonDecode(usersRes.body);
        if (data['success'] == true) {
          _users = (data['data'] as List).map((u) => UserModel.fromJson(u)).toList();
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
