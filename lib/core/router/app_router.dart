// Router configuration — go_router re-exports Flutter types needed below
import 'package:go_router/go_router.dart';
import '../../views/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/collector_register_screen.dart';
import '../../views/user/main_shell.dart'; 
import '../../views/user/create_order_screen.dart';
import '../../views/collector/collector_dashboard.dart';
import '../../views/admin/admin_dashboard.dart';
import '../../providers/auth_provider.dart';
import '../../views/user/address_page.dart';
import '../../views/user/notification_page.dart'; 
import '../../views/user/ai_price_page.dart'; 
import '../../views/user/points_page.dart'; // INTEGRASI: Import halaman Points

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
            location.startsWith('/register/collector');
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
          path: '/address',
          name: 'address',
          builder: (context, state) => const AddressPage(),
        ),
        GoRoute(
          path: '/notification', 
          name: 'notification',
          builder: (context, state) => const NotificationPage(),
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
          path: '/user',
          name: 'user',
          builder: (context, state) => const MainShell(),
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
        GoRoute(
          path: '/ai-price',
          name: 'ai-price',
          builder: (context, state) => const AiPricePage(),
        ),
        // INTEGRASI: Jalur Route baru untuk halaman Points
        GoRoute(
          path: '/points',
          name: 'points',
          builder: (context, state) => const PointsPage(),
        ),
      ],
    );
  }
}