import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../routes/app_router.dart';
import '../widgets/service_card.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().startListening();
      context.read<AnalyticsProvider>().fetchSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ServiceProvider>();
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Selector<UserProvider, String>(
              selector: (_, u) => u.name,
              builder: (_, name, _) => Text(
                '${DateHelpers.greeting()}, ${name.split(' ').first.isEmpty ? 'Staff' : name.split(' ').first}',
                style: const TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              DateHelpers.formatDate(DateTime.now()),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async => context.read<ServiceProvider>().startListening(),
        child: CustomScrollView(
          slivers: [
            // ── Stats row ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.lg,
                AppSizes.pagePaddingH,
                AppSizes.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: service.isLoading && service.allTodayServices.isEmpty
                    ? const _StatsShimmer()
                    : _StatsGrid(service: service),
              ),
            ),

            // ── Vehicle closing card ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                0,
                AppSizes.pagePaddingH,
                AppSizes.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: _ClosingCard(analytics: analytics),
              ),
            ),

            // ── Search + filter ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _SearchBar(service: service),
                    const SizedBox(height: AppSizes.sm),
                    _FilterChips(service: service),
                  ],
                ),
              ),
            ),

            // ── Section header ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Text(
                      "Today's Services",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${service.todayServices.length} jobs',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Service list ──────────────────────────────────────────────
            service.isLoading && service.allTodayServices.isEmpty
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH),
                    sliver: SliverToBoxAdapter(
                      child: ShimmerList(count: 4),
                    ),
                  )
                : service.todayServices.isEmpty
                    ? SliverFillRemaining(
                        child: EmptyStateWidget(
                          title: AppStrings.noServicesToday,
                          subtitle: AppStrings.noServicesTodaySubtitle,
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.pagePaddingH,
                          0,
                          AppSizes.pagePaddingH,
                          100,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => ServiceCard(
                              service: service.todayServices[i],
                              onComplete: () =>
                                  service.markCompleted(
                                      service.todayServices[i].id),
                              onDelete: () =>
                                  service.deleteService(
                                      service.todayServices[i].id),
                              onTap: () => context.push(
                                Routes.staffAddCustomer,
                                extra: service.todayServices[i],
                              ),
                            ),
                            childCount: service.todayServices.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.staffAddCustomer),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addCustomer),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.service});
  final ServiceProvider service;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.md,
      mainAxisSpacing: AppSizes.md,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          label: AppStrings.totalVehicles,
          value: service.totalVehicles,
          icon: Icons.directions_car_outlined,
        ),
        StatCard(
          label: AppStrings.completed,
          value: service.completedCount,
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
        ),
        StatCard(
          label: AppStrings.pending,
          value: service.pendingCount,
          icon: Icons.pending_outlined,
          iconColor: AppColors.warning,
        ),
        StatCard(
          label: AppStrings.todayRevenue,
          value: service.todayRevenue,
          icon: Icons.currency_rupee_outlined,
          isCurrency: true,
          iconColor: AppColors.primary,
          valueColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.md,
      mainAxisSpacing: AppSizes.md,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        StatCardShimmer(),
        StatCardShimmer(),
        StatCardShimmer(),
        StatCardShimmer(),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.service});
  final ServiceProvider service;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: service.setSearch,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: AppStrings.searchVehicle,
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
        suffixIcon: service.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textHint),
                onPressed: () => service.setSearch(''),
              )
            : null,
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.service});
  final ServiceProvider service;

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Pending', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = service.statusFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilterChip(
              label: Text(f),
              selected: selected,
              onSelected: (_) => service.setStatusFilter(f),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ClosingCard extends StatelessWidget {
  const _ClosingCard({required this.analytics});
  final AnalyticsProvider analytics;

  @override
  Widget build(BuildContext context) {
    final closed = analytics.closedVehicles;
    final total = analytics.totalVehicles;
    final rate = analytics.closingRate;
    final pct = rate.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.06),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct / 100,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  color: AppColors.success,
                ),
                Text(
                  '${pct.round()}%',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle Closing',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$closed of $total vehicles closed today',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$closed',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'closed',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: AppSizes.fontXs,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
