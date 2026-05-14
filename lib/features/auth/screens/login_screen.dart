import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (!ok) {
      AppSnackbar.error(context, auth.error ?? AppStrings.somethingWentWrong);
    }
    // GoRouter redirect handles navigation on success
  }

  @override
  Widget build(BuildContext context) {
    // Use Selector so only the loading state + selectedRole triggers rebuild
    return Selector<AuthProvider, ({bool isLoading, String role})>(
      selector: (_, a) => (isLoading: a.isLoading, role: a.selectedRole),
      builder: (context, data, _) {
        final isAdmin = data.role == 'admin';
        final accentColor =
            isAdmin ? AppColors.primary : AppColors.info;
        final roleLabel = isAdmin ? 'Administrator' : 'Staff Member';
        final roleEmail =
            isAdmin ? 'admin@kl16.com' : 'staff@kl16.com';
        final roleIcon = isAdmin
            ? Icons.admin_panel_settings_outlined
            : Icons.engineering_outlined;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Glow circles
              Positioned(
                top: -100,
                left: -100,
                child: _GlowOrb(color: accentColor, size: 300, opacity: 0.08),
              ),
              Positioned(
                bottom: -80,
                right: -80,
                child: _GlowOrb(color: accentColor, size: 240, opacity: 0.05),
              ),

              SafeArea(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideIn,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH,
                        vertical: AppSizes.pagePaddingV,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSizes.xxl),

                          // ── Role badge (back + icon) ───────────────────────
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSizes.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusSm),
                                    border: Border.all(
                                        color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md,
                                  vertical: AppSizes.xs,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusRound),
                                  border: Border.all(
                                      color: accentColor
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(roleIcon,
                                        color: accentColor, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      roleLabel,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: AppSizes.fontXs,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.xxxl),

                          // ── Logo ─────────────────────────────────────────
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: isAdmin
                                  ? AppColors.primaryGradient
                                  : LinearGradient(colors: [
                                      AppColors.info,
                                      AppColors.info
                                          .withValues(alpha: 0.7)
                                    ]),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child:
                                Icon(roleIcon, size: 36, color: Colors.white),
                          ),

                          const SizedBox(height: AppSizes.xl),

                          Text(
                            isAdmin ? 'Admin Login' : 'Staff Login',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: AppSizes.fontXxl,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'Sign in as $roleLabel to continue',
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: AppSizes.fontSm,
                            ),
                          ),

                          const SizedBox(height: AppSizes.xxxl),

                          // ── Login card ────────────────────────────────────
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusXxl),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(AppSizes.xxl),
                                decoration: BoxDecoration(
                                  color: AppColors.glassWhite,
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusXxl),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Email
                                      AppTextField(
                                        controller: _emailCtrl,
                                        label: 'Email',
                                        hint: roleEmail,
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: Validators.email,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
                                      ),
                                      const SizedBox(height: AppSizes.lg),

                                      // Password
                                      AppTextField(
                                        controller: _passCtrl,
                                        label: AppStrings.password,
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscure,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Required'
                                                : null,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _login(),
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscure
                                                ? Icons.visibility_outlined
                                                : Icons
                                                    .visibility_off_outlined,
                                            color: AppColors.textHint,
                                            size: AppSizes.iconSm,
                                          ),
                                          onPressed: () => setState(
                                              () => _obscure = !_obscure),
                                        ),
                                      ),
                                      const SizedBox(height: AppSizes.xxl),

                                      // Login button
                                      AppButton(
                                        label: AppStrings.login,
                                        onPressed: _login,
                                        isLoading: data.isLoading,
                                        icon: Icons.login_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSizes.xl),

                          // Hint
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.lg,
                              vertical: AppSizes.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.surface.withValues(alpha: 0.6),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColors.textHint, size: 14),
                                const SizedBox(width: AppSizes.sm),
                                Expanded(
                                  child: Text(
                                    'Email: $roleEmail  •  Password: 123456',
                                    style: const TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: AppSizes.fontXs,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSizes.xxxl),
                          Text(
                            '${AppStrings.appVersionLabel}: ${AppStrings.appVersion}',
                            style: const TextStyle(
                              color: AppColors.textDisabled,
                              fontSize: AppSizes.fontXs,
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb(
      {required this.color, required this.size, required this.opacity});
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}
