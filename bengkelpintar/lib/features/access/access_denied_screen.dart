import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blue_header.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BlueHeader(
            title: 'Akses Ditolak',
            type: BlueHeaderType.h2,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSpacing.statusIcon,
                      height: AppSpacing.statusIcon,
                      decoration: const BoxDecoration(
                        color: AppColors.dangerSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        AppIcons.lock,
                        color: AppColors.danger,
                        size: AppSpacing.iconLarge,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Halaman ini hanya untuk admin',
                      textAlign: TextAlign.center,
                      style: AppText.heading,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Anda tidak memiliki akses ke halaman ini.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.secondary(
                      label: 'Kembali',
                      onPressed: () => Navigator.maybePop(context),
                      expand: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
