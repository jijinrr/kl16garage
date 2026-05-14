import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Admin → go to login screen with credentials
  void _selectAdmin() {
    context.read<AuthProvider>().setSelectedRole('admin');
    context.push(Routes.login);
  }

  /// Staff → direct login, no credentials needed
  Future<void> _selectStaff() async {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);
    final auth = context.read<AuthProvider>();
    auth.setSelectedRole('staff');
    await auth.loginAsStaff();
    // GoRouter redirect handles navigation on success
    if (mounted) setState(() => _isLoggingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow orbs
          const Positioned(
              top: -120, left: -80, child: _GlowOrb(size: 320, opacity: 0.07)),
          const Positioned(
              bottom: -100,
              right: -60,
              child: _GlowOrb(size: 260, opacity: 0.05)),
          const Positioned(
              top: 220,
              right: -40,
              child: _GlowOrb(size: 160, opacity: 0.04)),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePaddingH),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.redGlow,
                        ),
                        child: const Icon(
                          Icons.local_car_wash,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // Title
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.primaryGradient.createShader(b),
                        child: const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.fontXxl,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      const Text(
                        'Select your role to continue',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: AppSizes.fontMd,
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── Admin card → login with credentials
                      _RoleCard(
                        title: 'Administrator',
                        subtitle: 'Full Garage Management',
                        description:
                            'Analytics, staff control, attendance,\nreports and system settings.',
                        icon: Icons.admin_panel_settings_outlined,
                        accentColor: AppColors.primary,
                        badge: 'Credentials Required',
                        badgeIcon: Icons.lock_outline,
                        isLoading: false,
                        onTap: _selectAdmin,
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // ── Staff card → direct login
                      _RoleCard(
                        title: 'Staff Member',
                        subtitle: 'Service Operations',
                        description:
                            'Add customers, track services\nand manage daily expenses.',
                        icon: Icons.engineering_outlined,
                        accentColor: AppColors.info,
                        badge: 'Tap to Enter',
                        badgeIcon: Icons.touch_app_outlined,
                        isLoading: _isLoggingIn,
                        onTap: _selectStaff,
                      ),

                      const Spacer(flex: 2),

                      Text(
                        '${AppStrings.appVersionLabel}: ${AppStrings.appVersion}',
                        style: const TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: AppSizes.fontXs,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role Card ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.badgeIcon,
    required this.isLoading,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String badge;
  final IconData badgeIcon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon badge
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.accentColor.withValues(alpha: 0.22),
                              widget.accentColor.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(
                              color: widget.accentColor.withValues(alpha: 0.3)),
                        ),
                        child: widget.isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: widget.accentColor,
                                ),
                              )
                            : Icon(widget.icon,
                                color: widget.accentColor,
                                size: AppSizes.iconLg),
                      ),
                      const SizedBox(width: AppSizes.lg),

                      // Labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: AppSizes.fontLg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: widget.accentColor,
                                fontSize: AppSizes.fontSm,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              widget.description,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: AppSizes.fontXs,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: widget.accentColor.withValues(alpha: 0.7),
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  // Badge row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.badgeIcon,
                          size: 11,
                          color: widget.accentColor.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(
                        widget.badge,
                        style: TextStyle(
                          color: widget.accentColor.withValues(alpha: 0.8),
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Decorative glow orb ────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: opacity),
      ),
    );
  }
}
