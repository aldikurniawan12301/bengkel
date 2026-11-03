import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

enum AppStatus {
  draft,
  finalised,
  aktif,
  nonaktif,
  stokAman,
  stokMenipis,
  stokHabis,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, soft) = switch (status) {
      AppStatus.draft => ('Draft', AppColors.warning, AppColors.warningSoft),
      AppStatus.finalised => (
        'Final',
        AppColors.success,
        AppColors.successSoft,
      ),
      AppStatus.aktif => ('Aktif', AppColors.success, AppColors.successSoft),
      AppStatus.nonaktif => (
        'Nonaktif',
        AppColors.disabled,
        AppColors.primarySoft,
      ),
      AppStatus.stokAman => (
        'Stok aman',
        AppColors.success,
        AppColors.successSoft,
      ),
      AppStatus.stokMenipis => (
        'Stok menipis',
        AppColors.warning,
        AppColors.warningSoft,
      ),
      AppStatus.stokHabis => (
        'Stok habis',
        AppColors.danger,
        AppColors.dangerSoft,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        label,
        style: AppText.label.copyWith(
          color: color == AppColors.disabled ? AppColors.textMuted : color,
        ),
      ),
    );
  }
}
