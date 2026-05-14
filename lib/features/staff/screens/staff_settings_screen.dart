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

class StaffSettingsScreen extends StatelessWidget {
  const StaffSettingsScreen({super.key});

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
          // ── Profile card ──────────────────────────────────────────────────
          Selector<UserProvider, ({String name, String email, String role, String initial, bool hasPhoto})>(
            selector: (_, u) => (
              name: u.name,
              email: u.email,
              role: u.role,
              initial: u.initial,
              hasPhoto: u.hasPhoto,
            ),
            builder: (_, user, _) => GlassmorphismCard(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarMd / 2,
                    backgroundColor: AppColors.primary,
                    backgroundImage: context.read<UserProvider>().localPhoto != null
                        ? FileImage(context.read<UserProvider>().localPhoto!)
                        : (context.read<UserProvider>().networkPhotoUrl.isNotEmpty
                            ? NetworkImage(context.read<UserProvider>().networkPhotoUrl) as ImageProvider
                            : null),
                    child: !user.hasPhoto
                        ? Text(
                            user.initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppSizes.fontXl,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isEmpty ? 'Staff' : user.name,
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
                        Container(
                          margin: const EdgeInsets.only(top: AppSizes.xs),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusRound),
                          ),
                          child: Text(
                            user.role.toUpperCase().isEmpty
                                ? 'STAFF'
                                : user.role.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w600,
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

          // ── Settings tiles ────────────────────────────────────────────────
          GlassmorphismCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Dark mode toggle — only rebuilds when isDarkMode changes
                Selector<SettingsProvider, bool>(
                  selector: (_, s) => s.isDarkMode,
                  builder: (_, isDark, _) => _SettingsTile(
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
                const _Divider(),
                const _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: AppStrings.notifications,
                ),
                const _Divider(),
                const _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: AppStrings.privacyPolicy,
                ),
                const _Divider(),
                const _SettingsTile(
                  icon: Icons.description_outlined,
                  label: AppStrings.termsAndConditions,
                ),
                const _Divider(),
                const _SettingsTile(
                  icon: Icons.info_outline,
                  label: AppStrings.appVersionLabel,
                  trailingText: AppStrings.appVersion,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          // ── Logout ────────────────────────────────────────────────────────
          GlassmorphismCard(
            padding: EdgeInsets.zero,
            child: _SettingsTile(
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
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.logout),
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

// ── Tiles ──────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}
