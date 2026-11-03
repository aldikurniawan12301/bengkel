import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Cari',
    this.onChanged,
    this.onFilter,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          AppSpacing.searchHeight +
          (MediaQuery.textScalerOf(context).scale(1) > 1 ? AppSpacing.md : 0),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        style: AppText.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(
            AppIcons.search,
            size: AppSpacing.icon,
            color: AppColors.textMuted,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: IconButton(
              onPressed: onFilter,
              tooltip: 'Filter',
              icon: const Icon(
                AppIcons.tune,
                color: AppColors.surface,
                size: AppSpacing.icon,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
              ),
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: AppSpacing.focusBorderWidth,
            ),
          ),
        ),
      ),
    );
  }
}
