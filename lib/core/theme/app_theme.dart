import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// KL16 Garage Pro — centralized ThemeData.
/// Dark-only theme. All colour references flow from AppColors.
class AppTheme {
  AppTheme._();

  // ── Light theme (white/black/red) ─────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        error: AppColors.error,
        onError: Colors.white,
        outline: Color(0xFFDDDDDD),
      ),
      textTheme: _buildLightTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: GoogleFonts.montserrat(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.fontXl,
        ),
        iconTheme:
            const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle:
            const TextStyle(color: Color(0xFF888888)),
        hintStyle:
            const TextStyle(color: Color(0xFFAAAAAA)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF888888),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        titleTextStyle: GoogleFonts.montserrat(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.fontXl,
        ),
      ),
    );
  }

  static TextTheme _buildLightTextTheme() {
    final poppins = GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);
    final montserrat =
        GoogleFonts.montserratTextTheme(ThemeData.light().textTheme);
    return poppins.copyWith(
      displayLarge: montserrat.displayLarge
          ?.copyWith(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w800),
      displayMedium: montserrat.displayMedium
          ?.copyWith(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w700),
      headlineLarge: montserrat.headlineLarge
          ?.copyWith(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w700),
      headlineMedium: montserrat.headlineMedium
          ?.copyWith(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w700),
      headlineSmall: montserrat.headlineSmall
          ?.copyWith(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w600),
      titleLarge: poppins.titleLarge
          ?.copyWith(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w600),
      bodyLarge: poppins.bodyLarge?.copyWith(color: const Color(0xFF1A1A1A)),
      bodyMedium: poppins.bodyMedium?.copyWith(color: const Color(0xFF333333)),
      bodySmall: poppins.bodySmall?.copyWith(color: const Color(0xFF666666)),
    );
  }

  // ── Dark theme (black/red/white) ──────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      inputDecorationTheme: _buildInputTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      chipTheme: _buildChipTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      snackBarTheme: _buildSnackBarTheme(),
      dialogTheme: _buildDialogTheme(),
    );
  }

  // ── Text Theme ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme() {
    final poppins = GoogleFonts.poppinsTextTheme();
    final montserrat = GoogleFonts.montserratTextTheme();

    return TextTheme(
      // Display / Hero — Montserrat Bold
      displayLarge: montserrat.displayLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: AppSizes.fontHero,
      ),
      displayMedium: montserrat.displayMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.fontDisplay,
      ),
      displaySmall: montserrat.displaySmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.fontXxl,
      ),

      // Headlines — Montserrat SemiBold
      headlineLarge: montserrat.headlineLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.fontXxl,
      ),
      headlineMedium: montserrat.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.fontXl,
      ),
      headlineSmall: montserrat.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.fontLg,
      ),

      // Titles — Poppins SemiBold
      titleLarge: poppins.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.fontXl,
      ),
      titleMedium: poppins.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.fontLg,
      ),
      titleSmall: poppins.titleSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: AppSizes.fontMd,
      ),

      // Body — Poppins Regular
      bodyLarge: poppins.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
        fontSize: AppSizes.fontLg,
      ),
      bodyMedium: poppins.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: AppSizes.fontMd,
      ),
      bodySmall: poppins.bodySmall?.copyWith(
        color: AppColors.textHint,
        fontWeight: FontWeight.w400,
        fontSize: AppSizes.fontSm,
      ),

      // Labels
      labelLarge: poppins.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.fontMd,
      ),
      labelMedium: poppins.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: AppSizes.fontSm,
      ),
      labelSmall: poppins.labelSmall?.copyWith(
        color: AppColors.textHint,
        fontWeight: FontWeight.w400,
        fontSize: AppSizes.fontXs,
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: GoogleFonts.montserrat(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.fontXl,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────
  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    );
  }

  // ── TextField / Input ─────────────────────────────────────────────────────
  static InputDecorationTheme _buildInputTheme() {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
      borderSide: BorderSide(color: AppColors.border),
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    );
    const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
      borderSide: BorderSide(color: AppColors.error),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.textHint,
        fontSize: AppSizes.fontMd,
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: AppSizes.fontMd,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
    );
  }

  // ── ElevatedButton ────────────────────────────────────────────────────────
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontLg,
        ),
      ),
    );
  }

  // ── OutlinedButton ────────────────────────────────────────────────────────
  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontLg,
        ),
      ),
    );
  }

  // ── TextButton ────────────────────────────────────────────────────────────
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontMd,
        ),
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  static BottomNavigationBarThemeData _buildBottomNavTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    );
  }

  // ── Chip ──────────────────────────────────────────────────────────────────
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      disabledColor: AppColors.surfaceVariant,
      labelStyle: GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: AppSizes.fontSm,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        color: AppColors.primary,
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.border, width: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
    );
  }

  // ── SnackBar ──────────────────────────────────────────────────────────────
  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: GoogleFonts.poppins(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  // ── Dialog ────────────────────────────────────────────────────────────────
  static DialogThemeData _buildDialogTheme() {
    return DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      titleTextStyle: GoogleFonts.montserrat(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.fontXl,
      ),
      contentTextStyle: GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: AppSizes.fontMd,
      ),
    );
  }

  // ── Glassmorphism helper ──────────────────────────────────────────────────
  /// Returns a BoxDecoration that mimics glassmorphism for Container usage.
  static BoxDecoration glassDecoration({
    Color? tint,
    double borderRadius = AppSizes.radiusLg,
    bool redBorder = false,
  }) {
    return BoxDecoration(
      color: tint ?? AppColors.glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: redBorder ? AppColors.primary.withValues(alpha: 0.5) : AppColors.glassBorder,
        width: redBorder ? 1.5 : 0.5,
      ),
    );
  }
}
