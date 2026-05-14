import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/common_dashboard_appbar.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../models/attendance_model.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/staff_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final attendance = context.read<AttendanceProvider>();
      final staff = context.read<StaffProvider>();
      staff.startListening();
      await attendance.fetchForDate(_selectedDate);
      if (mounted) {
        attendance.initForStaff(staff.staff);
      }
    });
  }

  Future<void> _pickDate() async {
    // Capture providers before any await to satisfy use_build_context_synchronously
    final attendance = context.read<AttendanceProvider>();
    final staffList = context.read<StaffProvider>().staff;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedDate = picked);
    await attendance.fetchForDate(picked);
    if (mounted) attendance.initForStaff(staffList);
  }

  Future<void> _save() async {
    final attendance = context.read<AttendanceProvider>();
    final ok = await attendance.saveAll();
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, AppStrings.attendanceSaved);
    } else {
      AppSnackbar.error(
          context, attendance.error ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final records = attendance.records
        .where((r) =>
            _search.isEmpty ||
            r.staffName.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonDashboardAppBar(
        title: AppStrings.attendance,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _pickDate,
            tooltip: 'Pick Date',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Date + stats header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.md,
              AppSizes.pagePaddingH,
              AppSizes.sm,
            ),
            child: GlassmorphismCard(
              redBorder: true,
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateHelpers.formatDate(_selectedDate),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.fontLg,
                        ),
                      ),
                      Text(
                        '${attendance.records.length} staff members',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _MiniStat('Present', attendance.presentCount, AppColors.success),
                  const SizedBox(width: AppSizes.md),
                  _MiniStat('Absent', attendance.absentCount, AppColors.error),
                  const SizedBox(width: AppSizes.md),
                  _MiniStat('Late', attendance.lateCount, AppColors.warning),
                ],
              ),
            ),
          ),

          // ── Search ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.sm,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search staff…',
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textHint),
              ),
            ),
          ),

          // ── Attendance list ───────────────────────────────────────────
          Expanded(
            child: attendance.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : records.isEmpty
                    ? const Center(
                        child: Text('No staff found',
                            style: TextStyle(color: AppColors.textHint)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.pagePaddingH),
                        itemCount: records.length,
                        itemBuilder: (_, i) =>
                            _AttendanceTile(record: records[i]),
                      ),
          ),

          // ── Save button ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.sm,
              AppSizes.pagePaddingH,
              AppSizes.xl,
            ),
            child: AppButton(
              label: AppStrings.markAttendance,
              onPressed: _save,
              isLoading: attendance.isLoading,
              icon: Icons.save_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.record});
  final AttendanceModel record;

  @override
  Widget build(BuildContext context) {
    final attendance = context.read<AttendanceProvider>();
    return GlassmorphismCard(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              record.staffName.isNotEmpty
                  ? record.staffName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              record.staffName,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          // Status toggle buttons
          _StatusBtn(
            label: 'P',
            selected: record.status == 'present',
            color: AppColors.success,
            onTap: () =>
                attendance.updateStatus(record.staffId, 'present'),
          ),
          const SizedBox(width: AppSizes.xs),
          _StatusBtn(
            label: 'L',
            selected: record.status == 'late',
            color: AppColors.warning,
            onTap: () =>
                attendance.updateStatus(record.staffId, 'late'),
          ),
          const SizedBox(width: AppSizes.xs),
          _StatusBtn(
            label: 'A',
            selected: record.status == 'absent',
            color: AppColors.error,
            onTap: () =>
                attendance.updateStatus(record.staffId, 'absent'),
          ),
        ],
      ),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  const _StatusBtn({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(
              color: selected ? color : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textHint,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.fontXl)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textHint, fontSize: AppSizes.fontXs)),
      ],
    );
  }
}
