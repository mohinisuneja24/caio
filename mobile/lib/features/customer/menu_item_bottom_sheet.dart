import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:ciao_delivery/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showMenuItemBottomSheet({
  required BuildContext context,
  required MenuItem item,
  required bool restaurantOpen,
}) async {
  if (!restaurantOpen) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restaurant is closed right now')),
    );
    return;
  }
  if (!item.available) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This dish is unavailable')),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _MenuItemSheetContent(item: item),
  );
}

class _MenuItemSheetContent extends ConsumerStatefulWidget {
  const _MenuItemSheetContent({required this.item});

  final MenuItem item;

  @override
  ConsumerState<_MenuItemSheetContent> createState() => _MenuItemSheetContentState();
}

class _MenuItemSheetContentState extends ConsumerState<_MenuItemSheetContent> {
  int _qty = 1;

  Future<void> _addToCart() async {
    final item = widget.item;
    try {
      ref.read(cartProvider.notifier).addItem(item, quantity: _qty);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_qty > 1 ? 'Added ${_qty}× ${item.name}' : 'Added ${item.name}'),
        ),
      );
    } catch (e) {
      if (e is! CartRestaurantConflictException || !mounted) return;
      final go = await showDialog<bool>(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: const Text('Different restaurant'),
          content: const Text(
            'Your cart has items from another restaurant. Clear the cart and add these?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Clear & add')),
          ],
        ),
      );
      if (go == true && mounted) {
        ref.read(cartProvider.notifier).clear();
        ref.read(cartProvider.notifier).addItem(item, quantity: _qty);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_qty > 1 ? 'Added ${_qty}× ${item.name}' : 'Added ${item.name}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(
                  item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${item.price.toStringAsFixed(0)} each',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.description != null && item.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              item.description!.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 22),
          Text('Quantity', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '$_qty',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _qty < 99 ? () => setState(() => _qty++) : null,
                icon: const Icon(Icons.add_rounded),
              ),
              const Spacer(),
              Text(
                '₹${(item.price * _qty).toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Add to cart'),
          ),
        ],
      ),
    );
  }
}
