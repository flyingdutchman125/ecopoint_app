import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ecopoint/providers/auth_provider.dart';
import 'package:ecopoint/providers/admin_provider.dart';
import 'package:ecopoint/views/admin/admin_home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return '.';
  });

  testWidgets('Capture Admin Live Dashboard UI Test', (WidgetTester tester) async {
    HttpOverrides.global = null;
    tester.view.physicalSize = const Size(1080, 2240);
    tester.view.devicePixelRatio = 2.5;

    // Login as Admin
    final baseUrl = 'https://ecopoint-api.fly.dev/api';
    final adminEmail = 'admin_master@ecopoint.id';
    final adminPassword = 'password123';

    final loginRes = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': adminEmail, 'password': adminPassword}),
    );
    final loginData = jsonDecode(loginRes.body);
    final token = loginData['token'] ?? loginData['data']?['token'];

    final authProvider = AuthProvider();
    await authProvider.setMockSession(
      email: adminEmail,
      name: 'Admin Master EcoPoint',
      role: 'admin',
      id: '168712d8-4141-4b40-88c9-d7d06d4e06e6',
    );

    final adminProvider = AdminProvider();
    await adminProvider.fetchDashboardData();

    final key = GlobalKey();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: adminProvider),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: RepaintBoundary(key: key, child: const AdminHomeScreen()),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final buffer = byteData.buffer.asUint8List();
          final file = File('scratch/admin_live_dashboard.png');
          await file.writeAsBytes(buffer);
          print('SUCCESS_CAPTURE: scratch/admin_live_dashboard.png');
        }
      }
    });
  });
}
