import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:ciao_delivery/data/models/order_models.dart';
import 'package:ciao_delivery/data/models/restaurant_models.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/providers/repositories_provider.dart';
import 'package:ciao_delivery/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price (₹)'),
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
      ref.invalidate(menuForRestaurantProvider(restaurantId));
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
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(myRestaurantsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your kitchen'),
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
              if (_selectedId != null) {
                ref.invalidate(restaurantOrdersProvider(_selectedId!));
                ref.invalidate(menuForRestaurantProvider(_selectedId!));
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRestaurant,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('New venue'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(humanMessage(e), textAlign: TextAlign.center),
          ),
        ),
        data: (venues) {
          if (venues.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, size: 72, color: scheme.outline),
                    const SizedBox(height: 20),
                    Text(
                      'No venues yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap “New venue” to create your restaurant, then add dishes to the menu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          _selectedId ??= venues.first.id;
          final selected = _selectedId!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Text('Select venue', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: venues
                      .map(
                        (v) => RadioListTile<int>(
                          title: Text(v.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            v.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: v.id,
                          groupValue: selected,
                          onChanged: (id) => setState(() => _selectedId = id),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              _MenuSection(
                restaurantId: selected,
                onAddItem: () => _addMenu(selected),
              ),
              const SizedBox(height: 20),
              _OrdersSection(restaurantId: selected),
            ],
          );
        },
      ),
    );
  }
}

class _MenuSection extends ConsumerWidget {
  const _MenuSection({
    required this.restaurantId,
    required this.onAddItem,
  });

  final int restaurantId;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(menuForRestaurantProvider(restaurantId));
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant_menu_rounded, color: scheme.primary, size: 22),
            const SizedBox(width: 8),
            Text('Menu', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton.filledTonal(
              tooltip: 'Refresh menu',
              onPressed: () => ref.invalidate(menuForRestaurantProvider(restaurantId)),
              icon: const Icon(Icons.refresh, size: 20),
            ),
            const SizedBox(width: 4),
            FilledButton.tonalIcon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add dish'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        async.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
          error: (e, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(humanMessage(e)),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 40, color: scheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'No dishes yet',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Guests won’t see anything until you add menu items.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: onAddItem,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add first dish'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.5)),
                    _MenuTile(item: items[i], restaurantId: restaurantId),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MenuTile extends ConsumerWidget {
  const _MenuTile({required this.item, required this.restaurantId});

  final MenuItem item;
  final int restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        item.description?.isNotEmpty == true
            ? item.description!
            : 'Use the chip to show or hide this dish for customers.',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹${item.price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(item.available ? 'On' : 'Off'),
            selected: item.available,
            onSelected: (_) async {
              try {
                await ref.read(menuRepositoryProvider).toggleAvailability(
                      restaurantId: restaurantId,
                      itemId: item.id,
                    );
                ref.invalidate(menuForRestaurantProvider(restaurantId));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(humanMessage(e))),
                  );
                }
              }
            },
          ),
        ],
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
    final scheme = Theme.of(context).colorScheme;
    return async.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(humanMessage(e)),
        ),
      ),
      data: (orders) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: scheme.primary, size: 22),
                const SizedBox(width: 8),
                Text('Orders', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ref.invalidate(restaurantOrdersProvider(restaurantId)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (orders.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No orders for this venue yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              )
            else
              ...orders.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Text(
                          '#${o.id}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      title: Text(o.status?.api ?? '-'),
                      subtitle: Text('₹${o.totalAmount.toStringAsFixed(2)}'),
                      children: [
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.check_circle_outline),
                          title: const Text('Accept order'),
                          onTap: o.status == OrderStatus.placed
                              ? () async {
                                  try {
                                    await ref.read(orderRepositoryProvider).accept(o.id);
                                    ref.invalidate(restaurantOrdersProvider(restaurantId));
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(humanMessage(e))),
                                      );
                                    }
                                  }
                                }
                              : null,
                        ),
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.delivery_dining_outlined),
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
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(humanMessage(e))),
                                      );
                                    }
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
