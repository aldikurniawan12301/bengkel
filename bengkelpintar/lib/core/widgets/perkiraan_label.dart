import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class PerkiraanLabel extends StatelessWidget {
  const PerkiraanLabel({super.key, this.onHeader = false});

  final bool onHeader;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: onHeader ? AppColors.surface : AppColors.warningSoft,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          AppIcons.roundedInfo,
          size: AppSpacing.iconSmall,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Perkiraan',
          style: AppText.label.copyWith(
            color: onHeader ? AppColors.textTitle : AppColors.warning,
          ),
        ),
      ],
    ),
  );
}
