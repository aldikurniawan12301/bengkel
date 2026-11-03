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
      width: AppSpacing.confidenceRingSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppSpacing.confidenceRingSize,
            height: AppSpacing.confidenceRingSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value.clamp(0, 1),
                  strokeWidth: AppSpacing.confidenceRingStroke,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.primarySoft,
                  color: AppColors.primary,
                ),
                Text.rich(
                  TextSpan(
                    text: '$percent',
                    style: AppText.heading.copyWith(
                      color: AppColors.textTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: '%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
          const Text('Yakin', style: AppText.bodySmall),
        ],
      ),
    );
  }
}
