import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/data/models/order_models.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/providers/repositories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderByIdProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text('Order #$orderId')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(humanMessage(e)),
        )),
        data: (order) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(orderByIdProvider(orderId)),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Status: ${order.status?.api ?? '-'}'),
                      Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                      if (order.deliveryPartnerName != null)
                        Text('Rider: ${order.deliveryPartnerName}'),
                      if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty)
                        Text('Address: ${order.deliveryAddress}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Items', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...order.itemNames.map(
                (n) => Card(
                  child: ListTile(title: Text(n)),
                ),
              ),
              const SizedBox(height: 24),
              if (order.status == OrderStatus.placed || order.status == OrderStatus.accepted)
                FilledButton.tonal(
                  onPressed: () async {
                    try {
                      await ref.read(orderRepositoryProvider).cancel(orderId);
                      ref.invalidate(orderByIdProvider(orderId));
                      ref.invalidate(myOrdersProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order cancelled')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(humanMessage(e))),
                        );
                      }
                    }
                  },
                  child: const Text('Cancel order'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
