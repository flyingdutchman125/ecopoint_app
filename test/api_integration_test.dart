import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ecopoint/models/order_model.dart';
import 'package:ecopoint/models/wallet_model.dart';
import 'package:ecopoint/models/price_model.dart';
import 'package:ecopoint/models/transaction_model.dart';
import 'package:ecopoint/models/user_model.dart';

void main() {
  const baseUrl = 'https://ecopoint-api.fly.dev/api';

  test('Live API Integration Test', () async {
    print('\n=== STARTING LIVE API INTEGRATION TEST ===');

    // 0. Register Test
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'user_$timestamp@test.com';
    final regRes = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': 'Test1234!',
        'name': 'User Test $timestamp',
        'phone': '08123456789',
        'city': 'Jakarta Selatan',
        'address': 'Jl. Kebayoran Baru No. 12',
        'subdistrict': 'Kebayoran Baru',
        'role': 'user',
        'consent_sorting_anorganic': true,
      }),
    );
    expect(regRes.statusCode, 201);
    final regData = jsonDecode(regRes.body);
    expect(regData['success'], true);
    print('  ✓ Registration successful for: $testEmail');

    // 1. Login
    final loginRes = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': 'user@test.com', 'password': 'Test1234!'}),
    );
    expect(loginRes.statusCode, 200);
    final loginData = jsonDecode(loginRes.body);
    expect(loginData['success'], true);
    final token = loginData['data']['token'];
    expect(token, isNotNull);

    // Parse User model from login
    final user = UserModel.fromJson(loginData['data']['user']);
    expect(user.id, isNotEmpty);
    print('  ✓ Login successful for: ${user.email}');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 2. Wallet
    final walletRes = await http.get(
      Uri.parse('$baseUrl/wallet'),
      headers: headers,
    );
    expect(walletRes.statusCode, 200);
    final walletData = jsonDecode(walletRes.body);
    final wallet = WalletModel.fromJson(walletData['data']);
    print('  ✓ Wallet balance: ${wallet.balance}, points: ${wallet.ecoPoints}');

    // 3. Prices
    final pricesRes = await http.get(
      Uri.parse('$baseUrl/prices'),
      headers: headers,
    );
    expect(pricesRes.statusCode, 200);
    final pricesData = jsonDecode(pricesRes.body);
    final List<dynamic> priceList = pricesData['data'];
    final prices = priceList.map((j) => PriceModel.fromJson(j)).toList();
    print('  ✓ Waste Prices count: ${prices.length}');
    for (var p in prices) {
      print('    - ${p.itemName}: Rp ${p.currentPrice}/${p.unit}');
    }

    // 4. Orders
    final ordersRes = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
    );
    expect(ordersRes.statusCode, 200);
    final ordersData = jsonDecode(ordersRes.body);
    final List<dynamic> orderList = ordersData['data'];
    final orders = orderList.map((j) => OrderModel.fromJson(j)).toList();
    print('  ✓ User Orders count: ${orders.length}');
    for (var o in orders) {
      print(
        '    - [${o.status}] ${o.itemType} (${o.estWeight}kg) at ${o.pickupAddress}',
      );
    }

    // 5. Transactions
    final txRes = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: headers,
    );
    expect(txRes.statusCode, 200);
    final txData = jsonDecode(txRes.body);
    final List<dynamic> txList = txData['data'];
    final transactions = txList
        .map((j) => TransactionModel.fromJson(j))
        .toList();
    print('  ✓ Transactions count: ${transactions.length}');

    // 6. Create Order
    final createRes = await http.post(
      Uri.parse('$baseUrl/order'),
      headers: headers,
      body: jsonEncode({
        'item_type': 'Cardboard',
        'est_weight': 3.0,
        'pickup_lat': -6.2088,
        'pickup_lng': 106.8456,
        'pickup_address': 'Jl. Kebon Jeruk No. 45, Jakarta',
        'notes': 'Tes otomatis',
      }),
    );
    expect(createRes.statusCode, 201);
    final createData = jsonDecode(createRes.body);
    final createdOrder = OrderModel.fromJson(createData['data']);
    print('  ✓ Created Order ID: ${createdOrder.id}');

    // 7. Cancel Order
    final cancelRes = await http.put(
      Uri.parse('$baseUrl/order/${createdOrder.id}/cancel'),
      headers: headers,
    );
    expect(cancelRes.statusCode, 200);
    print('  ✓ Cancelled Order ID: ${createdOrder.id}');

    print('=== ALL LIVE API INTEGRATION TESTS PASSED 100% ===\n');
  });
}
