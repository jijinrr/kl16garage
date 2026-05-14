import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_helpers.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/service_model.dart';

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key, required this.services});
  final List<ServiceModel> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.xxl),
          child: Text(
            'No recent activity',
            style: TextStyle(color: AppColors.textHint),
          ),
        ),
      );
    }
    return Column(
      children: services
          .map((s) => _ActivityTile(service: s))
          .toList(),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.service});
  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(
              Icons.directions_car,
              color: AppColors.primary,
              size: AppSizes.iconSm,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.vehicleNumber,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
                Text(
                  service.customerName,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyHelpers.format(service.totalAmount),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.fontMd,
                ),
              ),
              Text(
                service.createdAt != null
                    ? DateHelpers.relativeDate(service.createdAt!)
                    : '--',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: AppSizes.fontXs,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.sm),
          StatusChip(
            status: statusTypeFromString(service.paymentStatus),
            fontSize: AppSizes.fontXs,
          ),
        ],
      ),
    );
  }
}
