import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// API base URL (no trailing slash). Override with `--dart-define=API_BASE_URL=...`
///
/// When not overridden, defaults suit local dev: Android emulator uses the host
/// loopback alias [10.0.2.2](https://developer.android.com/studio/run/emulator-networking);
/// iOS Simulator uses loopback. Physical devices need your machine LAN IP (set in Settings).
class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  static String get _compileTimeDefault {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:8081';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8081';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8081';
      default:
        return 'http://127.0.0.1:8081';
    }
  }

  String _baseUrl = _compileTimeDefault;

  String get baseUrl => _baseUrl;

  Future<void> loadFromPrefs(SharedPreferences prefs) async {
    final saved = prefs.getString(_kKey);
    if (saved != null && saved.trim().isNotEmpty) {
      _baseUrl = _normalize(saved);
    }
  }

  Future<void> setBaseUrl(SharedPreferences prefs, String url) async {
    _baseUrl = _normalize(url);
    await prefs.setString(_kKey, _baseUrl);
  }

  static String _normalize(String url) {
    var u = url.trim();
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    return u;
  }

  static const _kKey = 'api_base_url';
}
