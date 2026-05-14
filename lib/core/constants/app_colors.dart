import 'package:flutter/material.dart';

/// KL16 Garage Pro — centralized color palette.
/// Every screen and widget must reference these; never hard-code hex values.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE50914); // Deep Red
  static const Color primaryDark = Color(0xFFB0060F);
  static const Color primaryLight = Color(0xFFFF3D3D);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D); // Dark Matte Black
  static const Color surface = Color(0xFF1A1A1A); // Slightly elevated
  static const Color surfaceVariant = Color(0xFF212121);
  static const Color card = Color(0xFF181818);

  // ── Glassmorphism ────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0x0FFFFFFF); // 6% white
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white border
  static const Color glassRed = Color(0x1AE50914); // 10% red tint

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF444444);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E); // Green — Completed / Paid
  static const Color warning = Color(0xFFF59E0B); // Yellow — Partial
  static const Color error = Color(0xFFEF4444); // Red — Pending / Error
  static const Color info = Color(0xFF3B82F6); // Blue — Info

  // ── Payment status colours ────────────────────────────────────────────────
  static const Color paymentCompleted = Color(0xFF22C55E);
  static const Color paymentPartial = Color(0xFFF59E0B);
  static const Color paymentPending = Color(0xFFEF4444);

  // ── Divider / border ─────────────────────────────────────────────────────
  static const Color divider = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF2E2E2E);
  static const Color borderActive = Color(0xFFE50914);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE50914), Color(0xFFB0060F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF222222), Color(0xFF181818)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow shadow used on red-accent elements
  static List<BoxShadow> get redGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
