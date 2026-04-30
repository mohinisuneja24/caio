import 'package:ciao_delivery/data/models/app_role.dart';
import 'package:ciao_delivery/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _go());
  }

  void _go() {
    final s = ref.read(sessionProvider);
    if (!mounted) return;
    if (!s.isLoggedIn || s.role == null) {
      context.go('/login');
      return;
    }
    final role = s.role!;
    if (role == AppRole.user) {
      context.go('/customer');
    } else if (role == AppRole.restaurant) {
      context.go('/restaurant');
    } else {
      context.go('/delivery');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining_rounded, size: 88, color: scheme.primary),
            const SizedBox(height: 24),
            Text('Ciao Delivery', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 32),
            const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
