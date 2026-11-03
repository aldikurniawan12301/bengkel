import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.onHeader = false,
    this.primary = false,
    this.compact = false,
    this.medium = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool onHeader;
  final bool primary;
  final bool compact;
  final bool medium;

  @override
  Widget build(BuildContext context) {
    final size = compact
        ? AppSpacing.stepperButtonSize
        : medium
        ? AppSpacing.backButtonSize
        : AppSpacing.touchMin;
    final iconButton = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: AppSpacing.iconSmall),
      color: onHeader || primary ? AppColors.surface : AppColors.primary,
      style: IconButton.styleFrom(
        minimumSize: Size(size, size),
        maximumSize: Size(size, size),
        padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),
        backgroundColor: onHeader
            ? AppColors.headerBackOverlay
            : primary
            ? AppColors.primary
            : AppColors.primarySoft,
        disabledForegroundColor: onHeader
            ? AppColors.surface
            : AppColors.textMuted,
        disabledBackgroundColor: onHeader
            ? AppColors.headerBackOverlay
            : AppColors.surfaceRaised,
      ),
    );
    final button = onHeader
        ? SizedBox(
            width: AppSpacing.touchMin,
            height: AppSpacing.touchMin,
            child: Center(child: iconButton),
          )
        : iconButton;
    return Semantics(button: true, label: tooltip, child: button);
  }
}
