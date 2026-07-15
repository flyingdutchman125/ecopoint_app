import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    
    if (_token != null && userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['data']['token'];
        _user = UserModel.fromJson(data['data']['user']);
        
        await _saveAuthData();
        _setLoading(false);
        return true;
      } else {
        _error = data['message'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post(ApiConstants.register, {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
           _setLoading(false);
           return true;
        } else {
           _error = data['message'] ?? 'Registration failed';
           _setLoading(false);
           return false;
        }
      } else {
        _error = data['message'] ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('auth_token', _token!);
    }
    if (_user != null) {
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
