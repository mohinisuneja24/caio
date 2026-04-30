import 'package:ciao_delivery/data/api_json.dart';
import 'package:ciao_delivery/data/models/order_models.dart';
import 'package:dio/dio.dart';

class OrderRepository {
  OrderRepository(this._dio);

  final Dio _dio;

  Future<OrderSummary> placeOrder({
    required int restaurantId,
    required List<int> menuItemIds,
    String? deliveryAddress,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/orders',
      data: {
        'restaurantId': restaurantId,
        'menuItemIds': menuItemIds,
        if (deliveryAddress != null && deliveryAddress.isNotEmpty) 'deliveryAddress': deliveryAddress,
      },
    );
    return OrderSummary.fromJson(parseObject(res));
  }

  Future<List<OrderSummary>> myOrders() async {
    final res = await _dio.get<Map<String, dynamic>>('/orders/my');
    return parseList(res).map((e) => OrderSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderSummary> getById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/orders/$id');
    return OrderSummary.fromJson(parseObject(res));
  }

  Future<List<OrderSummary>> forRestaurant(int restaurantId) async {
    final res = await _dio.get<Map<String, dynamic>>('/orders/restaurant/$restaurantId');
    return parseList(res).map((e) => OrderSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderSummary> accept(int orderId) async {
    final res = await _dio.patch<Map<String, dynamic>>('/orders/$orderId/accept');
    return OrderSummary.fromJson(parseObject(res));
  }

  Future<OrderSummary> updateStatus(int orderId, OrderStatus status) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/orders/$orderId/status',
      queryParameters: {'status': status.api},
    );
    return OrderSummary.fromJson(parseObject(res));
  }

  Future<OrderSummary> cancel(int orderId) async {
    final res = await _dio.patch<Map<String, dynamic>>('/orders/$orderId/cancel');
    return OrderSummary.fromJson(parseObject(res));
  }
}
