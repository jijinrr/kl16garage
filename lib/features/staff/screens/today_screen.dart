import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/widgets/common_dashboard_appbar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../routes/app_router.dart';
import '../widgets/service_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
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
    super.build(context);
    final service = context.watch<ServiceProvider>();
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonDashboardAppBar(title: 'Today'),
      body: Column(
        children: [
          // ── 5-stat summary card ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.md,
              AppSizes.pagePaddingH,
              AppSizes.sm,
            ),
            child: GlassmorphismCard(
              redBorder: true,
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.md, horizontal: AppSizes.sm),
              child: Row(
                children: [
                  _MiniStat(
                    label: 'Revenue',
                    value: CurrencyHelpers.compact(service.todayRevenue),
                    color: AppColors.primary,
                  ),
                  _Divider(),
                  _MiniStat(
                    label: 'Done',
                    value: '${service.completedCount}',
                    color: AppColors.success,
                  ),
                  _Divider(),
                  _MiniStat(
                    label: 'Pending',
                    value: '${service.pendingCount}',
                    color: AppColors.warning,
                  ),
                  _Divider(),
                  _MiniStat(
                    label: 'Total',
                    value: '${service.totalVehicles}',
                    color: AppColors.textPrimary,
                  ),
                  _Divider(),
                  _MiniStat(
                    label: 'Closed',
                    value: '${analytics.closedVehicles}',
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ),

          // ── Service list ──────────────────────────────────────────────
          Expanded(
            child: service.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH),
                    child: ShimmerList(count: 5),
                  )
                : service.todayServices.isEmpty
                    ? const EmptyStateWidget(
                        title: AppStrings.noServicesToday,
                        subtitle: AppStrings.noServicesTodaySubtitle,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.pagePaddingH,
                          AppSizes.sm,
                          AppSizes.pagePaddingH,
                          100,
                        ),
                        itemCount: service.todayServices.length,
                        itemBuilder: (_, i) {
                          final s = service.todayServices[i];
                          return RepaintBoundary(
                            child: ServiceCard(
                              service: s,
                              onComplete: () => service.markCompleted(s.id),
                              onDelete: () => service.deleteService(s.id),
                              onTap: () => context.push(
                                Routes.staffAddCustomer,
                                extra: s,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.staffAddCustomer),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: AppSizes.fontXs,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.border);
  }
}
