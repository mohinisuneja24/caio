import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:ciao_delivery/providers/repositories_provider.dart';
import 'package:ciao_delivery/providers/session_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryDashboardPage extends ConsumerStatefulWidget {
  const DeliveryDashboardPage({super.key});

  @override
  ConsumerState<DeliveryDashboardPage> createState() => _DeliveryDashboardPageState();
}

class _DeliveryDashboardPageState extends ConsumerState<DeliveryDashboardPage> {
  final _from = TextEditingController(text: '17:00:00');
  final _to = TextEditingController(text: '21:00:00');

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  Future<void> _registerOrUpdate({required bool isRegister}) async {
    try {
      final repo = ref.read(deliveryRepositoryProvider);
      if (isRegister) {
        await repo.registerProfile(
          availableFrom: _from.text.trim(),
          availableTo: _to.text.trim(),
        );
      } else {
        await repo.updateAvailability(
          availableFrom: _from.text.trim(),
          availableTo: _to.text.trim(),
        );
      }
      ref.invalidate(deliveryProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isRegister ? 'Profile created' : 'Hours updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanMessage(e))));
      }
    }
  }

  Future<void> _duty() async {
    try {
      await ref.read(deliveryRepositoryProvider).toggleDuty();
      ref.invalidate(deliveryProfileProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanMessage(e))));
      }
    }
  }

  Future<void> _loadAvailable() async {
    try {
      final list = await ref.read(deliveryRepositoryProvider).availablePartners();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Available now (${list.length})'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: list
                  .map((p) => ListTile(
                        title: Text(p.name),
                        subtitle: Text('${p.availableFrom} – ${p.availableTo} · on duty: ${p.onDuty}'),
                      ))
                  .toList(),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(deliveryProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Who is available',
            onPressed: _loadAvailable,
            icon: const Icon(Icons.groups_2_outlined),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(humanMessage(e), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('Register your student hours', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _from,
              decoration: const InputDecoration(labelText: 'Available from (HH:mm:ss)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _to,
              decoration: const InputDecoration(labelText: 'Available to (HH:mm:ss)'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _registerOrUpdate(isRegister: true),
              child: const Text('Register as partner'),
            ),
          ],
        ),
        data: (p) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(deliveryProfileProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Window: ${p.availableFrom} – ${p.availableTo}'),
                      Text('On duty: ${p.onDuty}'),
                      Text('Within window now: ${p.availableNow}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _from,
                decoration: const InputDecoration(labelText: 'Available from'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _to,
                decoration: const InputDecoration(labelText: 'Available to'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _registerOrUpdate(isRegister: false),
                child: const Text('Save hours'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _duty,
                child: Text(p.onDuty ? 'Go off duty' : 'Go on duty'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
