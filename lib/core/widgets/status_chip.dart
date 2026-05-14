import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Coloured status chip for payment and service statuses.
enum StatusType {
  completed,
  partial,
  pending,
  present,
  absent,
  late,
  active,
  inactive,
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.fontSize = AppSizes.fontSm,
  });

  final StatusType status;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: _bgColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _bgColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case StatusType.completed:
        return 'Completed';
      case StatusType.partial:
        return 'Partial';
      case StatusType.pending:
        return 'Pending';
      case StatusType.present:
        return 'Present';
      case StatusType.absent:
        return 'Absent';
      case StatusType.late:
        return 'Late';
      case StatusType.active:
        return 'Active';
      case StatusType.inactive:
        return 'Inactive';
    }
  }

  Color get _bgColor {
    switch (status) {
      case StatusType.completed:
      case StatusType.present:
      case StatusType.active:
        return AppColors.success;
      case StatusType.partial:
      case StatusType.late:
        return AppColors.warning;
      case StatusType.pending:
      case StatusType.absent:
      case StatusType.inactive:
        return AppColors.error;
    }
  }
}

/// Converts a string status to [StatusType].
StatusType statusTypeFromString(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return StatusType.completed;
    case 'partial':
      return StatusType.partial;
    case 'present':
      return StatusType.present;
    case 'absent':
      return StatusType.absent;
    case 'late':
      return StatusType.late;
    case 'active':
      return StatusType.active;
    case 'inactive':
      return StatusType.inactive;
    default:
      return StatusType.pending;
  }
}
