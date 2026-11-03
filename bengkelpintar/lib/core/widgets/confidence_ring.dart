import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class ConfidenceRing extends StatelessWidget {
  const ConfidenceRing({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value.clamp(0, 1) * 100).round();
    return SizedBox(
      width: AppSpacing.statusIcon + AppSpacing.sm,
      height: AppSpacing.statusIcon + AppSpacing.sm,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0, 1),
            strokeWidth: AppSpacing.sm + AppSpacing.xs / 2,
            strokeCap: StrokeCap.round,
            backgroundColor: AppColors.primarySoft,
            color: AppColors.primary,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$percent%',
              style: AppText.title.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
