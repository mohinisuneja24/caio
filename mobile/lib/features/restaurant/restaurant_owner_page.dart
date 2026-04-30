import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/data/models/order_models.dart';
import 'package:ciao_delivery/data/models/restaurant_models.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/providers/repositories_provider.dart';
import 'package:ciao_delivery/providers/session_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantOwnerPage extends ConsumerStatefulWidget {
  const RestaurantOwnerPage({super.key});

  @override
  ConsumerState<RestaurantOwnerPage> createState() => _RestaurantOwnerPageState();
}

class _RestaurantOwnerPageState extends ConsumerState<RestaurantOwnerPage> {
  int? _selectedId;

  Future<void> _createRestaurant() async {
    final name = TextEditingController(text: 'My Kitchen');
    final loc = TextEditingController(text: 'Main Street');
    final open = TextEditingController(text: '09:00:00');
    final close = TextEditingController(text: '22:00:00');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New restaurant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: loc, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: open, decoration: const InputDecoration(labelText: 'Open (HH:mm:ss)')),
              TextField(controller: close, decoration: const InputDecoration(labelText: 'Close (HH:mm:ss)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(restaurantRepositoryProvider).create(
            RestaurantRequest(
              name: name.text.trim(),
              location: loc.text.trim(),
              openTime: open.text.trim(),
              closeTime: close.text.trim(),
            ),
          );
      ref.invalidate(myRestaurantsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restaurant created')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanMessage(e))));
      }
    }
  }

  Future<void> _addMenu(int restaurantId) async {
    final name = TextEditingController(text: 'Chef special');
    final price = TextEditingController(text: '199');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add menu item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final p = double.tryParse(price.text.trim()) ?? 0;
      await ref.read(menuRepositoryProvider).addItem(
            restaurantId: restaurantId,
            name: name.text.trim(),
            price: p,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myRestaurantsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(myRestaurantsProvider);
              if (_selectedId != null) ref.invalidate(restaurantOrdersProvider(_selectedId!));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRestaurant,
        icon: const Icon(Icons.add),
        label: const Text('New venue'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text(humanMessage(e))),
        data: (venues) {
          if (venues.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No venues yet.\nTap “New venue” to create one.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          _selectedId ??= venues.first.id;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Your venues', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...venues.map(
                (v) => RadioListTile<int>(
                  title: Text(v.name),
                  subtitle: Text(v.location),
                  value: v.id,
                  groupValue: _selectedId,
                  onChanged: (id) => setState(() => _selectedId = id),
                  secondary: IconButton(
                    icon: const Icon(Icons.restaurant_menu),
                    onPressed: () => _addMenu(v.id),
                  ),
                ),
              ),
              const Divider(height: 32),
              if (_selectedId != null) _OrdersSection(restaurantId: _selectedId!),
            ],
          );
        },
      ),
    );
  }
}

class _OrdersSection extends ConsumerWidget {
  const _OrdersSection({required this.restaurantId});

  final int restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(restaurantOrdersProvider(restaurantId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (e, _) => Text(humanMessage(e)),
      data: (orders) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Orders', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.invalidate(restaurantOrdersProvider(restaurantId)),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            if (orders.isEmpty) const Text('No orders for this venue.'),
            ...orders.map((o) => Card(
                  child: ExpansionTile(
                    title: Text('#${o.id} · ${o.status?.api ?? '-'}'),
                    subtitle: Text('₹${o.totalAmount.toStringAsFixed(2)}'),
                    children: [
                      ListTile(
                        dense: true,
                        title: const Text('Accept'),
                        onTap: o.status == OrderStatus.placed
                            ? () async {
                                try {
                                  await ref.read(orderRepositoryProvider).accept(o.id);
                                  ref.invalidate(restaurantOrdersProvider(restaurantId));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(humanMessage(e))),
                                  );
                                }
                              }
                            : null,
                      ),
                      ListTile(
                        dense: true,
                        title: const Text('Mark out for delivery'),
                        onTap: o.status == OrderStatus.accepted
                            ? () async {
                                try {
                                  await ref.read(orderRepositoryProvider).updateStatus(
                                        o.id,
                                        OrderStatus.outForDelivery,
                                      );
                                  ref.invalidate(restaurantOrdersProvider(restaurantId));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(humanMessage(e))),
                                  );
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}
