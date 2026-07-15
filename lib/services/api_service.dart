import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    return http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }
  
  static Future<http.Response> delete(String url) async {
    final headers = await _getHeaders();
    return http.delete(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> upload(String url, String filePath) async {
    final headers = await _getHeaders();
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));
    
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
