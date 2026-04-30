import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailPage extends ConsumerWidget {
  const RestaurantDetailPage({super.key, required this.restaurantId});

  final int restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantDetailProvider(restaurantId));
    final menuAsync = ref.watch(menuForRestaurantProvider(restaurantId));

    return Scaffold(
      appBar: AppBar(
        title: restaurantAsync.maybeWhen(
          data: (r) => Text(r.name),
          orElse: () => const Text('Restaurant'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customer/cart'),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: Text('Cart (${ref.watch(cartProvider).items.length})'),
      ),
      body: restaurantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text(humanMessage(e))),
        data: (restaurant) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              restaurant.open ? Icons.check_circle : Icons.cancel,
                              size: 20,
                              color: restaurant.open
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              restaurant.open
                                  ? 'Open now · ${restaurant.openTime} – ${restaurant.closeTime}'
                                  : 'Closed · hours ${restaurant.openTime} – ${restaurant.closeTime}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Menu', style: Theme.of(context).textTheme.titleMedium),
              ),
              Expanded(
                child: menuAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                  error: (e, _) => Center(child: Text(humanMessage(e))),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(child: Text('No menu items'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return _MenuTile(item: item, restaurantOpen: restaurant.open);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuTile extends ConsumerWidget {
  const _MenuTile({required this.item, required this.restaurantOpen});

  final MenuItem item;
  final bool restaurantOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: item.description == null || item.description!.isEmpty
            ? null
            : Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₹${item.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall),
            if (!item.available) Text('Off', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        onTap: (!restaurantOpen || !item.available)
            ? null
            : () async {
                try {
                  ref.read(cartProvider.notifier).addItem(item);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${item.name}')),
                    );
                  }
                } catch (e) {
                  if (e is CartRestaurantConflictException) {
                    final go = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Different restaurant'),
                        content: const Text(
                          'Your cart has items from another restaurant. Clear cart and add this item?',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear & add')),
                        ],
                      ),
                    );
                    if (go == true && context.mounted) {
                      ref.read(cartProvider.notifier).clear();
                      ref.read(cartProvider.notifier).addItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${item.name}')),
                      );
                    }
                  }
                }
              },
      ),
    );
  }
}
