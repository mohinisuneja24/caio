import 'package:ciao_delivery/core/network/api_exception.dart';
import 'package:dio/dio.dart';

void ensureSuccess(Map<String, dynamic> map) {
  if (map['success'] != true) {
    throw ApiException(map['message']?.toString() ?? 'Request failed');
  }
}

Map<String, dynamic> parseObject(Response<dynamic> response) {
  final raw = response.data;
  if (raw is! Map) throw ApiException('Invalid response');
  final map = Map<String, dynamic>.from(raw as Map);
  ensureSuccess(map);
  final data = map['data'];
  if (data is! Map) {
    throw ApiException(map['message']?.toString() ?? 'Invalid response');
  }
  return Map<String, dynamic>.from(data as Map);
}

List<dynamic> parseList(Response<dynamic> response) {
  final raw = response.data;
  if (raw is! Map) throw ApiException('Invalid response');
  final map = Map<String, dynamic>.from(raw as Map);
  ensureSuccess(map);
  final data = map['data'];
  if (data is! List<dynamic>) return [];
  return List<dynamic>.from(data);
}

void parseVoid(Response<dynamic> response) {
  final raw = response.data;
  if (raw is! Map) {
    throw ApiException('Invalid response');
  }
  ensureSuccess(Map<String, dynamic>.from(raw as Map));
}
