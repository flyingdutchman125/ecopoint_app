import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:ecopoint/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Profile Tab Logout Flow', (WidgetTester tester) async {
    // 1. Launch main application on Android
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    print('✓ Step 1: App Launched on Android Emulator');

    // Register fresh user via backend API to ensure 100% login success
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'logout_test_$timestamp@ecopoint.id';
    final testPassword = 'Password123!';

    try {
      final res = await http.post(
        Uri.parse('https://ecopoint-api.fly.dev/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': testEmail,
          'password': testPassword,
          'name': 'Logout Tester',
          'role': 'user',
          'phone': '081234567890',
          'city': 'Jakarta',
          'address': 'Jl. Testing No. 1',
          'subdistrict': 'Kebayoran Baru',
          'consent_sorting_anorganic': true,
        }),
      );
      print('Register API status: ${res.statusCode}');
    } catch (e) {
      print('Register exception: $e');
    }

    // 2. Expect to see Login Screen
    expect(find.text('ECO POINT'), findsOneWidget);
    print('✓ Step 2: Login Screen Rendered');

    // 3. Fill Email & Password fields
    final textFields = find.byType(TextField);
    expect(textFields, findsAtLeast(2));

    await tester.enterText(textFields.at(0), testEmail);
    await tester.pumpAndSettle();

    await tester.enterText(textFields.at(1), testPassword);
    await tester.pumpAndSettle();

    // 4. Dismiss soft keyboard and Tap Login Button
    await tester.showKeyboard(textFields.at(1));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
    expect(loginButton, findsOneWidget);
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 8));
    print('✓ Step 3: Logged In as User');

    // 5. Tap 'Profile' Tab in Bottom Navigation
    final profileTab = find.text('Profile');
    expect(
      profileTab,
      findsOneWidget,
      reason: 'Expected Profile tab on MainShell',
    );
    await tester.tap(profileTab);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✓ Step 4: Switched to Profile Tab');

    // 6. Scroll down if needed and tap 'Keluar dari akun'
    final logoutBtn = find.text('Keluar dari akun');
    expect(
      logoutBtn,
      findsOneWidget,
      reason: 'Expected Keluar dari akun button on ProfilePage',
    );
    await tester.ensureVisible(logoutBtn);
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✓ Step 5: Tapped Keluar dari akun - Dialog Displayed');

    // 7. Verify AlertDialog appears with title 'Keluar Akun'
    expect(find.text('Keluar Akun'), findsOneWidget);
    expect(
      find.text('Apakah Anda yakin ingin keluar dari akun EcoPoint?'),
      findsOneWidget,
    );

    // 8. Tap 'Keluar' button inside AlertDialog
    final confirmLogoutBtn = find.widgetWithText(TextButton, 'Keluar');
    expect(confirmLogoutBtn, findsOneWidget);
    await tester.tap(confirmLogoutBtn);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    print('✓ Step 6: Confirmed Logout');

    // 9. Verify redirected back to Login Screen
    expect(find.text('ECO POINT'), findsOneWidget);
    expect(find.text('Masuk Ke Akun'), findsOneWidget);
    print('✓ Step 7: Successfully Redirected to Login Screen After Logout');

    print('\n=== LOGOUT TEST VERIFIED SUCCESSFULLY ===');
  });
}
