import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

enum Urgensi { rendah, sedang, tinggi }

class UrgensiBadge extends StatelessWidget {
  const UrgensiBadge({super.key, required this.level});
  final Urgensi level;

  @override
  Widget build(BuildContext context) {
    final (label, color, soft) = switch (level) {
      Urgensi.rendah => ('Rendah', AppColors.success, AppColors.successSoft),
      Urgensi.sedang => ('Sedang', AppColors.warning, AppColors.warningSoft),
      Urgensi.tinggi => ('Tinggi', AppColors.danger, AppColors.dangerSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(label, style: AppText.label.copyWith(color: color)),
    );
  }
}
