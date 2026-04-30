import 'package:ciao_delivery/core/network/dio_client.dart';
import 'package:ciao_delivery/data/repositories/auth_repository.dart';
import 'package:ciao_delivery/data/repositories/delivery_repository.dart';
import 'package:ciao_delivery/data/repositories/menu_repository.dart';
import 'package:ciao_delivery/data/repositories/order_repository.dart';
import 'package:ciao_delivery/data/repositories/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(plainDioProvider)),
);

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => RestaurantRepository(ref.watch(authDioProvider)),
);

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepository(ref.watch(authDioProvider)),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(authDioProvider)),
);

final deliveryRepositoryProvider = Provider<DeliveryRepository>(
  (ref) => DeliveryRepository(ref.watch(authDioProvider)),
);
