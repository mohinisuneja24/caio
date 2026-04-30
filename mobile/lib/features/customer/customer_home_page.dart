import 'package:ciao_delivery/data/models/restaurant_models.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
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

    final cartCount = ref.watch(cartProvider).items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(['Explore', 'My orders', 'Settings'][_index]),
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
          _ExploreTab(),
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
            label: 'Explore',
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

class _ExploreTab extends ConsumerWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(restaurantsListProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, _) => Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(e.toString(), textAlign: TextAlign.center),
      )),
      data: (list) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(restaurantsListProvider),
        child: list.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No restaurants yet')),
                ],
              )
            : LayoutBuilder(
                builder: (context, c) {
                  final cross = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      childAspectRatio: 1.05,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final r = list[i];
                      return _RestaurantCard(restaurant: r);
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final scheme = Theme.of(context).colorScheme;
    final open = r.open;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/customer/restaurant/${restaurant.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.storefront_rounded, color: scheme.primary, size: 28),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: open ? scheme.primaryContainer : scheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      open ? 'Open' : 'Closed',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                r.name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                r.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${r.openTime} – ${r.closeTime}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
