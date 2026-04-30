import 'package:ciao_delivery/data/api_json.dart';
import 'package:ciao_delivery/data/models/app_role.dart';
import 'package:ciao_delivery/data/models/auth_models.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthPayload> login({required String phone, required String password}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    return AuthPayload.fromJson(parseObject(res));
  }

  Future<AuthPayload> register({
    required String name,
    required String phone,
    required String password,
    required AppRole role,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': name,
        'phone': phone,
        'password': password,
        'role': role.apiValue,
      },
    );
    return AuthPayload.fromJson(parseObject(res));
  }
}
