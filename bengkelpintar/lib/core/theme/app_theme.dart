import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.surface,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.textTitle,
      secondary: AppColors.primaryDark,
      onSecondary: AppColors.surface,
      secondaryContainer: AppColors.primarySoft,
      onSecondaryContainer: AppColors.textTitle,
      tertiary: AppColors.primaryDeep,
      onTertiary: AppColors.surface,
      tertiaryContainer: AppColors.primaryTint,
      onTertiaryContainer: AppColors.textTitle,
      error: AppColors.danger,
      onError: AppColors.surface,
      errorContainer: AppColors.dangerSoft,
      onErrorContainer: AppColors.textTitle,
      surface: AppColors.surface,
      onSurface: AppColors.textTitle,
      surfaceContainerHighest: AppColors.surfaceRaised,
      onSurfaceVariant: AppColors.textBody,
      outline: AppColors.border,
      outlineVariant: AppColors.borderStrong,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.navy,
      onInverseSurface: AppColors.surface,
      inversePrimary: AppColors.lightBlue,
      surfaceTint: Colors.transparent,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      canvasColor: AppColors.background,
      cardColor: AppColors.surface,
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      applyElevationOverlayColor: false,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displayLarge: AppText.display,
        titleLarge: AppText.title,
        titleMedium: AppText.heading,
        titleSmall: AppText.subheading,
        bodyLarge: AppText.body,
        bodyMedium: AppText.body,
        bodySmall: AppText.bodySmall,
        labelLarge: AppText.button,
        labelMedium: AppText.label,
      ),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textMuted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppText.bodySmall.copyWith(
            color: selected ? AppColors.primary : AppColors.textMuted,
          );
        }),
        overlayColor: const WidgetStatePropertyAll(AppColors.primaryOverlay),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        constraints: const BoxConstraints(
          minHeight: AppSpacing.formInputHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.disabled),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        contentTextStyle: AppText.body.copyWith(color: AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        insetPadding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.sm,
          AppSpacing.pageMargin,
          AppSpacing.lg,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
