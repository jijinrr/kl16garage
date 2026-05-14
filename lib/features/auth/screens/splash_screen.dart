import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _navigate();
  }

  Future<void> _navigate() async {
    // Reduced from 2800ms for faster startup
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      final route = auth.role == UserRole.admin
          ? Routes.adminHome
          : Routes.staffHome;
      context.go(route);
    } else {
      // Always go to role selection, not directly to login
      context.go(Routes.roleSelection);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ClipRect(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo / Lottie animation
                    _buildLogo(),
                    const SizedBox(height: AppSizes.xxl),
                    // App name
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontDisplay,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      AppStrings.appTagline,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppSizes.fontMd,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Loading indicator at bottom
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    const Text(
                      AppStrings.loading,
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    try {
      return Lottie.asset(
        AppIcons.splashAnim,
        controller: _controller,
        width: 160,
        height: 160,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward();
        },
        errorBuilder: (_, _, _) => _fallbackLogo(),
      );
    } catch (_) {
      return _fallbackLogo();
    }
  }

  Widget _fallbackLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: AppColors.redGlow,
      ),
      child: const Icon(
        Icons.local_car_wash,
        size: 60,
        color: Colors.white,
      ),
    );
  }
}
