import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'circle_icon_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.role,
    required this.onNotifications,
    this.stats = const [],
  });

  final String name;
  final String role;
  final VoidCallback onNotifications;
  final List<Widget> stats;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.paddingOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final firstName = name.trim().split(RegExp(r'\s+')).first;
    final initial = firstName.isEmpty ? '?' : firstName[0].toUpperCase();
    return Container(
      height:
          AppSpacing.headerH1 +
          (textScale > 1
              ? AppSpacing.homeStatLargeTextHeight - AppSpacing.homeStatHeight
              : 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusHeader),
          bottomRight: Radius.circular(AppSpacing.radiusHeader),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageMargin + media.left,
              media.top + AppSpacing.sm,
              AppSpacing.pageMargin + media.right,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: AppSpacing.circleSmall / 2,
                      backgroundColor: AppColors.primaryMuted,
                      child: Text(
                        initial,
                        style: AppText.title.copyWith(color: AppColors.surface),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.heading.copyWith(
                              color: AppColors.surface,
                            ),
                          ),
                          Text(
                            role,
                            style: AppText.body.copyWith(
                              color: AppColors.surface.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleIconButton(
                      icon: AppIcons.notifications,
                      onPressed: onNotifications,
                      tooltip: 'Notifikasi',
                      onHeader: true,
                    ),
                  ],
                ),
                if (stats.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [for (final stat in stats) Expanded(child: stat)],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
