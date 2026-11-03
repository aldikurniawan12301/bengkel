import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class PercentageBar extends StatelessWidget {
  const PercentageBar({super.key, required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppText.body)),
              Text('${(value * 100).round()}%', style: AppText.subheading),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: AppSpacing.xs + AppSpacing.borderWidth * 2,
              color: AppColors.primary,
              backgroundColor: AppColors.primarySoft,
            ),
          ),
        ],
      ),
    );
  }
}
