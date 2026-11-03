import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.chipHeight,
      child: FilterChip(
        label: Text(
          label,
          style: AppText.label.copyWith(
            color: selected ? AppColors.surface : AppColors.textTitle,
          ),
        ),
        avatar: icon == null
            ? null
            : Icon(
                icon,
                size: AppSpacing.iconSmall,
                color: selected ? AppColors.surface : AppColors.primary,
              ),
        selected: selected,
        onSelected: onSelected,
        showCheckmark: false,
        side: BorderSide.none,
        backgroundColor: AppColors.primarySoft,
        selectedColor: AppColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    );
  }
}
