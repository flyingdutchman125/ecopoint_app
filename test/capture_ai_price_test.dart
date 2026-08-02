import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/views/user/ai_price_page.dart';
import '../lib/providers/auth_provider.dart';
import '../lib/providers/user_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture AI Price Page Screen', (WidgetTester tester) async {
    HttpOverrides.global = null;
    tester.view.physicalSize = const Size(1080, 2240);
    tester.view.devicePixelRatio = 2.5;

    final key = GlobalKey();

    await tester.runAsync(() async {
      final userProv = UserProvider();
      await userProv.fetchPrices();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => userProv),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: RepaintBoundary(
              key: key,
              child: const AiPricePage(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File('/home/user/.gemini/antigravity-cli/brain/257437b9-a89a-4414-afe3-4eec98073572/screenshot_ai_price_live.png');
      await file.writeAsBytes(buffer);
    });
  });
}
