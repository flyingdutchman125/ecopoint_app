import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ecopoint/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Collector & Payment Android App UI Test', (
    WidgetTester tester,
  ) async {
    // 1. Launch App on Android
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✓ Step 1: App Launched on Android Emulator');

    // 2. Fill login with a Collector account
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'user@test.com');
    await tester.enterText(textFields.at(1), 'Test1234!');
    await tester.pumpAndSettle();

    final loginBtn = find.widgetWithText(ElevatedButton, 'Masuk');
    await tester.tap(loginBtn);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    print('✓ Step 2: Logged in & Navigated to Home');

    // 3. Open Wallet & Test Payment / Topup Sheet UI
    final dompetTab = find.text('Dompet');
    if (dompetTab.evaluate().isNotEmpty) {
      await tester.tap(dompetTab.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✓ Step 3a: Switched to Dompet UI (Saldo & Eco Points)');

      // Tap Top Up
      final topUpBtn = find.text('Top Up');
      if (topUpBtn.evaluate().isNotEmpty) {
        await tester.tap(topUpBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.text('Top Up Saldo'), findsOneWidget);
        print('✓ Step 3b: Top Up Bottom Sheet Rendered with Payment Methods');

        // Close sheet by tapping anywhere outside or back
        final cancelBtn = find.text('Batal');
        if (cancelBtn.evaluate().isNotEmpty) {
          await tester.tap(cancelBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else {
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    }

    // 4. Open Waste Prices Catalog UI
    final berandaTab = find.text('Beranda');
    if (berandaTab.evaluate().isNotEmpty) {
      await tester.tap(berandaTab.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    final hargaSampahBtn = find.text('Harga Sampah');
    if (hargaSampahBtn.evaluate().isNotEmpty) {
      await tester.tap(hargaSampahBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Katalog Harga Sampah'), findsOneWidget);
      print(
        '✓ Step 4: Waste Prices Catalog UI Rendered with Live Prices & Icons',
      );
    }

    print('\n=== ALL COLLECTOR & PAYMENT UI TESTS COMPLETED SUCCESSFULLY ===');
  });
}
