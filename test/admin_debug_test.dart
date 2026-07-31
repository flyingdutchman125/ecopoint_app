import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Register and Test Admin Account', () async {
    final baseUrl = 'https://ecopoint-api.fly.dev/api';
    final adminEmail = 'admin_master@ecopoint.id';
    final adminPassword = 'password123';

    // 1. Register Admin
    final regRes = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': adminEmail,
        'password': adminPassword,
        'name': 'Admin Master EcoPoint',
        'role': 'admin',
        'phone': '081299998888',
      }),
    );
    print('REGISTER ADMIN STATUS: ${regRes.statusCode}');
    print('REGISTER ADMIN BODY: ${regRes.body}');

    // 2. Login Admin
    final loginRes = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': adminEmail,
        'password': adminPassword,
      }),
    );
    print('LOGIN ADMIN STATUS: ${loginRes.statusCode}');
    print('LOGIN ADMIN BODY: ${loginRes.body}');

    final loginData = jsonDecode(loginRes.body);
    final token = loginData['token'] ?? loginData['data']?['token'];
    print('TOKEN: $token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Fetch Statistics
    final statRes = await http.get(Uri.parse('$baseUrl/statistics'), headers: headers);
    print('STATISTICS STATUS: ${statRes.statusCode}');
    print('STATISTICS BODY: ${statRes.body}');

    // 4. Fetch Admin Users
    final usersRes = await http.get(Uri.parse('$baseUrl/admin/users'), headers: headers);
    print('ADMIN USERS STATUS: ${usersRes.statusCode}');
    print('ADMIN USERS BODY: ${usersRes.body}');

    // 5. Fetch Admin Orders
    final ordersRes = await http.get(Uri.parse('$baseUrl/admin/orders'), headers: headers);
    print('ADMIN ORDERS STATUS: ${ordersRes.statusCode}');
    print('ADMIN ORDERS BODY: ${ordersRes.body}');
  });
}
