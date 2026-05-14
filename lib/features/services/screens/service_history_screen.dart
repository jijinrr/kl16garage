import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/service_model.dart';
import '../../../repositories/service_repository.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final List<ServiceModel> _services = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _statusFilter = 'All';
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final repo = context.read<ServiceRepository>();
      final list = await repo.fetchHistory(
        limit: 20,
        statusFilter: _statusFilter,
      );
      setState(() {
        _services.addAll(list);
        _hasMore = list.length == 20;
      });
    } catch (_) {
      // handle silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _statusFilter = filter;
      _services.clear();
      _hasMore = true;
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service History'),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.surface,
            onSelected: _applyFilter,
            itemBuilder: (_) => ['All', 'Completed', 'Pending']
                .map((s) => PopupMenuItem(value: s, child: Text(s)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: AppSizes.iconSm),
                  const SizedBox(width: 4),
                  Text(_statusFilter,
                      style: const TextStyle(fontSize: AppSizes.fontSm)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _services.isEmpty && _isLoading
          ? const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
              child: ShimmerList(count: 6),
            )
          : _services.isEmpty && !_isLoading
              ? const EmptyStateWidget(title: 'No service history')
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePaddingH,
                    vertical: AppSizes.md,
                  ),
                  itemCount: _services.length + (_hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _services.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.lg),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      );
                    }
                    final s = _services[i];
                    return GlassmorphismCard(
                      margin:
                          const EdgeInsets.only(bottom: AppSizes.md),
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        s.vehicleNumber,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    Flexible(
                                      child: Text(
                                        s.vehicleType,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: AppSizes.fontXs,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.customerName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: AppSizes.fontSm,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.createdAt != null
                                      ? DateHelpers.formatDateTime(
                                          s.createdAt!)
                                      : '--',
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
                                CurrencyHelpers.format(s.totalAmount),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSizes.xs),
                              StatusChip(
                                status: statusTypeFromString(
                                    s.paymentStatus),
                                fontSize: AppSizes.fontXs,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
