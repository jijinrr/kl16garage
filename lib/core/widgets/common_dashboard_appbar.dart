import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/date_helpers.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_router.dart';

/// Premium unified dashboard app bar used across ALL screens.
///
/// - [title] — if provided, replaces the auto-generated greeting with a
///   plain title string (for Analytics, Attendance, Settings, Stock, etc.)
/// - [showBack] — shows a back chevron (for pushed full-screen routes like Stock)
/// - [extraActions] — additional trailing widgets inserted before the avatar
class CommonDashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CommonDashboardAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.onNotificationTap,
    this.onAvatarTap,
    this.extraActions = const [],
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height +
          MediaQuery.of(context).padding.top, // respect status bar
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF0D0D0D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXl),
          bottomRight: Radius.circular(AppSizes.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.14),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Back button (pushed screens only) ──────────────────────
              if (showBack) ...[
                GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.xs + 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: AppSizes.iconSm,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
              ],

              // ── Left: greeting OR title ─────────────────────────────────
              Expanded(
                child: title != null
                    ? _TitleSection(title: title!)
                    : const _GreetingSection(),
              ),

              // ── Right: extra actions + notification + avatar ────────────
              ...extraActions,
              _NotificationButton(onTap: onNotificationTap),
              const SizedBox(width: AppSizes.xs),
              _AvatarButton(onTap: onAvatarTap),
              const SizedBox(width: AppSizes.xs),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Left content variants ─────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Selector<UserProvider, String>(
          selector: (_, u) => u.name,
          builder: (_, name, _) {
            final first = name.split(' ').first;
            return Text(
              '${DateHelpers.greeting()}, ${first.isEmpty ? 'KL16' : first} 👋',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        const SizedBox(height: 2),
        Text(
          DateHelpers.formatDate(DateTime.now()),
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: AppSizes.fontXs,
          ),
        ),
      ],
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppSizes.fontXl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── Right content widgets ─────────────────────────────────────────────────────

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.sm - 2),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<UserProvider, String>(
      selector: (_, u) => u.initial,
      builder: (_, initial, _) => GestureDetector(
        onTap: onTap ??
            () {
              // Default: navigate to settings based on role
              final loc = GoRouterState.of(context).matchedLocation;
              if (loc.startsWith('/admin')) {
                context.go(Routes.adminSettings);
              } else {
                context.go(Routes.staffSettings);
              }
            },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: AppSizes.fontSm,
            ),
          ),
        ),
      ),
    );
  }
}
