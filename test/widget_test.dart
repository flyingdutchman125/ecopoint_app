// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecopoint/main.dart';
import 'package:ecopoint/providers/admin_provider.dart';
import 'package:ecopoint/providers/auth_provider.dart';
import 'package:ecopoint/providers/collector_provider.dart';
import 'package:ecopoint/providers/user_provider.dart';

void main() {
  testWidgets('EcoPoint splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CollectorProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: const EcoPointApp(),
      ),
    );

    expect(find.byType(EcoPointApp), findsOneWidget);
  });
}
