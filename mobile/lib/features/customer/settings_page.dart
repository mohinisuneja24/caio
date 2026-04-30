import 'package:ciao_delivery/core/config/app_config.dart';
import 'package:ciao_delivery/core/network/dio_client.dart';
import 'package:ciao_delivery/core/network/dio_client.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: AppConfig.instance.baseUrl);
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await AppConfig.instance.setBaseUrl(prefs, _url.text.trim());
    ref.invalidate(restaurantsListProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base URL saved. Pull to refresh on Explore.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('API', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Android emulator: http://10.0.2.2:8081\nPhysical device: http://YOUR_PC_LAN_IP:8081',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _url,
          decoration: const InputDecoration(
            labelText: 'Base URL (no trailing slash)',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _saveUrl, child: const Text('Save base URL')),
        const SizedBox(height: 32),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          onTap: () async {
            await ref.read(sessionProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
        ),
      ],
    );
  }
}
