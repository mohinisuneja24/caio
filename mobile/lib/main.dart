import 'package:ciao_delivery/app.dart';
import 'package:ciao_delivery/core/config/app_config.dart';
import 'package:ciao_delivery/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await AppConfig.instance.loadFromPrefs(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CiaoApp(),
    ),
  );
}
