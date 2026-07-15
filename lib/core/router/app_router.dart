import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../views/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/user/user_dashboard.dart';
import '../../views/user/create_order_screen.dart';
import '../../views/collector/collector_dashboard.dart';
import '../../views/admin/admin_dashboard.dart';
import '../../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        final isSplash = state.matchedLocation == '/';

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
          path: '/user',
          name: 'user',
          builder: (context, state) => const UserDashboard(),
        ),
        GoRoute(
          path: '/create-order',
          name: 'create-order',
          builder: (context, state) => const CreateOrderScreen(),
        ),
        GoRoute(
          path: '/collector',
          name: 'collector',
          builder: (context, state) => const CollectorDashboard(),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminDashboard(),
        ),
      ],
    );
  }
}
