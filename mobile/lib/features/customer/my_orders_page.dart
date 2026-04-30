import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/data/models/order_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Embedded in customer home tab.
class MyOrdersTab extends ConsumerWidget {
  const MyOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myOrdersProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (orders) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(myOrdersProvider),
        child: orders.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('No orders yet')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final o = orders[i];
                  return Card(
                    child: ListTile(
                      title: Text(o.restaurantName),
                      subtitle: Text(
                        '${o.status?.api ?? '-'} · ₹${o.totalAmount.toStringAsFixed(2)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/customer/order/${o.id}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
