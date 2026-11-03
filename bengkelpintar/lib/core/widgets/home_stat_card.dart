import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class HomeStatCard extends StatelessWidget {
  const HomeStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.warning = false,
    this.onTap,
    this.onPrimary = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool warning;
  final VoidCallback? onTap;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) => Material(
    color: onPrimary
        ? AppColors.transparent
        : warning
        ? AppColors.warningSoft
        : AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        height: MediaQuery.textScalerOf(context).scale(1) >= 1.2
            ? AppSpacing.homeStatLargeTextHeight
            : AppSpacing.homeStatHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (onPrimary ? AppText.statNumber : AppText.metric)
                    .copyWith(
                      color: onPrimary
                          ? AppColors.surface
                          : AppColors.textTitle,
                    ),
              ),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: AppText.label.copyWith(
                  fontSize: AppText.label.fontSize! - AppSpacing.xs / 2,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
