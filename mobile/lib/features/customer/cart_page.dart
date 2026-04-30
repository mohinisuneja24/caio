import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/core/widgets/responsive_body.dart';
import 'package:ciao_delivery/providers/cart_provider.dart';
import 'package:ciao_delivery/providers/repositories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _address = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final cart = ref.read(cartProvider);
    if (cart.restaurantId == null || cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      final order = await repo.placeOrder(
        restaurantId: cart.restaurantId!,
        menuItemIds: ref.read(cartProvider.notifier).menuItemIds,
        deliveryAddress: _address.text.trim().isEmpty ? null : _address.text.trim(),
      );
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      context.go('/customer/order/${order.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: SafeArea(
        child: ResponsiveBody(
          child: cart.items.isEmpty
              ? Center(
                  child: Text(
                    'Nothing here yet.\nBrowse restaurants and tap items to add.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView(
                  children: [
                    TextField(
                      controller: _address,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Delivery address (optional)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(cart.items.length, (i) {
                      final it = cart.items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            title: Text(it.name),
                            subtitle: Text('₹${it.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  ref.read(cartProvider.notifier).removeAt(i),
                            ),
                          ),
                        ),
                      );
                    }),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '₹${cart.subtotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _checkout,
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Place order'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
