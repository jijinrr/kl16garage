import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/common_dashboard_appbar.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../routes/app_router.dart';
import '../widgets/activity_feed.dart';
import '../widgets/quick_action_grid.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchSummary();
      context.read<AnalyticsProvider>().fetchRecentActivity();
      context.read<ServiceProvider>().startListening();
      context.read<StaffProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonDashboardAppBar(
        onAvatarTap: () => context.go(Routes.adminSettings),
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Stats grid ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.lg,
              AppSizes.pagePaddingH,
              AppSizes.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.md,
                  mainAxisSpacing: AppSizes.md,
                  childAspectRatio: 1.55,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      label: AppStrings.totalRevenue,
                      value: analytics.totalRevenue,
                      icon: Icons.currency_rupee,
                      isCurrency: true,
                      iconColor: AppColors.primary,
                      valueColor: AppColors.primary,
                    ),
                    StatCard(
                      label: 'Total Vehicles',
                      value: analytics.totalVehicles,
                      icon: Icons.directions_car_outlined,
                    ),
                    StatCard(
                      label: 'Total Expenses',
                      value: analytics.totalExpenses,
                      icon: Icons.receipt_long_outlined,
                      isCurrency: true,
                      iconColor: AppColors.warning,
                    ),
                    StatCard(
                      label: AppStrings.profit,
                      value: analytics.profit,
                      icon: Icons.trending_up,
                      isCurrency: true,
                      iconColor: AppColors.success,
                      valueColor: AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Quick actions ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  QuickActionGrid(
                    actions: [
                      QuickAction(
                        icon: Icons.add_circle_outline,
                        label: 'Add Service',
                        onTap: () => context.push(Routes.staffAddCustomer),
                      ),
                      QuickAction(
                        icon: Icons.people_outline,
                        label: 'Manage Staff',
                        onTap: () => context.go(Routes.adminStaff),
                      ),
                      QuickAction(
                        icon: Icons.bar_chart_outlined,
                        label: 'Reports',
                        onTap: () => context.push(Routes.adminReports),
                      ),
                      QuickAction(
                        icon: Icons.calendar_today_outlined,
                        label: 'Attendance',
                        onTap: () => context.go(Routes.adminAttendance),
                      ),
                      QuickAction(
                        icon: Icons.history,
                        label: 'History',
                        onTap: () => context.push(Routes.adminHistory),
                      ),
                      QuickAction(
                        icon: Icons.receipt_long_outlined,
                        label: 'Expenses',
                        onTap: () {},
                      ),
                      QuickAction(
                        icon: Icons.inventory_2_outlined,
                        label: 'Stock',
                        onTap: () => context.push(Routes.staffStocks),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Activity feed ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.sm,
              AppSizes.pagePaddingH,
              100,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ActivityFeed(services: analytics.recentActivity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
