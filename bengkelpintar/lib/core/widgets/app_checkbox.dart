import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final box = InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        width: AppSpacing.checkbox,
        height: AppSpacing.checkbox,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.border,
            width: AppSpacing.focusBorderWidth,
          ),
        ),
        child: value
            ? const Icon(
                AppIcons.check,
                color: AppColors.surface,
                size: AppSpacing.iconSmall,
              )
            : null,
      ),
    );
    return label == null
        ? box
        : InkWell(
            onTap: () => onChanged?.call(!value),
            child: Row(
              children: [
                box,
                const SizedBox(width: AppSpacing.sm),
                Flexible(child: Text(label!, style: AppText.body)),
              ],
            ),
          );
  }
}
