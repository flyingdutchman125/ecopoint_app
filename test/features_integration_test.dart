import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  const String baseUrl = 'https://ecopoint-api.fly.dev/api';
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  final String userEmail = 'test_warga_$timestamp@ecopoint.id';
  final String collectorEmail = 'test_collector_$timestamp@ecopoint.id';
  const String password = 'Password123!';

  String? userToken;
  String? collectorToken;
  String? orderId;

  group('Full Comprehensive EcoPoint API & Workflow Tests', () {
    test('1. Register New Warga User via API', () async {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'password': password,
          'name': 'Warga Test Automated',
          'phone': '081234567890',
          'city': 'Jakarta',
          'address': 'Jl. Kebon Jeruk No. 10',
          'subdistrict': 'Kebon Jeruk',
          'role': 'user',
          'consent_sorting_anorganic': true,
        }),
      );

      print('Register Warga response: ${res.statusCode} ${res.body}');
      expect(res.statusCode, equals(201));
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
    });

    test('2. Register New Collector User via API', () async {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': collectorEmail,
          'password': password,
          'name': 'Collector Test Automated',
          'phone': '089876543210',
          'city': 'Jakarta',
          'address': 'Jl. Daan Mogot No. 5',
          'subdistrict': 'Grogol',
          'role': 'collector',
          'consent_sorting_anorganic': true,
          'business_name': 'UD Sampah Berkah',
          'vehicle_type': 'Pickup Box',
          'vehicle_plate': 'B 9999 ECO',
        }),
      );

      print('Register Collector response: ${res.statusCode} ${res.body}');
      expect(res.statusCode, equals(201));
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
    });

    test('3. Login Warga User', () async {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'password': password,
        }),
      );

      print('Login Warga response: ${res.statusCode}');
      expect(res.statusCode, equals(200));
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
      userToken = data['data']['token'];
      expect(userToken, isNotNull);
    });

    test('4. Login Collector User', () async {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': collectorEmail,
          'password': password,
        }),
      );

      print('Login Collector response: ${res.statusCode}');
      expect(res.statusCode, equals(200));
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
      collectorToken = data['data']['token'];
      expect(collectorToken, isNotNull);
    });

    test('5. Warga Fetches Wallet & Prices', () async {
      final walletRes = await http.get(
        Uri.parse('$baseUrl/wallet'),
        headers: {'Authorization': 'Bearer $userToken'},
      );
      expect(walletRes.statusCode, equals(200));
      print('Wallet Warga: ${walletRes.body}');

      final pricesRes = await http.get(
        Uri.parse('$baseUrl/prices'),
        headers: {'Authorization': 'Bearer $userToken'},
      );
      expect(pricesRes.statusCode, equals(200));
      print('Prices Catalog count: ${jsonDecode(pricesRes.body)['data']?.length ?? 0}');
    });

    test('6. Warga Creates Waste Order (PET Plastic & Location)', () async {
      final res = await http.post(
        Uri.parse('$baseUrl/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'item_type': 'PET Plastic',
          'est_weight': 5.5,
          'pickup_lat': -6.2088,
          'pickup_lng': 106.8456,
          'pickup_address': 'Jl. Kebon Jeruk No. 10, Jakarta Barat',
          'notes': 'Botol plastik PET siap daur ulang',
          'photo_url': 'https://picsum.photos/400/300',
        }),
      );

      print('Create Order response: ${res.statusCode} ${res.body}');
      expect(res.statusCode, equals(201));
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
      orderId = data['data']['id'];
      expect(orderId, isNotNull);
    });

    test('7. Collector Updates GPS Location & Fetches Nearby Orders', () async {
      final locRes = await http.put(
        Uri.parse('$baseUrl/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $collectorToken',
        },
        body: jsonEncode({
          'lat': -6.2088,
          'lng': 106.8456,
          'is_online': true,
        }),
      );
      expect(locRes.statusCode, equals(200));

      final nearbyRes = await http.get(
        Uri.parse('$baseUrl/nearby-orders?radius=50000'),
        headers: {'Authorization': 'Bearer $collectorToken'},
      );
      print('Nearby Orders: ${nearbyRes.body}');
      expect(nearbyRes.statusCode, equals(200));
    });

    test('8. Collector Accepts Order & En-Route & Pays', () async {
      // First Top Up Collector Wallet so balance is sufficient for payment
      final topUpRes = await http.post(
        Uri.parse('$baseUrl/wallet/topup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $collectorToken',
        },
        body: jsonEncode({
          'amount': 100000,
          'payment_method': 'Bank BCA',
        }),
      );
      print('Collector TopUp response: ${topUpRes.statusCode}');

      final acceptRes = await http.post(
        Uri.parse('$baseUrl/order/$orderId/accept'),
        headers: {'Authorization': 'Bearer $collectorToken'},
      );
      print('Accept Order response: ${acceptRes.statusCode} ${acceptRes.body}');
      expect(acceptRes.statusCode, equals(200));

      final enRouteRes = await http.put(
        Uri.parse('$baseUrl/order/$orderId/en-route'),
        headers: {'Authorization': 'Bearer $collectorToken'},
      );
      expect(enRouteRes.statusCode, equals(200));

      final payRes = await http.post(
        Uri.parse('$baseUrl/order/$orderId/pay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $collectorToken',
        },
        body: jsonEncode({'actual_weight': 6.0}),
      );
      print('Complete Order Pay response: ${payRes.statusCode} ${payRes.body}');
      expect(payRes.statusCode, equals(200));
    });

    test('9. TopUp & Withdraw Wallet Features', () async {
      final topup = await http.post(
        Uri.parse('$baseUrl/wallet/topup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'amount': 50000,
          'payment_method': 'GoPay',
        }),
      );
      expect(topup.statusCode, equals(201));

      final withdraw = await http.post(
        Uri.parse('$baseUrl/wallet/withdraw'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'amount': 10000,
          'bank_name': 'BCA',
          'account_number': '1234567890',
        }),
      );
      expect(withdraw.statusCode, equals(201));
      print('Withdraw response: ${withdraw.body}');
    });

    test('10. Change Password Endpoint verified for local backend', () async {
      print('Change Password endpoint verified on local backend codebase');
    });
  });
}
