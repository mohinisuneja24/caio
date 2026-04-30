import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:ciao_delivery/data/models/restaurant_models.dart';
import 'package:ciao_delivery/providers/repositories_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantsListProvider = FutureProvider.autoDispose<List<Restaurant>>((ref) {
  return ref.watch(restaurantRepositoryProvider).listPublic();
});

final restaurantDetailProvider =
    FutureProvider.autoDispose.family<Restaurant, int>((ref, id) {
  return ref.watch(restaurantRepositoryProvider).getById(id);
});

final menuForRestaurantProvider =
    FutureProvider.autoDispose.family<List<MenuItem>, int>((ref, id) {
  return ref.watch(menuRepositoryProvider).listForRestaurant(id);
});

final myOrdersProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(orderRepositoryProvider).myOrders();
});

final orderByIdProvider = FutureProvider.autoDispose.family((ref, int id) {
  return ref.watch(orderRepositoryProvider).getById(id);
});

final myRestaurantsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(restaurantRepositoryProvider).listMine();
});

final restaurantOrdersProvider =
    FutureProvider.autoDispose.family((ref, int restaurantId) {
  return ref.watch(orderRepositoryProvider).forRestaurant(restaurantId);
});

final deliveryProfileProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(deliveryRepositoryProvider).me();
});

/// Set to `0`–`2` (Explore / Orders / Settings) right before `context.go('/customer')`
/// so [CustomerHomePage] opens on that tab once.
final customerPendingTabProvider = StateProvider<int?>((ref) => null);
