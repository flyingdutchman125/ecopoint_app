import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecopoint/views/collector/collector_dashboard.dart';
import 'package:ecopoint/providers/auth_provider.dart';
import 'package:ecopoint/providers/collector_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture Radar Order Tab', (WidgetTester tester) async {
    HttpOverrides.global = null;
    tester.view.physicalSize = const Size(1080, 2240);
    tester.view.devicePixelRatio = 2.5;

    final key = GlobalKey();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => CollectorProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: RepaintBoundary(key: key, child: const CollectorDashboard()),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File(
        '/home/user/.gemini/antigravity-cli/brain/257437b9-a89a-4414-afe3-4eec98073572/screenshot_collector_radar_order.png',
      );
      await file.writeAsBytes(buffer);
    });
  });

  testWidgets('Capture Peta Rute GPS Tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2240);
    tester.view.devicePixelRatio = 2.5;

    final key = GlobalKey();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => CollectorProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: RepaintBoundary(key: key, child: const CollectorDashboard()),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Peta Rute GPS'));
      await tester.pump(const Duration(milliseconds: 500));

      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File(
        '/home/user/.gemini/antigravity-cli/brain/257437b9-a89a-4414-afe3-4eec98073572/screenshot_collector_peta_gps.png',
      );
      await file.writeAsBytes(buffer);
    });
  });
}
