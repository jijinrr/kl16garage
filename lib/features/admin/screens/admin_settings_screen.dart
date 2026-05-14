import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../routes/app_router.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.pagePaddingV,
        ),
        children: [
          // ── Profile card (re-builds only when profile changes) ────────────
          Selector<UserProvider, ({String name, String email, String initial, bool hasPhoto})>(
            selector: (_, u) => (
              name: u.name,
              email: u.email,
              initial: u.initial,
              hasPhoto: u.hasPhoto,
            ),
            builder: (_, user, _) => GlassmorphismCard(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isEmpty ? 'Admin' : user.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: AppSizes.fontLg,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: AppSizes.fontSm,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusRound),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          GlassmorphismCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Dark mode — only rebuilds on toggle
                Selector<SettingsProvider, bool>(
                  selector: (_, s) => s.isDarkMode,
                  builder: (_, isDark, _) => _Tile(
                    icon: Icons.dark_mode_outlined,
                    label: AppStrings.darkMode,
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) =>
                          context.read<SettingsProvider>().toggleDarkMode(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                const _Tile(
                  icon: Icons.manage_accounts_outlined,
                  label: AppStrings.userManagement,
                ),
                const Divider(height: 1, color: AppColors.divider),
                const _Tile(
                  icon: Icons.backup_outlined,
                  label: AppStrings.backupData,
                ),
                const Divider(height: 1, color: AppColors.divider),
                const _Tile(
                  icon: Icons.notifications_outlined,
                  label: AppStrings.notifications,
                ),
                const Divider(height: 1, color: AppColors.divider),
                const _Tile(
                  icon: Icons.security_outlined,
                  label: AppStrings.securitySettings,
                ),
                const Divider(height: 1, color: AppColors.divider),
                const _Tile(
                  icon: Icons.privacy_tip_outlined,
                  label: AppStrings.privacyPolicy,
                ),
                const Divider(height: 1, color: AppColors.divider),
                const _Tile(
                  icon: Icons.description_outlined,
                  label: AppStrings.termsAndConditions,
                ),
                const Divider(height: 1, color: AppColors.divider),
                const _Tile(
                  icon: Icons.info_outline,
                  label: AppStrings.appVersionLabel,
                  trailingText: AppStrings.appVersion,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          GlassmorphismCard(
            padding: EdgeInsets.zero,
            child: _Tile(
              icon: Icons.logout,
              label: AppStrings.logout,
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () => _confirmLogout(context),
            ),
          ),

          const SizedBox(height: AppSizes.xxxl),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text(AppStrings.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await auth.logout();
        if (context.mounted) context.go(Routes.roleSelection);
      });
    }
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    this.trailing,
    this.trailingText,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon,
          color: iconColor ?? AppColors.textSecondary,
          size: AppSizes.iconMd),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontSize: AppSizes.fontMd,
        ),
      ),
      trailing: trailing ??
          (trailingText != null
              ? Text(trailingText!,
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: AppSizes.fontSm))
              : onTap != null
                  ? const Icon(Icons.chevron_right, color: AppColors.textHint)
                  : null),
    );
  }
}
