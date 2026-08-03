import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecopoint/providers/auth_provider.dart';
import 'package:ecopoint/providers/user_provider.dart';
import 'package:ecopoint/providers/collector_provider.dart';
import 'package:ecopoint/providers/admin_provider.dart';

import 'package:ecopoint/views/auth/login_screen.dart';
import 'package:ecopoint/views/user/user_dashboard.dart';
import 'package:ecopoint/views/user/create_order_screen.dart';
import 'package:ecopoint/views/user/store_page.dart';
import 'package:ecopoint/views/user/eco_tree_page.dart';
import 'package:ecopoint/views/user/points_page.dart';
import 'package:ecopoint/views/user/history_page.dart';
import 'package:ecopoint/views/user/wallet_screen.dart';
import 'package:ecopoint/views/collector/collector_dashboard.dart';
import 'package:ecopoint/views/collector/collector_earnings_page.dart';
import 'package:ecopoint/views/admin/admin_home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return '.';
  });

  Future<void> captureWidget(
    WidgetTester tester,
    Widget widget,
    String filename,
  ) async {
    HttpOverrides.global = null;
    tester.view.physicalSize = const Size(1080, 2240);
    tester.view.devicePixelRatio = 2.5;

    final key = GlobalKey();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => CollectorProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: RepaintBoundary(key: key, child: widget),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final buffer = byteData.buffer.asUint8List();
          final outDir = Directory('screenshots');
          if (!outDir.existsSync()) outDir.createSync(recursive: true);
          final file = File('screenshots/$filename');
          await file.writeAsBytes(buffer);
          print('SUCCESS_CAPTURE: screenshots/$filename');
        }
      }
    });
  }

  testWidgets('Capture Login Screen', (WidgetTester tester) async {
    await captureWidget(tester, const LoginScreen(), '01_login_screen.png');
  });

  testWidgets('Capture Warga Dashboard Screen', (WidgetTester tester) async {
    await captureWidget(tester, const UserDashboard(), '02_warga_dashboard.png');
  });

  testWidgets('Capture Warga Create Order Screen', (WidgetTester tester) async {
    await captureWidget(tester, const CreateOrderScreen(), '03_warga_create_order.png');
  });

  testWidgets('Capture Warga Store Page', (WidgetTester tester) async {
    await captureWidget(tester, const StorePage(), '04_warga_store.png');
  });

  testWidgets('Capture Warga Eco Tree Page', (WidgetTester tester) async {
    await captureWidget(tester, const EcoTreePage(), '05_warga_eco_tree.png');
  });

  testWidgets('Capture Warga Points Page', (WidgetTester tester) async {
    await captureWidget(tester, const PointsPage(), '06_warga_points.png');
  });

  testWidgets('Capture Warga History Page', (WidgetTester tester) async {
    await captureWidget(tester, const HistoryPage(), '07_warga_history.png');
  });

  testWidgets('Capture Warga Wallet Screen', (WidgetTester tester) async {
    await captureWidget(tester, const WalletScreen(), '08_warga_wallet.png');
  });

  testWidgets('Capture Collector Dashboard Screen', (WidgetTester tester) async {
    await captureWidget(tester, const CollectorDashboard(), '09_collector_dashboard.png');
  });

  testWidgets('Capture Collector Earnings Page', (WidgetTester tester) async {
    await captureWidget(tester, const CollectorEarningsPage(), '10_collector_earnings.png');
  });

  testWidgets('Capture Admin Home Screen', (WidgetTester tester) async {
    await captureWidget(tester, const AdminHomeScreen(), '11_admin_home.png');
  });
}
