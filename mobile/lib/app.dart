import 'package:ciao_delivery/core/theme/app_theme.dart';
import 'package:ciao_delivery/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CiaoApp extends ConsumerWidget {
  const CiaoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ciao Delivery',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
