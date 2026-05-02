import 'package:ciao_delivery/core/utils/error_message.dart';
import 'package:ciao_delivery/data/models/restaurant_models.dart';
import 'package:ciao_delivery/features/customer/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _OpenFilter { all, openOnly, closedOnly }

enum _SortMode { smart, nameAsc, nameDesc }

/// Discovery: search, filters, sort, and restaurant list/grid (Step 1 customer roadmap).
class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab> {
  final _search = TextEditingController();
  _OpenFilter _openFilter = _OpenFilter.all;
  _SortMode _sortMode = _SortMode.smart;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Restaurant> _applyFilters(List<Restaurant> all) {
    final q = _search.text.trim().toLowerCase();
    Iterable<Restaurant> x = all;
    if (q.isNotEmpty) {
      x = x.where(
        (r) =>
            r.name.toLowerCase().contains(q) ||
            r.location.toLowerCase().contains(q),
      );
    }
    switch (_openFilter) {
      case _OpenFilter.openOnly:
        x = x.where((r) => r.open);
      case _OpenFilter.closedOnly:
        x = x.where((r) => !r.open);
      case _OpenFilter.all:
        break;
    }
    final list = x.toList();
    switch (_sortMode) {
      case _SortMode.smart:
        list.sort((a, b) {
          if (a.open != b.open) return a.open ? -1 : 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case _SortMode.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _SortMode.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    }
    return list;
  }

  String get _sortLabel => switch (_sortMode) {
        _SortMode.smart => 'Recommended',
        _SortMode.nameAsc => 'Name A–Z',
        _SortMode.nameDesc => 'Name Z–A',
      };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(restaurantsListProvider);
    final scheme = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: scheme.outline),
              const SizedBox(height: 16),
              Text(humanMessage(e), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(restaurantsListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (all) {
        final filtered = _applyFilters(all);
        final wide = MediaQuery.sizeOf(context).width >= 720;

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(restaurantsListProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search restaurants or area…',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear',
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _search.clear();
                                    setState(() {});
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _openFilter == _OpenFilter.all,
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _openFilter = _OpenFilter.all),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Open now'),
                              selected: _openFilter == _OpenFilter.openOnly,
                              avatar: Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: scheme.primary,
                              ),
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _openFilter = _OpenFilter.openOnly),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Closed'),
                              selected: _openFilter == _OpenFilter.closedOnly,
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _openFilter = _OpenFilter.closedOnly),
                            ),
                            const SizedBox(width: 16),
                            PopupMenuButton<_SortMode>(
                              tooltip: 'Sort',
                              onSelected: (m) => setState(() => _sortMode = m),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: _SortMode.smart,
                                  checked: _sortMode == _SortMode.smart,
                                  child: const Text('Recommended (open first)'),
                                ),
                                PopupMenuItem(
                                  value: _SortMode.nameAsc,
                                  checked: _sortMode == _SortMode.nameAsc,
                                  child: const Text('Name A–Z'),
                                ),
                                PopupMenuItem(
                                  value: _SortMode.nameDesc,
                                  checked: _sortMode == _SortMode.nameDesc,
                                  child: const Text('Name Z–A'),
                                ),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sort_rounded, color: scheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      _sortLabel,
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Icon(Icons.arrow_drop_down_rounded, color: scheme.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        all.isEmpty
                            ? 'No restaurants on the platform yet'
                            : '${filtered.length} of ${all.length} ${all.length == 1 ? 'place' : 'places'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (all.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_mall_directory_outlined, size: 64, color: scheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'Nothing to show yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back when restaurants go live.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: scheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'No matches',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search or filter.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            _search.clear();
                            setState(() {
                              _openFilter = _OpenFilter.all;
                              _sortMode = _SortMode.smart;
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (wide)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _RestaurantCard(
                        restaurant: filtered[i],
                        compact: true,
                      ),
                      childCount: filtered.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 380,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RestaurantCard(
                          restaurant: filtered[i],
                          compact: false,
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.compact,
  });

  final Restaurant restaurant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final scheme = Theme.of(context).colorScheme;
    final initial = r.name.isNotEmpty ? r.name[0].toUpperCase() : '?';

    final openChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: r.open ? scheme.tertiaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        r.open ? 'Open' : 'Closed',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: r.open ? scheme.onTertiaryContainer : scheme.onErrorContainer,
            ),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/customer/restaurant/${r.id}'),
        child: compact
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                          child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        openChip,
                      ],
                    ),
                    const Spacer(),
                    Text(
                      r.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: scheme.outline),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${r.openTime} – ${r.closeTime}',
                            style: Theme.of(context).textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: Text(
                        initial,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 15, color: scheme.outline),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${r.openTime} – ${r.closeTime}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        openChip,
                        const SizedBox(height: 8),
                        Icon(Icons.chevron_right_rounded, color: scheme.outline),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
