import 'package:ciao_delivery/core/network/dio_client.dart';
import 'package:ciao_delivery/data/models/app_role.dart';
import 'package:ciao_delivery/data/models/auth_models.dart';
import 'package:ciao_delivery/providers/repositories_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
  const SessionState({
    this.token,
    this.name,
    this.phone,
    this.role,
  });

  final String? token;
  final String? name;
  final String? phone;
  final AppRole? role;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  SessionState copyWith({
    String? token,
    String? name,
    String? phone,
    AppRole? role,
    bool clearToken = false,
  }) {
    return SessionState(
      token: clearToken ? null : (token ?? this.token),
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }

  static const guest = SessionState();
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._prefs, this._ref) : super(SessionState.guest) {
    _restore();
  }

  final SharedPreferences _prefs;
  final Ref _ref;

  Future<void> _restore() async {
    final t = readToken(_prefs);
    if (t == null || t.isEmpty) return;
    final role = AppRole.fromApi(_prefs.getString(_kRole));
    state = SessionState(
      token: t,
      name: _prefs.getString(_kName),
      phone: _prefs.getString(_kPhone),
      role: role,
    );
  }

  Future<void> login({required String phone, required String password}) async {
    final repo = _ref.read(authRepositoryProvider);
    final auth = await repo.login(phone: phone, password: password);
    await _persist(auth);
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required AppRole role,
  }) async {
    final repo = _ref.read(authRepositoryProvider);
    final auth = await repo.register(
      name: name,
      phone: phone,
      password: password,
      role: role,
    );
    await _persist(auth);
  }

  Future<void> _persist(AuthPayload auth) async {
    await persistToken(_prefs, auth.token);
    await _prefs.setString(_kRole, auth.role.apiValue);
    await _prefs.setString(_kName, auth.name);
    await _prefs.setString(_kPhone, auth.phone);
    state = SessionState(
      token: auth.token,
      name: auth.name,
      phone: auth.phone,
      role: auth.role,
    );
  }

  Future<void> logout() async {
    await persistToken(_prefs, null);
    await _prefs.remove(_kRole);
    await _prefs.remove(_kName);
    await _prefs.remove(_kPhone);
    state = SessionState.guest;
  }

  static const _kRole = 'session_role';
  static const _kName = 'session_name';
  static const _kPhone = 'session_phone';
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionNotifier(prefs, ref);
});
