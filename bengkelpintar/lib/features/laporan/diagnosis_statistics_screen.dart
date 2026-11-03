import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/list_card.dart';
import '../../core/widgets/diagnosis_donut_chart.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../services/service_interfaces.dart';
import '../../data/models/statistik_diagnosis.dart';

class DiagnosisStatisticsScreen extends StatefulWidget {
  const DiagnosisStatisticsScreen({super.key});
  @override
  State<DiagnosisStatisticsScreen> createState() =>
      _DiagnosisStatisticsScreenState();
}

class _DiagnosisStatisticsScreenState extends State<DiagnosisStatisticsScreen> {
  late Future<StatistikDiagnosis> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = context.read<DiagnosisService>().getStatistics();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const BlueHeader(
            title: 'Statistik Diagnosis',
            type: BlueHeaderType.h4,
          ),
          Expanded(
            child: FutureBuilder<StatistikDiagnosis>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingSkeleton();
                }
                if (snap.hasError) {
                  return ErrorState(
                    message: 'Statistik diagnosis belum dapat dimuat.',
                    onRetry: () => setState(_reload),
                  );
                }
                final data = snap.data!;
                if (data.items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada statistik diagnosis.',
                      style: AppText.body,
                    ),
                  );
                }
                return ListView(
                  padding: AppSpacing.pageInsets,
                  children: [
                    DiagnosisDonutChart(
                      values: {
                        for (final item in data.items) item.nama: item.jumlah,
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    for (final entry in data.items)
                      ListCard(
                        title: entry.nama,
                        subtitle: '${entry.jumlah} diagnosis',
                        trailing: Text(
                          '${(entry.persentase * 100).round()}%',
                          style: AppText.subheading,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
