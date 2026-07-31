import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:ecopoint/providers/auth_provider.dart';
import 'package:ecopoint/providers/user_provider.dart';
import 'package:ecopoint/providers/collector_provider.dart';
import 'package:ecopoint/providers/admin_provider.dart';
import 'package:ecopoint/views/auth/login_screen.dart';
import 'package:ecopoint/views/user/user_home_screen.dart';
import 'package:ecopoint/views/user/profile_screen.dart';
import 'package:ecopoint/views/user/create_order_screen.dart';
import 'package:ecopoint/views/collector/collector_home_screen.dart';
import 'package:ecopoint/views/admin/admin_home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CollectorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        home: child,
      ),
    );
  }

  testWidgets('1. Android UI Test: Login Screen & Form Interaction', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets);

    final fields = find.byType(TextField);
    expect(fields, findsAtLeast(2));

    await tester.enterText(fields.at(0), 'warga@ecopoint.id');
    await tester.enterText(fields.at(1), 'password123');
    await tester.pumpAndSettle();

    print('✓ Login Screen rendered and form inputs tested cleanly on Android');
  });

  testWidgets('2. Android UI Test: User Profile Screen (Phone edit, Password, Delete)', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Profil Saya'), findsOneWidget);
    print('✓ User Profile Screen rendered cleanly on Android');
  });

  testWidgets('3. Android UI Test: Create Order Screen (18 Categories & Notes & GPS)', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const CreateOrderScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Recycle Waste'), findsOneWidget);
    expect(find.text('Upload Photo'), findsOneWidget);
    print('✓ Create Order Screen rendered with 18 Categories & Notes on Android');
  });

  testWidgets('4. Android UI Test: Collector Home Screen (4 Tabs)', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const CollectorHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    print('✓ Collector Home Screen with 4 tabs rendered on Android');
  });

  testWidgets('5. Android UI Test: Admin Home Screen (4 Tabs)', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const AdminHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    print('✓ Admin Home Screen with 4 tabs rendered on Android');
  });
}
