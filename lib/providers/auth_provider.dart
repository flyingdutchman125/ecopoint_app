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

  String _parseErrorMessage(Map<String, dynamic> data, String fallback) {
    final message = data['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    final error = data['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    if (error is String && error.isNotEmpty) {
      return error;
    }

    return fallback;
  }

  String _connectionErrorMessage(Object e) {
    if (e is ApiConnectionException) return e.message;
    return 'Koneksi gagal. Pastikan backend API berjalan di ${ApiConstants.baseUrl}';
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['data']['token'];
        _user = UserModel.fromJson(data['data']['user']);
        
        await _saveAuthData();
        _setLoading(false);
        return true;
      } else {
        _error = _parseErrorMessage(data, 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = _connectionErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String city,
    required String address,
    required String subdistrict,
    required String role,
    required bool consentSorting,
    String? businessName,
    String? vehicleType,
    String? vehiclePlate,
    String? ktpUrl,
  }) async {
   _setLoading(true);
   _clearError();

   try {
     final response = await ApiService.post(ApiConstants.register, {
       'email': email,
       'password': password,
       'name': name,
       'phone': phone,
       'city': city,
       'address': address,
       'subdistrict': subdistrict,
       'role': role,
       'consent_sorting_anorganic': consentSorting,
       if (businessName != null) 'business_name': businessName,
       if (vehicleType != null) 'vehicle_type': vehicleType,
       if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
       if (ktpUrl != null) 'ktp_url': ktpUrl,
     });

     final data = jsonDecode(response.body) as Map<String, dynamic>;

     if (response.statusCode == 200 || response.statusCode == 201) {
       if (data['success'] == true) {
         _setLoading(false);
         return true;
       } else {
         _error = _parseErrorMessage(data, 'Registration failed');
         _setLoading(false);
         return false;
       }
     } else {
       _error = _parseErrorMessage(data, 'Registration failed');
       _setLoading(false);
       return false;
     }
   } catch (e) {
     _error = _connectionErrorMessage(e);
     _setLoading(false);
     return false;
   }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await ApiService.put(ApiConstants.changePassword, {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = _parseErrorMessage(data, 'Failed to change password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = _connectionErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();
    try {
      final response = await ApiService.delete(ApiConstants.deleteAccount);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        await logout();
        return true;
      } else {
        _error = _parseErrorMessage(data, 'Failed to delete account');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = _connectionErrorMessage(e);
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
