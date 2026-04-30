import 'package:ciao_delivery/core/network/api_exception.dart';
import 'package:dio/dio.dart';

String humanMessage(Object error) {
  if (error is ApiException) return error.message;
  if (error is DioException) {
    if (error.error is ApiException) {
      return (error.error as ApiException).message;
    }
    return error.message ?? 'Network error';
  }
  return error.toString();
}
