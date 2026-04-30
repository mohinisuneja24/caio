import 'package:ciao_delivery/data/api_json.dart';
import 'package:ciao_delivery/data/models/menu_models.dart';
import 'package:dio/dio.dart';

class MenuRepository {
  MenuRepository(this._dio);

  final Dio _dio;

  Future<List<MenuItem>> listForRestaurant(int restaurantId) async {
    final res = await _dio.get<Map<String, dynamic>>('/restaurants/$restaurantId/menu');
    return parseList(res).map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MenuItem> addItem({
    required int restaurantId,
    required String name,
    String? description,
    required double price,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/restaurants/$restaurantId/menu',
      data: {
        'name': name,
        'description': description,
        'price': price,
      },
    );
    return MenuItem.fromJson(parseObject(res));
  }

  Future<MenuItem> updateItem({
    required int restaurantId,
    required int itemId,
    required String name,
    String? description,
    required double price,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/restaurants/$restaurantId/menu/$itemId',
      data: {
        'name': name,
        'description': description,
        'price': price,
      },
    );
    return MenuItem.fromJson(parseObject(res));
  }

  Future<void> toggleAvailability({required int restaurantId, required int itemId}) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/restaurants/$restaurantId/menu/$itemId/toggle',
    );
    parseVoid(res);
  }
}
