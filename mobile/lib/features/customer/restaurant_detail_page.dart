import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:ciao_delivery/data/models/restaurant_models.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/features/customer/menu_item_bottom_sheet.dart';
import 'package:ciao_delivery/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailPage extends ConsumerStatefulWidget {
  const RestaurantDetailPage({super.key, required this.restaurantId});

  final int restaurantId;

  @override
  ConsumerState<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends ConsumerState<RestaurantDetailPage> {
  final _menuSearch = TextEditingController();

  @override
  void dispose() {
    _menuSearch.dispose();
    super.dispose();
  }

  List<MenuItem> _filterMenu(List<MenuItem> items) {
    final q = _menuSearch.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              (m.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(restaurantDetailProvider(widget.restaurantId));
    final menuAsync = ref.watch(menuForRestaurantProvider(widget.restaurantId));
    final cart = ref.watch(cartProvider);
    final rid = widget.restaurantId;
    final showStickyCart =
        cart.restaurantId == rid && cart.itemCount > 0;

    return Scaffold(
      body: restaurantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(humanMessage(e), textAlign: TextAlign.center),
          ),
        ),
        data: (restaurant) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar.large(
                    pinned: true,
                    title: Text(restaurant.name),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _RestaurantHeaderCard(restaurant: restaurant),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Menu', style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _menuSearch,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Search dishes…',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  menuAsync.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      child: Center(child: Text(humanMessage(e))),
                    ),
                    data: (items) {
                      final filtered = _filterMenu(items);
                      if (items.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text('No menu items yet')),
                        );
                      }
                      if (filtered.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 48, color: Theme.of(context).colorScheme.outline),
                                const SizedBox(height: 12),
                                const Text('No dishes match your search'),
                                TextButton(
                                  onPressed: () {
                                    _menuSearch.clear();
                                    setState(() {});
                                  },
                                  child: const Text('Clear search'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          showStickyCart ? 100 : 24,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final item = filtered[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _MenuListTile(
                                  item: item,
                                  restaurantOpen: restaurant.open,
                                  onTap: () => showMenuItemBottomSheet(
                                    context: context,
                                    item: item,
                                    restaurantOpen: restaurant.open,
                                  ),
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (showStickyCart)
                _StickyCartBar(
                  itemCount: cart.itemCount,
                  subtotal: cart.subtotal,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RestaurantHeaderCard extends StatelessWidget {
  const _RestaurantHeaderCard({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = restaurant;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.85),
              scheme.surfaceContainerHighest.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.location,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: r.open ? scheme.tertiaryContainer : scheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r.open ? 'Open now' : 'Closed',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: r.open ? scheme.onTertiaryContainer : scheme.onErrorContainer,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${r.openTime} – ${r.closeTime}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            if (!r.open) ...[
              const SizedBox(height: 10),
              Text(
                'You can browse the menu, but ordering opens during these hours.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuListTile extends StatelessWidget {
  const _MenuListTile({
    required this.item,
    required this.restaurantOpen,
    required this.onTap,
  });

  final MenuItem item;
  final bool restaurantOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canOrder = restaurantOpen && item.available;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
                child: Text(
                  item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (item.description != null && item.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    if (!item.available)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Currently unavailable',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.error,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: canOrder ? scheme.primary : scheme.outline,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyCartBar extends ConsumerWidget {
  const _StickyCartBar({
    required this.itemCount,
    required this.subtotal,
  });

  final int itemCount;
  final double subtotal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      elevation: 8,
      shadowColor: Colors.black38,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'} in cart',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Subtotal ₹${subtotal.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push('/customer/cart'),
                icon: const Icon(Icons.shopping_bag_rounded),
                label: const Text('View cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
