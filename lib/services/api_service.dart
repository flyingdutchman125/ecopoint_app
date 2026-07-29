import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';

class ApiConnectionException implements Exception {
  ApiConnectionException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Never _rethrowAsConnectionError(Object error) {
    if (error is ApiConnectionException) throw error;
    if (error is TimeoutException) {
      throw ApiConnectionException(
        'Server tidak merespons (timeout). Pastikan backend API berjalan di ${ApiConstants.baseUrl}',
      );
    }
    if (error is SocketException) {
      throw ApiConnectionException(
        'Tidak dapat terhubung ke server. Pastikan backend API berjalan di ${ApiConstants.baseUrl}',
      );
    }
    throw ApiConnectionException('Koneksi gagal: $error');
  }

  static Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(_timeout, onTimeout: () {
      throw TimeoutException('Request timed out after ${_timeout.inSeconds}s');
    });
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      return await _withTimeout(
        http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      );
    } catch (e) {
      _rethrowAsConnectionError(e);
    }
  }

  static Future<http.Response> get(String url) async {
    try {
      final headers = await _getHeaders();
      return await _withTimeout(http.get(Uri.parse(url), headers: headers));
    } catch (e) {
      _rethrowAsConnectionError(e);
    }
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      return await _withTimeout(
        http.put(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      );
    } catch (e) {
      _rethrowAsConnectionError(e);
    }
  }

  static Future<http.Response> delete(String url) async {
    try {
      final headers = await _getHeaders();
      return await _withTimeout(http.delete(Uri.parse(url), headers: headers));
    } catch (e) {
      _rethrowAsConnectionError(e);
    }
  }

  static Future<http.Response> upload(String url, String filePath) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      final streamedResponse = await _withTimeout(request.send());
      return await _withTimeout(http.Response.fromStream(streamedResponse));
    } catch (e) {
      _rethrowAsConnectionError(e);
    }
  }
}
