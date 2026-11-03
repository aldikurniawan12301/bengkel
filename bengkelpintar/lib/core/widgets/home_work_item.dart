import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class HomeWorkItem extends StatelessWidget {
  const HomeWorkItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: AppSpacing.homeWorkItemWidth,
        child: Column(
          children: [
            Container(
              width: AppSpacing.homeWorkIcon,
              height: AppSpacing.homeWorkIcon,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.icon,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: AppSpacing.homeWorkLabelHeight,
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: AppText.bodySmall.copyWith(color: AppColors.textTitle),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
