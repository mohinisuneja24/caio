import 'package:ciao_delivery/data/models/app_role.dart';

class AuthPayload {
  const AuthPayload({
    required this.token,
    required this.name,
    required this.phone,
    required this.role,
  });

  final String token;
  final String name;
  final String phone;
  final AppRole role;

  factory AuthPayload.fromJson(Map<String, dynamic> j) {
    final role = AppRole.fromApi(j['role'] as String?) ?? AppRole.user;
    return AuthPayload(
      token: j['token'] as String,
      name: j['name'] as String,
      phone: j['phone'] as String,
      role: role,
    );
  }
}
