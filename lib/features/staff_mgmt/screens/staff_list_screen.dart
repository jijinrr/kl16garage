import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/staff_model.dart';
import '../../../providers/staff_provider.dart';
import '../../../routes/app_router.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProv = context.watch<StaffProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.staff_)),
      body: Column(
        children: [
          // ── Search ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.md,
              AppSizes.pagePaddingH,
              AppSizes.sm,
            ),
            child: TextField(
              onChanged: staffProv.setSearch,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search staff…',
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textHint),
              ),
            ),
          ),

          // ── Stats row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH),
            child: Row(
              children: [
                Text(
                  '${staffProv.activeCount} active',
                  style: const TextStyle(
                      color: AppColors.success,
                      fontSize: AppSizes.fontSm),
                ),
                const SizedBox(width: AppSizes.md),
                Text(
                  '${staffProv.inactiveCount} inactive',
                  style: const TextStyle(
                      color: AppColors.error, fontSize: AppSizes.fontSm),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: staffProv.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH),
                    child: ShimmerList(count: 5),
                  )
                : staffProv.staff.isEmpty
                    ? const EmptyStateWidget(
                        title: AppStrings.noStaff,
                        subtitle: 'Tap + to add your first staff member.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.pagePaddingH,
                          0,
                          AppSizes.pagePaddingH,
                          100,
                        ),
                        itemCount: staffProv.staff.length,
                        itemBuilder: (_, i) => _StaffCard(
                          staff: staffProv.staff[i],
                          onToggle: () => staffProv.toggleStatus(
                            staffProv.staff[i].id,
                            !staffProv.staff[i].isActive,
                          ),
                          onEdit: () => context.push(
                            Routes.adminAddStaff,
                            extra: staffProv.staff[i],
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.adminAddStaff),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text(AppStrings.addStaff),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.onToggle,
    required this.onEdit,
  });

  final StaffModel staff;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          // Photo / avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.avatarMd / 2),
            child: staff.photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: staff.photoUrl,
                    width: AppSizes.avatarMd,
                    height: AppSizes.avatarMd,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _avatar(),
                    errorWidget: (_, _, _) => _avatar(),
                  )
                : _avatar(),
          ),
          const SizedBox(width: AppSizes.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontLg,
                  ),
                ),
                Text(
                  staff.phone,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    StatusChip(
                      status: staff.isActive
                          ? StatusType.active
                          : StatusType.inactive,
                      fontSize: AppSizes.fontXs,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      staff.role.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: AppSizes.iconSm, color: AppColors.textSecondary),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(
                  staff.isActive
                      ? Icons.toggle_on
                      : Icons.toggle_off_outlined,
                  size: AppSizes.iconMd,
                  color: staff.isActive ? AppColors.success : AppColors.error,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: AppSizes.avatarMd,
      height: AppSizes.avatarMd,
      color: AppColors.primary.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.fontXl),
        ),
      ),
    );
  }
}
