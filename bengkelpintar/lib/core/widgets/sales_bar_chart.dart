import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../../data/models/laporan_penjualan.dart';
import '../utils/formatters.dart';

class SalesBarChart extends StatefulWidget {
  const SalesBarChart({super.key, required this.items});
  final List<PenjualanPerHari> items;

  @override
  State<SalesBarChart> createState() => _SalesBarChartState();
}

class _SalesBarChartState extends State<SalesBarChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final maxValue = widget.items.fold<int>(
      0,
      (max, item) => item.total > max ? item.total : max,
    );
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Penjualan per Hari', style: AppText.heading),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _ChartGridPainter(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < widget.items.length; index++)
                      Expanded(
                        child: _Bar(
                          item: widget.items[index],
                          maxValue: maxValue,
                          selected: _selected == index,
                          onTap: () => setState(() => _selected = index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.item,
    required this.maxValue,
    required this.selected,
    required this.onTap,
  });
  final PenjualanPerHari item;
  final int maxValue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final factor = maxValue == 0 ? 0.0 : item.total / maxValue;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: formatRupiah(item.total),
              child: Text(
                _compactRupiah(item.total),
                style: AppText.bodySmall.copyWith(
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: factor == 0 ? 0.015 : factor.clamp(0.015, 1),
                  widthFactor: 0.62,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.72),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _shortDate(item.tanggal),
              style: AppText.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (final fraction in [0.25, 0.5, 0.75]) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _shortDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.length > 6 ? value.substring(0, 6) : value;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${parsed.day} ${months[parsed.month - 1]}';
}

String _compactRupiah(int value) {
  if (value >= 1000000) return 'Rp${(value / 1000000).toStringAsFixed(1)}jt';
  if (value >= 1000) return 'Rp${(value / 1000).round()}rb';
  return formatRupiah(value);
}
