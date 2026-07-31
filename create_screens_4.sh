#!/bin/bash
cat << 'INNER_EOF' > /home/user/myapp/lib/views/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.recycling, size: 100, color: Colors.white)
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: const Duration(seconds: 4)),
            const SizedBox(height: 24),
            Text(
              'EcoPoint',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 800)).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Smart Waste Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white)
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 800)),
          ],
        ),
      ),
    );
  }
}
INNER_EOF

cat << 'INNER_EOF' > /home/user/myapp/lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../../views/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/collector_register_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/user/user_home_screen.dart';
import '../../views/user/create_order_screen.dart';
import '../../views/user/price_catalog_screen.dart';
import '../../views/user/order_detail_screen.dart';
import '../../views/collector/collector_home_screen.dart';
import '../../views/admin/admin_home_screen.dart';
import '../../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final location = state.matchedLocation;
        final isAuthRoute = location == '/login' ||
            location == '/register' ||
            location.startsWith('/register/collector') ||
            location == '/forgot-password';
        final isSplash = location == '/';

        // Wait for auth init
        if (authProvider.isLoading) return null;

        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }

        if (isLoggedIn && (isAuthRoute || isSplash)) {
          final role = authProvider.user?.role;
          if (role == 'collector') return '/collector';
          if (role == 'admin') return '/admin';
          return '/user';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/register/collector',
          name: 'register-collector',
          builder: (context, state) => CollectorBusinessScreen(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/register/collector/ktp',
          name: 'register-collector-ktp',
          builder: (context, state) => CollectorKtpScreen(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/user',
          name: 'user',
          builder: (context, state) => const UserHomeScreen(),
        ),
        GoRoute(
          path: '/create-order',
          name: 'create-order',
          builder: (context, state) => const CreateOrderScreen(),
        ),
        GoRoute(
          path: '/prices',
          name: 'prices',
          builder: (context, state) => const PriceCatalogScreen(),
        ),
        GoRoute(
          path: '/order/:id',
          name: 'order-detail',
          builder: (context, state) {
            final orderId = state.pathParameters['id'] ?? '';
            return OrderDetailScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: '/collector',
          name: 'collector',
          builder: (context, state) => const CollectorHomeScreen(),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminHomeScreen(),
        ),
      ],
    );
  }
}
INNER_EOF

cat << 'INNER_EOF' > /home/user/myapp/lib/main.dart
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
INNER_EOF

echo "// Moved to user_dashboard_tab.dart" > /home/user/myapp/lib/views/user/user_dashboard.dart
echo "// Moved to collector_nearby_tab.dart" > /home/user/myapp/lib/views/collector/collector_dashboard.dart
echo "// Moved to admin_dashboard_tab.dart" > /home/user/myapp/lib/views/admin/admin_dashboard.dart

