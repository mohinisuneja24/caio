import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartRestaurantConflictException implements Exception {
  const CartRestaurantConflictException();
}

class CartState {
  const CartState({this.restaurantId, this.items = const []});

  final int? restaurantId;
  final List<MenuItem> items;

  double get subtotal => items.fold(0, (a, b) => a + b.price);

  CartState copyWith({
    int? restaurantId,
    List<MenuItem>? items,
    bool clear = false,
  }) {
    if (clear) return const CartState();
    return CartState(
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(MenuItem item) {
    if (state.restaurantId != null && state.restaurantId != item.restaurantId) {
      throw const CartRestaurantConflictException();
    }
    final next = [...state.items, item];
    state = CartState(restaurantId: item.restaurantId, items: next);
  }

  void removeAt(int index) {
    final next = [...state.items]..removeAt(index);
    if (next.isEmpty) {
      state = const CartState();
    } else {
      state = CartState(restaurantId: state.restaurantId, items: next);
    }
  }

  void clear() {
    state = const CartState();
  }

  List<int> get menuItemIds => state.items.map((e) => e.id).toList();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
