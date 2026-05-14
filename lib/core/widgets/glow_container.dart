import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A container with a red neon glow effect.
/// Use for highlighted sections, action cards, or key metrics.
class GlowContainer extends StatelessWidget {
  const GlowContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.glowColor,
    this.glowRadius = 20.0,
    this.backgroundColor,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? glowColor;
  final double glowRadius;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final color = glowColor ?? AppColors.primary;
    final radius = borderRadius ?? AppSizes.radiusLg;

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: color.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: glowRadius,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: glowRadius * 2,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
