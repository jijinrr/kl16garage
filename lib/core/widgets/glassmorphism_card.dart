import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Premium glassmorphism card using BackdropFilter.
/// The foundational card widget used across every screen.
class GlassmorphismCard extends StatelessWidget {
  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.redBorder = false,
    this.tint,
    this.blur = 12.0,
    this.margin,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool redBorder;
  final Color? tint;
  final double blur;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSizes.radiusLg;
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ??
                  const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: tint ?? AppColors.glassWhite,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: redBorder
                      ? AppColors.primary.withValues(alpha: 0.6)
                      : AppColors.glassBorder,
                  width: redBorder ? 1.5 : 0.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
