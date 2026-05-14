import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../routes/app_router.dart';
import '../widgets/activity_feed.dart';
import '../widgets/quick_action_grid.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
    final analytics = context.watch<AnalyticsProvider>();
    context.watch<StaffProvider>(); // triggers rebuild when staff data updates

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium app bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePaddingH,
                  AppSizes.huge,
                  AppSizes.pagePaddingH,
                  AppSizes.lg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Selector<UserProvider, String>(
                      selector: (_, u) => u.name,
                      builder: (_, name, _) => Text(
                        '${DateHelpers.greeting()}, ${name.split(' ').first.isEmpty ? 'Admin' : name.split(' ').first} 👋',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontXl,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateHelpers.formatDate(DateTime.now()),
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.sm),
                child: Selector<UserProvider, String>(
                  selector: (_, u) => u.initial,
                  builder: (_, initial, _) => GestureDetector(
                    onTap: () => context.go(Routes.adminSettings),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Stats grid ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.sm,
              AppSizes.pagePaddingH,
              AppSizes.sm,
            ),
            sliver: SliverToBoxAdapter(
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

          // ── Quick actions ─────────────────────────────────────────────
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
                        onTap: () =>
                            context.push(Routes.staffAddCustomer),
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
                        onTap: () =>
                            context.go(Routes.adminAttendance),
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
                        label: 'Manage Stock',
                        onTap: () => context.go(Routes.staffStocks),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Activity feed ─────────────────────────────────────────────
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
                  ActivityFeed(
                      services: analytics.recentActivity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
