import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bengkelpintar/core/theme/app_colors.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';

void main() {
  test('tema aplikasi memakai token visual dan font lokal', () {
    final theme = AppTheme.light;

    expect(theme.textTheme.bodyLarge?.fontFamily, 'Plus Jakarta Sans');
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.primary);
  });

  test('tema dan ujung gradasi hanya memakai token keluarga biru', () {
    final theme = AppTheme.light;
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
      theme.colorScheme.inversePrimary,
    ];

    expect(AppColors.gradientEnd, AppColors.primaryDark);
    expect(colors, isNot(contains(const Color(0xFF4B3FE0))));
    expect(colors, isNot(contains(const Color(0xFF4F46E5))));
    expect(colors, isNot(contains(const Color(0xFF4338CA))));
    expect(colors, isNot(contains(const Color(0xFF6366F1))));
    expect(colors, isNot(contains(const Color(0xFF7C3AED))));
    expect(colors, isNot(contains(const Color(0xFF6750A4))));
    expect(theme.colorScheme.surfaceTint, Colors.transparent);
    expect(theme.navigationBarTheme.surfaceTintColor, Colors.transparent);
  });
}
