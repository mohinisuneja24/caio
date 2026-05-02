import 'package:ciao_delivery/core/config/app_config.dart';
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

  void _applyPreset(String url) {
    setState(() {
      _url.text = url;
    });
  }

  Future<void> _saveUrl() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await AppConfig.instance.setBaseUrl(prefs, _url.text.trim());
    ref.invalidate(restaurantsListProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base URL saved. Pull to refresh on Discover.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Point the app at your Ciao API. Change this if the backend runs on another machine or port.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.link_rounded, color: scheme.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'API base URL',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'No trailing slash. Examples below match the default Spring port 8081.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'http://10.0.2.2:8081',
                  ),
                ),
                const SizedBox(height: 14),
                Text('Quick presets', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.android, size: 18),
                      label: const Text('Android emulator'),
                      onPressed: () => _applyPreset('http://10.0.2.2:8081'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.phone_iphone, size: 18),
                      label: const Text('iOS simulator'),
                      onPressed: () => _applyPreset('http://127.0.0.1:8081'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.computer, size: 18),
                      label: const Text('This machine'),
                      onPressed: () => _applyPreset('http://127.0.0.1:8081'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'On a real phone, use your PC’s Wi‑Fi IP, e.g. http://192.168.1.10:8081',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _saveUrl,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save base URL'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                  child: const Icon(Icons.logout_rounded),
                ),
                title: const Text('Sign out'),
                subtitle: const Text('You will need to sign in again'),
                onTap: () async {
                  await ref.read(sessionProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
