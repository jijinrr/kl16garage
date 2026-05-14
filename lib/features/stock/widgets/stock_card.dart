import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../models/stock_model.dart';

class StockCard extends StatelessWidget {
  const StockCard({
    super.key,
    required this.stock,
    required this.onTap,
    required this.onDelete,
  });

  final StockModel stock;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = stock.isOutOfStock
        ? AppColors.error
        : stock.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: statusColor.withValues(alpha: stock.isOutOfStock || stock.isLowStock ? 0.4 : 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(
                  alpha: stock.isOutOfStock || stock.isLowStock ? 0.08 : 0.0),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  _categoryIcon(stock.category),
                  color: statusColor,
                  size: AppSizes.iconSm,
                ),
              ),

              const SizedBox(width: AppSizes.md),

              // Name, brand, category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stock.brand} · ${stock.category}',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        Icon(Icons.currency_rupee,
                            size: 11, color: AppColors.textSecondary),
                        Text(
                          CurrencyHelpers.format(stock.sellingPrice),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppSizes.fontXs,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.sm),

              // Quantity + status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stock.quantity}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'units',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: AppSizes.fontXs,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  _StatusBadge(status: stock.stockStatus, color: statusColor),
                ],
              ),

              const SizedBox(width: AppSizes.sm),

              // Delete
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textHint,
                  size: AppSizes.iconSm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Towels':
        return Icons.cleaning_services_outlined;
      case 'Liquids':
        return Icons.water_drop_outlined;
      case 'Machines':
        return Icons.precision_manufacturing_outlined;
      case 'Accessories':
        return Icons.handyman_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
