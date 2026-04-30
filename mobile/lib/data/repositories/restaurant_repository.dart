import 'package:ciao_delivery/data/api_json.dart';
import 'package:ciao_delivery/data/models/restaurant_models.dart';
import 'package:dio/dio.dart';

class RestaurantRepository {
  RestaurantRepository(this._dio);

  final Dio _dio;

  Future<List<Restaurant>> listPublic() async {
    final res = await _dio.get<Map<String, dynamic>>('/restaurants');
    return parseList(res).map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Restaurant>> listMine() async {
    final res = await _dio.get<Map<String, dynamic>>('/restaurants/mine');
    return parseList(res).map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Restaurant> getById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/restaurants/$id');
    return Restaurant.fromJson(parseObject(res));
  }

  Future<Restaurant> create(RestaurantRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>('/restaurants', data: body.toJson());
    return Restaurant.fromJson(parseObject(res));
  }

  Future<Restaurant> update(int id, RestaurantRequest body) async {
    final res = await _dio.put<Map<String, dynamic>>('/restaurants/$id', data: body.toJson());
    return Restaurant.fromJson(parseObject(res));
  }

  Future<void> deactivate(int id) async {
    final res = await _dio.delete<Map<String, dynamic>>('/restaurants/$id');
    parseVoid(res);
  }
}
