import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

enum AppButtonVariant { primary, secondary, tonal, small, danger, onPrimary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height,
  }) : variant = AppButtonVariant.primary;
  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height,
  }) : variant = AppButtonVariant.secondary;
  const AppButton.tonal({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height,
  }) : variant = AppButtonVariant.tonal;
  const AppButton.small({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.height,
  }) : variant = AppButtonVariant.small;
  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height,
  }) : variant = AppButtonVariant.danger;
  const AppButton.onPrimary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height,
  }) : variant = AppButtonVariant.onPrimary;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isOutline = variant == AppButtonVariant.secondary;
    final isTonal = variant == AppButtonVariant.tonal;
    final isSmall = variant == AppButtonVariant.small;
    final isDanger = variant == AppButtonVariant.danger;
    final isOnPrimary = variant == AppButtonVariant.onPrimary;
    final background = isOutline
        ? AppColors.surface
        : isTonal
        ? AppColors.primarySoft
        : isDanger
        ? AppColors.danger
        : isOnPrimary
        ? AppColors.surface
        : AppColors.primary;
    final foreground = isOutline
        ? AppColors.primary
        : isTonal
        ? AppColors.primary
        : isOnPrimary
        ? AppColors.primary
        : AppColors.surface;
    final child = loading
        ? SizedBox(
            width: AppSpacing.iconSmall,
            height: AppSpacing.iconSmall,
            child: CircularProgressIndicator(
              strokeWidth: AppSpacing.xs / 2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: isSmall
                      ? AppText.label.copyWith(color: foreground)
                      : AppText.button.copyWith(color: foreground),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, size: AppSpacing.iconSmall, color: foreground),
              ],
            ],
          );
    final button = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight:
            height ??
            (isSmall ? AppSpacing.smallButtonHeight : AppSpacing.buttonHeight),
        maxHeight: height ?? double.infinity,
      ),
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.surface,
          side: onPressed == null || loading
              ? BorderSide.none
              : BorderSide(
                  color: isOutline ? AppColors.primary : background,
                  width: isOutline
                      ? AppSpacing.focusBorderWidth
                      : AppSpacing.borderWidth,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          minimumSize: const Size(AppSpacing.touchMin, AppSpacing.touchMin),
        ),
        child: child,
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
