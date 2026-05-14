import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/common_dashboard_appbar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../providers/stock_provider.dart';
import '../../../routes/app_router.dart';
import '../widgets/stock_card.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockProvider>();
    const filters = ['All', 'Towels', 'Liquids', 'Accessories', 'Machines', 'Low Stock'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonDashboardAppBar(
        title: 'Stock Management',
        showBack: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => context.read<StockProvider>().fetchAll(),
        child: stock.isLoading && stock.items.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
                child: ShimmerList(count: 6),
              )
            : CustomScrollView(
                slivers: [
                  // ── Header stats ────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePaddingH,
                      AppSizes.md,
                      AppSizes.pagePaddingH,
                      AppSizes.sm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: GlassmorphismCard(
                        redBorder: true,
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Row(
                          children: [
                            _MiniStat(
                              label: 'Total',
                              value: '${stock.totalItems}',
                              color: AppColors.primary,
                            ),
                            _Divider(),
                            _MiniStat(
                              label: 'Low Stock',
                              value: '${stock.lowStockCount}',
                              color: AppColors.warning,
                            ),
                            _Divider(),
                            _MiniStat(
                              label: 'Out',
                              value: '${stock.outOfStockCount}',
                              color: AppColors.error,
                            ),
                            _Divider(),
                            _MiniStat(
                              label: 'Recent',
                              value: '${stock.recentlyAdded}',
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Low stock alerts ─────────────────────────────────────
                  if (stock.lowStockItems.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePaddingH,
                        0,
                        AppSizes.pagePaddingH,
                        AppSizes.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                            border: Border.all(
                                color: AppColors.warning.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.warning,
                                  size: AppSizes.iconSm),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(
                                  '${stock.lowStockItems.length} item(s) need restocking: '
                                  '${stock.lowStockItems.take(2).map((i) => i.name).join(', ')}'
                                  '${stock.lowStockItems.length > 2 ? '...' : ''}',
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: AppSizes.fontSm,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── Search bar ──────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePaddingH,
                      vertical: AppSizes.xs,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: TextField(
                        onChanged: stock.setSearch,
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.textHint),
                          suffixIcon: stock.search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.textHint),
                                  onPressed: () => stock.setSearch(''),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // ── Filter chips ────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH,
                        vertical: AppSizes.sm),
                    sliver: SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filters.map((f) {
                            final selected = stock.categoryFilter == f;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSizes.sm),
                              child: FilterChip(
                                label: Text(f),
                                selected: selected,
                                onSelected: (_) =>
                                    stock.setCategoryFilter(f),
                                selectedColor: AppColors.primary
                                    .withValues(alpha: 0.2),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: AppSizes.fontSm,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // ── Stock count header ──────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH,
                        vertical: AppSizes.xs),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '${stock.items.length} product${stock.items.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                    ),
                  ),

                  // ── Items list ──────────────────────────────────────────
                  stock.items.isEmpty
                      ? SliverFillRemaining(
                          child: EmptyStateWidget(
                            title: 'No Products Found',
                            subtitle: stock.search.isNotEmpty
                                ? 'Try a different search term'
                                : 'Add your first stock item',
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
                              (_, i) {
                                final item = stock.items[i];
                                return StockCard(
                                  stock: item,
                                  onTap: () => context.push(
                                    Routes.staffAddStock,
                                    extra: item,
                                  ),
                                  onDelete: () => _confirmDelete(
                                      context, stock, item.id, item.name),
                                );
                              },
                              childCount: stock.items.length,
                            ),
                          ),
                        ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.staffAddStock),
        icon: const Icon(Icons.add),
        label: const Text('Add Stock'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, StockProvider stock, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Item',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Remove "$name" from stock?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              stock.deleteStock(id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
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
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}
