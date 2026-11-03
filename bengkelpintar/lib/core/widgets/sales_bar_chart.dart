import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../../data/models/laporan_penjualan.dart';
import '../utils/formatters.dart';

class SalesBarChart extends StatelessWidget {
  const SalesBarChart({super.key, required this.items});
  final List<PenjualanPerHari> items;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.fold<int>(
      0,
      (max, item) => item.total > max ? item.total : max,
    );
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Penjualan per Hari', style: AppText.heading),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: AppSpacing.headerH2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final item in items)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              formatRupiah(item.total),
                              style: AppText.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Flexible(
                              child: FractionallySizedBox(
                                heightFactor: maxValue == 0
                                    ? 0
                                    : item.total / maxValue,
                                alignment: Alignment.bottomCenter,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              item.tanggal.length >= 3
                                  ? item.tanggal.substring(0, 3)
                                  : item.tanggal,
                              style: AppText.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
