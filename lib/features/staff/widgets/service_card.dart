import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/service_model.dart';

/// Swipeable service card used on Home and Today screens.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onComplete,
    this.onDelete,
    this.onTap,
  });

  final ServiceModel service;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(service.id),
      background: _swipeBg(
        color: AppColors.success,
        icon: Icons.check,
        alignment: Alignment.centerLeft,
        label: 'Complete',
      ),
      secondaryBackground: _swipeBg(
        color: AppColors.error,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete?.call();
          return false; // don't remove from UI (stream updates it)
        } else {
          return await _confirmDelete(context);
        }
      },
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphismCard(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Row(
                children: [
                  // Vehicle number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      service.vehicleNumber.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.fontMd,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StatusChip(
                    status: statusTypeFromString(service.paymentStatus),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              // ── Customer name ──────────────────────────────────────────
              Text(
                service.customerName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSizes.xs),

              // ── Services list ──────────────────────────────────────────
              Text(
                service.services.join(', '),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: AppSizes.fontSm,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.md),

              // ── Footer ─────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: AppSizes.iconXs,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.createdAt != null
                        ? DateHelpers.formatTime(service.createdAt!)
                        : '--',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: AppSizes.fontXs,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyHelpers.format(service.totalAmount),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: AppSizes.iconMd),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Delete service for ${service.customerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

