import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../providers/expense_provider.dart';
import '../widgets/expense_modal.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().startListening();
    });
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExpenseModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.expenses),
      ),
      body: Column(
        children: [
          // ── Daily total card ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.lg,
              AppSizes.pagePaddingH,
              AppSizes.sm,
            ),
            child: GlassmorphismCard(
              redBorder: true,
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.todayExpenses,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                      Text(
                        CurrencyHelpers.format(expenses.todayTotal),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: AppSizes.fontXxl,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${expenses.expenses.length} items',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expense list ──────────────────────────────────────────────
          Expanded(
            child: expenses.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH),
                    child: ShimmerList(count: 4),
                  )
                : expenses.expenses.isEmpty
                    ? const EmptyStateWidget(
                        title: 'No Expenses',
                        subtitle: AppStrings.noExpenses,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.pagePaddingH,
                          AppSizes.sm,
                          AppSizes.pagePaddingH,
                          100,
                        ),
                        itemCount: expenses.expenses.length,
                        itemBuilder: (_, i) {
                          final e = expenses.expenses[i];
                          return Dismissible(
                            key: Key(e.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(
                                  bottom: AppSizes.md),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusLg),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(
                                  right: AppSizes.xl),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) =>
                                expenses.deleteExpense(e.id),
                            child: GlassmorphismCard(
                              margin: const EdgeInsets.only(
                                  bottom: AppSizes.md),
                              padding: const EdgeInsets.all(AppSizes.lg),
                              child: Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.all(AppSizes.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusSm),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_outlined,
                                      color: AppColors.primary,
                                      size: AppSizes.iconSm,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.title,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          e.category,
                                          style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: AppSizes.fontSm,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyHelpers.format(e.amount),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        e.createdAt != null
                                            ? DateHelpers.formatTime(
                                                e.createdAt!)
                                            : '--',
                                        style: const TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: AppSizes.fontXs,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddModal,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addExpense),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
