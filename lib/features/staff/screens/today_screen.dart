import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/utils/date_helpers.dart';
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

class _TodayScreenState extends State<TodayScreen> {
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
            const Text(AppStrings.todayServices),
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
      ),
      body: Column(
        children: [
          // ── Revenue summary card ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.md,
              AppSizes.pagePaddingH,
              AppSizes.sm,
            ),
            child: GlassmorphismCard(
              redBorder: true,
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  _MiniStat(
                    label: 'Revenue',
                    value: CurrencyHelpers.compact(service.todayRevenue),
                    color: AppColors.primary,
                  ),
                  _Divider(),
                  _MiniStat(
                    label: 'Completed',
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

          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.sm,
            ),
            child: TextField(
              onChanged: service.setSearch,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: AppStrings.searchVehicle,
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textHint),
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
                          0,
                          AppSizes.pagePaddingH,
                          100,
                        ),
                        itemCount: service.todayServices.length,
                        itemBuilder: (_, i) {
                          final s = service.todayServices[i];
                          return ServiceCard(
                            service: s,
                            onComplete: () =>
                                service.markCompleted(s.id),
                            onDelete: () =>
                                service.deleteService(s.id),
                            onTap: () => context.push(
                              Routes.staffAddCustomer,
                              extra: s,
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
              fontSize: AppSizes.fontLg,
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
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
    );
  }
}
