import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ecopoint/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End Test: Admin, User, and Collector Flows', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Helper function for login
    Future<void> loginAs(String email, String password) async {
      await tester.enterText(find.byType(TextField).at(0), email);
      await tester.enterText(find.byType(TextField).at(1), password);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // Helper function for logout
    Future<void> logout() async {
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // 1. Test Admin Flow
    await loginAs('testadmin@ecopoint.com', 'password123');
    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Scrape Latest Prices'), findsOneWidget);
    await tester.tap(find.text('Scrape Latest Prices'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await logout();

    // 2. Test User Flow
    // Tap "Don't have an account? Register"
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();
    
    // Register as User
    final userEmail = 'testuser_${DateTime.now().millisecondsSinceEpoch}@ecopoint.com';
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), userEmail);
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    // Dropdown is already 'user' by default
    await tester.tap(find.text('Register').last);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    
    // Login as the new User
    await loginAs(userEmail, 'password123');

    // Verify User Dashboard
    expect(find.text('Wallet Balance'), findsOneWidget);
    expect(find.text('New Pickup Order'), findsOneWidget);
    await tester.tap(find.text('New Pickup Order').last);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Confirm Order'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await logout();

    // 3. Test Collector Flow
    // Tap "Don't have an account? Register"
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();
    
    // Register as Collector
    final collectorEmail = 'testcollector_${DateTime.now().millisecondsSinceEpoch}@ecopoint.com';
    await tester.enterText(find.byType(TextField).at(0), 'Test Collector');
    await tester.enterText(find.byType(TextField).at(1), collectorEmail);
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    
    // Change Dropdown to collector
    await tester.tap(find.text('Waste Generator (User)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Waste Collector').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register').last);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    
    // Login as Collector
    await loginAs(collectorEmail, 'password123');

    // Verify Collector Dashboard
    expect(find.text('Collector Dashboard'), findsOneWidget);
    expect(find.text('Nearby Pending Orders'), findsOneWidget);
    expect(find.text('Total Earnings'), findsOneWidget);
    await logout();
  });
}
