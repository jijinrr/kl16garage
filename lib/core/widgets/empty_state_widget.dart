import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_icons.dart';

/// Lottie animation + message displayed when a list is empty.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.animationAsset,
    this.actionLabel,
    this.onAction,
    this.lottieSize = 200,
  });

  final String title;
  final String? subtitle;
  final String? animationAsset;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double lottieSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie or fallback icon
            _buildAnimation(),
            const SizedBox(height: AppSizes.xxl),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: AppSizes.fontMd,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.xxl),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    final asset = animationAsset ?? AppIcons.emptyStateAnim;
    // Lottie may not exist during development — fallback to icon
    try {
      return Lottie.asset(
        asset,
        width: lottieSize,
        height: lottieSize,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _fallbackIcon(),
      );
    } catch (_) {
      return _fallbackIcon();
    }
  }

  Widget _fallbackIcon() {
    return Icon(
      Icons.inbox_outlined,
      size: 80,
      color: AppColors.textHint.withValues(alpha: 0.5),
    );
  }
}
