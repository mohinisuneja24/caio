import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/features/customer/explore_tab.dart';
import 'package:ciao_delivery/features/customer/my_orders_page.dart';
import 'package:ciao_delivery/features/customer/settings_page.dart';
import 'package:ciao_delivery/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(customerPendingTabProvider, (_, next) {
      if (next != null && mounted) {
        setState(() => _index = next.clamp(0, 2));
        ref.read(customerPendingTabProvider.notifier).state = null;
      }
    });

    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(['Discover', 'My orders', 'Settings'][_index]),
        actions: [
          if (_index == 0)
            IconButton(
              tooltip: 'Cart',
              onPressed: () => context.push('/customer/cart'),
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          ExploreTab(),
          MyOrdersTab(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
