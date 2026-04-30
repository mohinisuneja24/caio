import 'package:ciao_delivery/data/models/app_role.dart';
import 'package:ciao_delivery/features/auth/login_page.dart';
import 'package:ciao_delivery/features/auth/register_page.dart';
import 'package:ciao_delivery/features/customer/cart_page.dart';
import 'package:ciao_delivery/features/customer/customer_home_page.dart';
import 'package:ciao_delivery/features/customer/order_detail_page.dart';
import 'package:ciao_delivery/features/customer/restaurant_detail_page.dart';
import 'package:ciao_delivery/features/delivery/delivery_dashboard_page.dart';
import 'package:ciao_delivery/features/restaurant/restaurant_owner_page.dart';
import 'package:ciao_delivery/features/splash/splash_page.dart';
import 'package:ciao_delivery/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

String _homeFor(AppRole role) {
  switch (role) {
    case AppRole.user:
      return '/customer';
    case AppRole.restaurant:
      return '/restaurant';
    case AppRole.delivery:
      return '/delivery';
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  final sub = ref.listen(sessionProvider, (_, __) {
    refresh.value++;
  });
  ref.onDispose(() {
    sub.close();
    refresh.dispose();
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;

      if (loc == '/splash') {
        if (session.isLoggedIn && session.role != null) {
          return _homeFor(session.role!);
        }
        return null;
      }

      final authScreens = loc == '/login' || loc == '/register';
      if (!session.isLoggedIn) {
        if (!authScreens) return '/login';
        return null;
      }

      if (session.role == null) return '/login';

      if (authScreens) return _homeFor(session.role!);

      if (session.role == AppRole.user) {
        if (loc.startsWith('/restaurant') || loc.startsWith('/delivery')) {
          return '/customer';
        }
      } else if (session.role == AppRole.restaurant) {
        if (loc.startsWith('/customer') || loc.startsWith('/delivery')) {
          return '/restaurant';
        }
      } else if (session.role == AppRole.delivery) {
        if (loc.startsWith('/customer') || loc.startsWith('/restaurant')) {
          return '/delivery';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerHomePage(),
      ),
      GoRoute(
        path: '/customer/restaurant/:rid',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['rid']!);
          return RestaurantDetailPage(restaurantId: id);
        },
      ),
      GoRoute(
        path: '/customer/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/customer/order/:oid',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['oid']!);
          return OrderDetailPage(orderId: id);
        },
      ),
      GoRoute(
        path: '/restaurant',
        builder: (context, state) => const RestaurantOwnerPage(),
      ),
      GoRoute(
        path: '/delivery',
        builder: (context, state) => const DeliveryDashboardPage(),
      ),
    ],
  );
});
