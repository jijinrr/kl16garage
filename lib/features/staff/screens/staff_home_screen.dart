import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/common_dashboard_appbar.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../routes/app_router.dart';
import '../widgets/service_card.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final service = context.watch<ServiceProvider>();
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonDashboardAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          context.read<ServiceProvider>().startListening();
          await context.read<AnalyticsProvider>().fetchSummary();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Stats grid ────────────────────────────────────────────────
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
                    : RepaintBoundary(child: _StatsGrid(service: service)),
              ),
            ),

            // ── Vehicle closing card ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.xs,
              ),
              sliver: SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: _ClosingCard(analytics: analytics),
                ),
              ),
            ),

            // ── Quick Access ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.lg,
                AppSizes.pagePaddingH,
                AppSizes.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    _QuickAccessGrid(context: context),
                  ],
                ),
              ),
            ),

            // ── Today's summary header ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.lg,
                AppSizes.pagePaddingH,
                AppSizes.xs,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Text(
                      "Today's Summary",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go(Routes.staffToday),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Recent services list ──────────────────────────────────────
            service.isLoading && service.allTodayServices.isEmpty
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH),
                    sliver: SliverToBoxAdapter(
                      child: ShimmerList(count: 3),
                    ),
                  )
                : service.allTodayServices.isEmpty
                    ? const SliverToBoxAdapter(
                        child: _EmptyTodaySummary(),
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
                            (_, i) {
                              final s = service.allTodayServices[i];
                              return RepaintBoundary(
                                child: ServiceCard(
                                  service: s,
                                  onComplete: () =>
                                      service.markCompleted(s.id),
                                  onDelete: () =>
                                      service.deleteService(s.id),
                                  onTap: () => context.push(
                                    Routes.staffAddCustomer,
                                    extra: s,
                                  ),
                                ),
                              );
                            },
                            childCount:
                                service.allTodayServices.length.clamp(0, 5),
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
        elevation: 4,
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

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

// ── Closing card ──────────────────────────────────────────────────────────────

class _ClosingCard extends StatelessWidget {
  const _ClosingCard({required this.analytics});
  final AnalyticsProvider analytics;

  @override
  Widget build(BuildContext context) {
    final closed = analytics.closedVehicles;
    final total = analytics.totalVehicles;
    final pct = analytics.closingRate.clamp(0.0, 100.0);

    return GlassmorphismCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.md),
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
                  strokeWidth: 5,
                  backgroundColor: AppColors.surfaceVariant,
                  color: AppColors.success,
                ),
                Text(
                  '${pct.round()}%',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 9,
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
                  fontSize: AppSizes.fontXxl,
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

// ── Quick Access Grid ─────────────────────────────────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final items = [
      _QAItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add Service',
        color: AppColors.primary,
        onTap: () => context.push(Routes.staffAddCustomer),
      ),
      _QAItem(
        icon: Icons.today_rounded,
        label: "Today's Work",
        color: AppColors.info,
        onTap: () => context.go(Routes.staffToday),
      ),
      _QAItem(
        icon: Icons.receipt_long_rounded,
        label: 'Expenses',
        color: AppColors.warning,
        onTap: () => context.go(Routes.staffExpenses),
      ),
      _QAItem(
        icon: Icons.inventory_2_rounded,
        label: 'Stock',
        color: AppColors.success,
        onTap: () => context.push(Routes.staffStocks),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: AppSizes.sm,
      mainAxisSpacing: AppSizes.sm,
      childAspectRatio: 0.82,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) => _QACard(item: item)).toList(),
    );
  }
}

class _QAItem {
  const _QAItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QACard extends StatelessWidget {
  const _QACard({required this.item});
  final _QAItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: item.color.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.06),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: AppSizes.iconSm + 4),
            ),
            const SizedBox(height: AppSizes.xs + 2),
            Text(
              item.label,
              style: TextStyle(
                color: item.color.withValues(alpha: 0.9),
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty today summary ───────────────────────────────────────────────────────

class _EmptyTodaySummary extends StatelessWidget {
  const _EmptyTodaySummary();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH, AppSizes.lg, AppSizes.pagePaddingH, 100),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              color: AppColors.textHint,
              size: AppSizes.iconLg,
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              'No services today',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            const Text(
              'Tap "Add Service" to get started',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
