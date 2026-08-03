import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/address_state.dart';
import 'core/notification_state.dart';
import 'core/history_state.dart';
import 'core/price_lock_state.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/collector_provider.dart';
import 'providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure all persistent states are fully loaded from SharedPreferences on app startup
  await AddressState.instance.init();
  await NotificationState.instance.init();
  await HistoryState.instance.init();
  await PriceLockState.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CollectorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const EcoPointApp(),
    ),
  );
}

class EcoPointApp extends StatelessWidget {
  const EcoPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return MaterialApp.router(
      title: 'EcoPoint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.createRouter(authProvider),
    );
  }
}
