import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.color = AppColors.primary,
  });
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    ),
    child: Text(
      label.toUpperCase(),
      style: AppText.label.copyWith(color: AppColors.surface),
    ),
  );
}
