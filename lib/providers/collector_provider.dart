import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class CollectorProvider with ChangeNotifier {
  List<OrderModel> _nearbyOrders = [];
  List<OrderModel> _myOrders = [];
  double _earnings = 0.0;
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get nearbyOrders => _nearbyOrders;
  List<OrderModel> get myOrders => _myOrders;
  double get earnings => _earnings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> updateLocationAndFetchNearby() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Get location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      } 

      Position position = await Geolocator.getCurrentPosition();

      // 2. Update API Location
      await ApiService.put(ApiConstants.location, {
        'lat': position.latitude,
        'lng': position.longitude,
        'status': 'online',
      });

      // 3. Fetch Nearby Orders
      final res = await ApiService.get('${ApiConstants.nearbyOrders}?radius=5000&lat=${position.latitude}&lng=${position.longitude}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          _nearbyOrders = (data['data'] as List).map((o) => OrderModel.fromJson(o)).toList();
        }
      }

      // 4. Fetch My Orders & Earnings
      final myOrdersRes = await ApiService.get(ApiConstants.collectorOrders);
      if (myOrdersRes.statusCode == 200) {
         final data = jsonDecode(myOrdersRes.body);
         if (data['success'] == true) {
            _myOrders = (data['data'] as List).map((o) => OrderModel.fromJson(o)).toList();
         }
      }

      final earnRes = await ApiService.get('${ApiConstants.earnings}?period=all');
      if (earnRes.statusCode == 200) {
         final data = jsonDecode(earnRes.body);
         if (data['success'] == true) {
            _earnings = data['data']['total'] != null ? double.parse(data['data']['total'].toString()) : 0.0;
         }
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('${ApiConstants.baseUrl}/order/$orderId/accept', {});
      if (res.statusCode == 200) {
        await updateLocationAndFetchNearby();
        return true;
      }
      _error = 'Failed to accept order';
      return false;
    } catch(e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeOrder(String orderId, double actualWeight) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('${ApiConstants.baseUrl}/order/$orderId/pay', {
        'actual_weight': actualWeight
      });
      if (res.statusCode == 200) {
        await updateLocationAndFetchNearby();
        return true;
      }
      _error = 'Failed to complete order';
      return false;
    } catch(e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
