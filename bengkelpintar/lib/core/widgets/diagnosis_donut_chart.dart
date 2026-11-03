import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class DiagnosisDonutChart extends StatelessWidget {
  const DiagnosisDonutChart({super.key, required this.values});
  final Map<String, int> values;
  @override
  Widget build(BuildContext context) {
    final total = values.values.fold<int>(0, (sum, item) => sum + item);
    final colors = [
      AppColors.primary,
      AppColors.primaryDark,
      AppColors.lightBlue,
      AppColors.success,
      AppColors.warning,
      AppColors.border,
    ];
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          children: [
            SizedBox(
              height: AppSpacing.headerH2,
              child: CustomPaint(
                painter: _DonutPainter(
                  values: values,
                  total: total,
                  colors: colors,
                ),
                child: Center(
                  child: Text(
                    '$total\ndiagnosis',
                    textAlign: TextAlign.center,
                    style: AppText.title,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < values.entries.length; i++)
              Builder(
                builder: (context) {
                  final entry = values.entries.elementAt(i);
                  return Row(
                    children: [
                      Container(
                        width: AppSpacing.sm,
                        height: AppSpacing.sm,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(entry.key, style: AppText.body)),
                      Text(
                        '${total == 0 ? 0 : (entry.value / total * 100).round()}%',
                        style: AppText.subheading,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.values,
    required this.total,
    required this.colors,
  });
  final Map<String, int> values;
  final int total;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - AppSpacing.lg;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values.values.elementAt(i) / total * math.pi * 2;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSpacing.lg
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values;
}
