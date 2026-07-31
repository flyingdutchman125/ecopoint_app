import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:ecopoint/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full Android UI Navigation and Interactive Test', (WidgetTester tester) async {
    // 1. Launch main application on Android
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    print('✓ Step 1: App Launched on Android Emulator');

    // 1b. Register fresh user via backend API to ensure 100% login success
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'ui_test_$timestamp@ecopoint.id';
    final testPassword = 'Password123!';

    try {
      await http.post(
        Uri.parse('https://ecopoint-api.fly.dev/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': testEmail,
          'password': testPassword,
          'name': 'UI Tester',
          'role': 'user',
          'phone': '081234567890',
          'city': 'Jakarta',
          'address': 'Jl. Testing No. 1',
          'subdistrict': 'Kebayoran Baru',
        }),
      );
    } catch (_) {}

    // 2. Expect to see Login Screen
    expect(find.text('ECO POINT'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets);
    print('✓ Step 2: Login Screen Rendered with Brand & Typography');

    // 3. Fill Email & Password fields
    final textFields = find.byType(TextField);
    expect(textFields, findsAtLeast(2));

    await tester.enterText(textFields.at(0), testEmail);
    await tester.pumpAndSettle();
    
    await tester.enterText(textFields.at(1), testPassword);
    await tester.pumpAndSettle();
    print('✓ Step 3: Filled Form Inputs ($testEmail)');

    // 4. Dismiss soft keyboard and Tap Login Button
    await tester.showKeyboard(textFields.at(1));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
    expect(loginButton, findsOneWidget);
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 8));
    print('✓ Step 4: Attempted Login via Live API');

    // 5. Verify Home Dashboard Rendered (User, Collector, or Admin)
    final dashboardFound = find.text('Total Saldo').evaluate().isNotEmpty ||
        find.text('Halo,').evaluate().isNotEmpty ||
        find.text('Pesanan Terdekat').evaluate().isNotEmpty ||
        find.text('Dashboard').evaluate().isNotEmpty;

    expect(dashboardFound, isTrue, reason: 'Expected dashboard to render after login');
    print('✓ Step 5: Dashboard UI Rendered Successfully for Authenticated Role');

    // 6. Test Bottom Navigation Switching
    // Tap 'Pesanan' Tab (index 1)
    final pesananTab = find.text('Pesanan');
    if (pesananTab.evaluate().isNotEmpty) {
      await tester.tap(pesananTab.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Step 6a: Navigated to Pesanan Tab');
    }

    // Tap 'Dompet' Tab
    final dompetTab = find.text('Dompet');
    if (dompetTab.evaluate().isNotEmpty) {
      await tester.tap(dompetTab.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Step 6b: Navigated to Dompet Tab (Saldo & Eco Points)');
    }

    // Tap 'Profil' Tab
    final profilTab = find.text('Profil');
    if (profilTab.evaluate().isNotEmpty) {
      await tester.tap(profilTab.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Step 6c: Navigated to Profil Tab');
    }

    // Tap 'Beranda' Tab
    final berandaTab = find.text('Beranda');
    if (berandaTab.evaluate().isNotEmpty) {
      await tester.tap(berandaTab.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Step 6d: Navigated back to Beranda Tab');
    }

    // 7. Test Opening Create Order Screen
    final buatPesananBtn = find.text('Buat Pesanan');
    await tester.tap(buatPesananBtn.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Recycle Waste'), findsOneWidget);
    print('✓ Step 7: Navigated to Create Order Screen UI (Recycle Waste)');

    print('\n=== ALL ANDROID UI & TAP TESTS COMPLETED SUCCESSFULLY ===');
  });
}
