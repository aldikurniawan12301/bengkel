import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'app_checkbox.dart';

class CheckListItem extends StatelessWidget {
  const CheckListItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: value ? AppColors.primarySoft : AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      side: BorderSide(
        color: value ? AppColors.primary : AppColors.border,
        width: value ? AppSpacing.selectedBorderWidth : AppSpacing.borderWidth,
      ),
    ),
    child: InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            AppCheckbox(value: value, onChanged: onChanged),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body),
                  if (subtitle != null)
                    Text(subtitle!, style: AppText.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
