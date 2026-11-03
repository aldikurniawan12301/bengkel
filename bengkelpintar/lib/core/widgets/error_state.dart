import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message = 'Terjadi kendala. Silakan coba lagi.',
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.statusIcon,
              height: AppSpacing.statusIcon,
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: .25),
                ),
              ),
              child: const Icon(
                AppIcons.roundedError,
                color: AppColors.danger,
                size: AppSpacing.iconLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(message, textAlign: TextAlign.center, style: AppText.body),
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: 'Coba lagi',
              onPressed: onRetry,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }
}
