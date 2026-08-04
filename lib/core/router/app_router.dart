// Router configuration — go_router re-exports Flutter types needed below
import 'package:go_router/go_router.dart';
import '../../views/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/collector_register_screen.dart';
import '../../views/user/main_shell.dart';
import '../../views/user/create_order_screen.dart';
import '../../views/collector/collector_dashboard.dart';
import '../../views/collector/collector_order_detail.dart';
import '../../views/collector/collector_order_weigh.dart';
import '../../views/collector/collector_chat_detail.dart';
import '../../views/collector/collector_earnings_page.dart'; // Import halaman pendapatan
import '../../models/order_model.dart';
import '../../views/admin/admin_home_screen.dart';
import '../../providers/auth_provider.dart';
import '../../views/user/address_page.dart';
import '../../views/user/notification_page.dart';
import '../../views/user/price_catalog_screen.dart';
import '../../views/user/ai_vision_page.dart';
import '../../views/user/points_page.dart';
import '../../views/user/warga_chat_room_page.dart';
import '../../views/user/warga_chat_list_page.dart';
import '../../views/user/rating_page.dart';
import '../../views/user/review_detail_page.dart';
import '../../views/user/route_map_page.dart';
import '../../views/user/eco_tree_page.dart';
import '../../views/user/order_page.dart';
import '../../views/user/order_tracking_page.dart';
import '../../views/user/eco_book_page.dart';
import '../../views/user/eco_book_modul_page.dart';
import '../../views/user/convert_page.dart';
import '../../views/user/convert_confirm_page.dart';
import '../../views/user/withdraw_page.dart';
import '../../views/user/withdraw_confirm_page.dart';
import '../../views/user/withdraw_verify_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final location = state.matchedLocation;
        final isAuthRoute =
            location == '/login' ||
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
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final role = extra?['role'] as String? ?? 'user';
            return RegisterScreen(role: role);
          },
        ),
        GoRoute(
          path: '/collector-register',
          name: 'collector-register',
          builder: (context, state) => CollectorBusinessScreen(
            extra: state.extra as Map<String, dynamic>?,
          ),
        ),
        GoRoute(
          path: '/register/collector',
          name: 'register-collector',
          builder: (context, state) => CollectorBusinessScreen(
            extra: state.extra as Map<String, dynamic>?,
          ),
        ),
        GoRoute(
          path: '/register/collector/ktp',
          name: 'register-collector-ktp',
          builder: (context, state) =>
              CollectorKtpScreen(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/user',
          name: 'user',
          builder: (context, state) => const MainShell(),
        ),
        GoRoute(
          path: '/create-order',
          name: 'create-order',
          builder: (context, state) =>
              CreateOrderScreen(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/ai-vision',
          name: 'ai-vision',
          builder: (context, state) => const AiVisionPage(),
        ),
        GoRoute(
          path: '/collector',
          name: 'collector',
          builder: (context, state) => const CollectorDashboard(),
        ),
        GoRoute(
          path: '/collector/order-detail',
          name: 'collector-order-detail',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              return CollectorOrderDetailPage(
                order: OrderModel.fromJson(extra),
              );
            }
            return const CollectorDashboard();
          },
        ),
        GoRoute(
          path: '/collector/order-weigh',
          name: 'collector-order-weigh',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              return CollectorOrderWeighPage(order: OrderModel.fromJson(extra));
            }
            return const CollectorDashboard();
          },
        ),
        GoRoute(
          path: '/collector/chat-detail',
          name: 'collector-chat-detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return CollectorChatDetailPage(
              name: extra?['name']?.toString() ?? 'Chat',
              preview: extra?['preview']?.toString() ?? '',
            );
          },
        ),
        GoRoute(
          path: '/warga/chat-room',
          name: 'warga-chat-room',
          builder: (context, state) =>
              WargaChatRoomPage(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/collector/earnings',
          name: 'collector-earnings',
          builder: (context, state) => const CollectorEarningsPage(),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminHomeScreen(),
        ),
        GoRoute(
          path: '/ai-price',
          name: 'ai-price',
          builder: (context, state) => const PriceCatalogScreen(),
        ),
        GoRoute(
          path: '/points',
          name: 'points',
          builder: (context, state) => const PointsPage(),
        ),
        GoRoute(
          path: '/rating',
          name: 'rating',
          builder: (context, state) => const RatingPage(),
        ),
        GoRoute(
          path: '/rating/detail',
          name: 'rating-detail',
          builder: (context, state) =>
              ReviewDetailPage(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/warga/chats',
          name: 'warga-chats',
          builder: (context, state) => const WargaChatListPage(),
        ),
        GoRoute(
          path: '/route-map',
          name: 'route-map',
          builder: (context, state) => const RouteMapPage(),
        ),
        GoRoute(
          path: '/eco-tree',
          name: 'eco-tree',
          builder: (context, state) => const EcoTreePage(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) =>
              OrderPage(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/orders/tracking',
          name: 'orders-tracking',
          builder: (context, state) =>
              OrderTrackingPage(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/eco-book',
          name: 'eco-book',
          builder: (context, state) => const EcoBookPage(),
        ),
        GoRoute(
          path: '/eco-book/modul',
          name: 'eco-book-modul',
          builder: (context, state) =>
              EcoBookModulPage(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/convert',
          name: 'convert',
          builder: (context, state) => const ConvertPage(),
        ),
        GoRoute(
          path: '/convert/confirm',
          name: 'convert-confirm',
          builder: (context, state) =>
              ConvertConfirmPage(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/withdraw',
          name: 'withdraw',
          builder: (context, state) => const WithdrawPage(),
        ),
        GoRoute(
          path: '/withdraw/confirm',
          name: 'withdraw-confirm',
          builder: (context, state) =>
              WithdrawConfirmPage(extra: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: '/withdraw/verify',
          name: 'withdraw-verify',
          builder: (context, state) =>
              WithdrawVerifyPage(extra: state.extra as Map<String, dynamic>?),
        ),
      ],
    );
  }
}
