import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glow_container.dart';

/// Payment section widget with auto-calculated balance and animated status.
/// Used inside AddCustomerScreen.
class PaymentSection extends StatefulWidget {
  const PaymentSection({
    super.key,
    required this.totalCtrl,
    required this.advanceCtrl,
    required this.onStatusChanged,
  });

  final TextEditingController totalCtrl;
  final TextEditingController advanceCtrl;
  final ValueChanged<String> onStatusChanged;

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  double _balance = 0;
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    widget.totalCtrl.addListener(_recalculate);
    widget.advanceCtrl.addListener(_recalculate);
  }

  @override
  void dispose() {
    widget.totalCtrl.removeListener(_recalculate);
    widget.advanceCtrl.removeListener(_recalculate);
    super.dispose();
  }

  void _recalculate() {
    final total = CurrencyHelpers.parse(widget.totalCtrl.text);
    final advance = CurrencyHelpers.parse(widget.advanceCtrl.text);
    final balance = CurrencyHelpers.balance(total, advance);
    final status = CurrencyHelpers.paymentStatus(total, advance);
    setState(() {
      _balance = balance;
      _status = status;
    });
    widget.onStatusChanged(status);
  }

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.primary,
                size: AppSizes.iconSm,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                AppStrings.paymentSection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const Spacer(),
              _StatusBadge(status: _status),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          AppTextField(
            controller: widget.totalCtrl,
            label: AppStrings.totalAmount,
            prefixIcon: Icons.currency_rupee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.fieldRequired;
              if (double.tryParse(v) == null) return AppStrings.invalidAmount;
              return null;
            },
          ),
          const SizedBox(height: AppSizes.md),

          AppTextField(
            controller: widget.advanceCtrl,
            label: AppStrings.advanceAmount,
            prefixIcon: Icons.money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final total = CurrencyHelpers.parse(widget.totalCtrl.text);
              return CurrencyHelpers.parse(v ?? '0') > total
                  ? AppStrings.advanceExceedsTotal
                  : null;
            },
          ),
          const SizedBox(height: AppSizes.md),

          // Balance (read-only)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.textHint,
                  size: AppSizes.iconSm,
                ),
                const SizedBox(width: AppSizes.sm),
                const Text(
                  AppStrings.balanceAmount,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyHelpers.format(_balance),
                  style: TextStyle(
                    color: _balance > 0
                        ? AppColors.warning
                        : AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontLg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Completed':
        color = AppColors.success;
      case 'Partial':
        color = AppColors.warning;
      default:
        color = AppColors.error;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
