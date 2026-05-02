import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartRestaurantConflictException implements Exception {
  const CartRestaurantConflictException();
}

class CartLine {
  const CartLine({required this.item, this.quantity = 1});

  final MenuItem item;
  final int quantity;

  double get lineTotal => item.price * quantity;

  CartLine copyWith({MenuItem? item, int? quantity}) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  const CartState({this.restaurantId, this.lines = const []});

  final int? restaurantId;
  final List<CartLine> lines;

  double get subtotal => lines.fold(0, (a, b) => a + b.lineTotal);

  /// Total units (for badges).
  int get itemCount => lines.fold(0, (a, l) => a + l.quantity);

  bool get isEmpty => lines.isEmpty;

  CartState copyWith({
    int? restaurantId,
    List<CartLine>? lines,
    bool clear = false,
  }) {
    if (clear) return const CartState();
    return CartState(
      restaurantId: restaurantId ?? this.restaurantId,
      lines: lines ?? this.lines,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Expands quantities into repeated IDs for the place-order API.
  List<int> get menuItemIds =>
      lines.expand((l) => List<int>.filled(l.quantity, l.item.id)).toList();

  void addItem(MenuItem item, {int quantity = 1}) {
    if (quantity < 1) return;
    if (state.restaurantId != null && state.restaurantId != item.restaurantId) {
      throw const CartRestaurantConflictException();
    }
    final idx = state.lines.indexWhere((l) => l.item.id == item.id);
    final next = [...state.lines];
    if (idx >= 0) {
      final line = next[idx];
      next[idx] = line.copyWith(quantity: line.quantity + quantity);
    } else {
      next.add(CartLine(item: item, quantity: quantity));
    }
    state = CartState(restaurantId: item.restaurantId, lines: next);
  }

  void setLineQuantity(int index, int quantity) {
    if (quantity < 1) {
      removeLine(index);
      return;
    }
    final next = [...state.lines];
    next[index] = next[index].copyWith(quantity: quantity);
    state = CartState(restaurantId: state.restaurantId, lines: next);
  }

  void removeLine(int index) {
    final next = [...state.lines]..removeAt(index);
    if (next.isEmpty) {
      state = const CartState();
    } else {
      state = CartState(restaurantId: state.restaurantId, lines: next);
    }
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
