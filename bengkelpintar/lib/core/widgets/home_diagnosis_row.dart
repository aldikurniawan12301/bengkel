import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'urgensi_badge.dart';

class HomeDiagnosisRow extends StatelessWidget {
  const HomeDiagnosisRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.urgency,
    required this.onTap,
    this.showDivider = false,
  });

  final String title;
  final String subtitle;
  final Urgensi urgency;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final (color, soft) = switch (urgency) {
      Urgensi.rendah => (AppColors.success, AppColors.successSoft),
      Urgensi.sedang => (AppColors.warning, AppColors.warningSoft),
      Urgensi.tinggi => (AppColors.danger, AppColors.dangerSoft),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.homeDiagnosisCardPadding,
              vertical: AppSpacing.homeDiagnosisCardPadding,
            ),
            child: Row(
              children: [
                Container(
                  width: AppSpacing.homeDiagnosisIcon,
                  height: AppSpacing.homeDiagnosisIcon,
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    AppIcons.buildCircleRounded,
                    color: color,
                    size: AppSpacing.icon,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.homeDiagnosisTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                UrgensiBadge(level: urgency),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  AppIcons.chevronRight,
                  color: AppColors.textMuted,
                  size: AppSpacing.icon,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent:
                AppSpacing.homeDiagnosisCardPadding +
                AppSpacing.homeDiagnosisIcon +
                AppSpacing.md,
            endIndent: AppSpacing.homeDiagnosisCardPadding,
          ),
      ],
    );
  }
}
