import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/collector_provider.dart';
import 'providers/admin_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
