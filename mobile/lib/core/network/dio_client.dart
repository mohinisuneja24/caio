import 'package:ciao_delivery/core/config/app_config.dart';
import 'package:ciao_delivery/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kJwtKey = 'jwt_token';

/// Login / register only (no `Authorization` header).
final plainDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${AppConfig.instance.baseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(_configBaseUrlInterceptor());
  dio.interceptors.add(_errorInterceptor());
  return dio;
});

/// All protected APIs — reads JWT from [SharedPreferences] each request (no Riverpod cycle).
final authDioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: '${AppConfig.instance.baseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(_configBaseUrlInterceptor());
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final t = prefs.getString(_kJwtKey);
        if (t != null && t.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $t';
        }
        return handler.next(options);
      },
    ),
  );
  dio.interceptors.add(_errorInterceptor());
  return dio;
});

InterceptorsWrapper _configBaseUrlInterceptor() {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      options.baseUrl = '${AppConfig.instance.baseUrl}/api/v1';
      return handler.next(options);
    },
  );
}

InterceptorsWrapper _errorInterceptor() {
  return InterceptorsWrapper(
    onError: (e, handler) {
      final msg = _messageFromDio(e);
      return handler.reject(
        DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: ApiException(msg, statusCode: e.response?.statusCode),
          message: msg,
        ),
      );
    },
  );
}

String _messageFromDio(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Connection timed out. Check base URL and server.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Cannot reach server. Check Wi‑Fi and API base URL in Settings.';
  }
  return e.message ?? 'Something went wrong';
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main()');
});

Future<void> persistToken(SharedPreferences prefs, String? token) async {
  if (token == null || token.isEmpty) {
    await prefs.remove(_kJwtKey);
  } else {
    await prefs.setString(_kJwtKey, token);
  }
}

String? readToken(SharedPreferences prefs) => prefs.getString(_kJwtKey);
