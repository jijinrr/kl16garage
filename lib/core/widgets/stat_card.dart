import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/currency_helpers.dart';
import 'glassmorphism_card.dart';

/// Dashboard stat card: icon, value, and label.
/// Supports currency formatting or plain string values.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isCurrency = false,
    this.iconColor,
    this.valueColor,
    this.onTap,
    this.subtitle,
  });

  final String label;
  final dynamic value; // double (currency) or String
  final IconData icon;
  final bool isCurrency;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    final displayValue = isCurrency
        ? CurrencyHelpers.compact(value as double)
        : value.toString();

    return GlassmorphismCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, color: color, size: AppSizes.iconSm),
              ),
              const Spacer(),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            displayValue,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: AppSizes.fontXxl,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
