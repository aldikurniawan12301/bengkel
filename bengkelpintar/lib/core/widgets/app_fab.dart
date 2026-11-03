import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: onPressed,
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.surface,
    icon: const Icon(AppIcons.addRounded, size: AppSpacing.icon),
    label: Text(
      label,
      style: AppText.button.copyWith(color: AppColors.surface),
    ),
  );
}
