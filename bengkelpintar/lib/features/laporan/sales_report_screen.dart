import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/app_horizontal_chip_list.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/list_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../services/service_interfaces.dart';
import '../../data/models/laporan_penjualan.dart';
import '../../core/widgets/sales_bar_chart.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});
  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  late Future<LaporanPenjualan> _future;
  String _period = '7 Hari';
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final service = context.read<LaporanService?>();
    _future = service == null
        ? Future.error(StateError('Laporan belum dapat dimuat.'))
        : service.salesReport(
            periodeMulai: '2026-10-23',
            periodeSelesai: '2026-10-24',
          );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Laporan',
          type: BlueHeaderType.h4,
          onBack: () => Navigator.maybePop(context),
          child: AppHorizontalChipList(
            children: [
              for (final period in [
                'Hari Ini',
                '7 Hari',
                'Bulan Ini',
                'Kustom',
              ])
                ChoiceChip(
                  label: Text(period),
                  selected: _period == period,
                  onSelected: (_) => setState(() {
                    _period = period;
                    _reload();
                  }),
                  selectedColor: AppColors.surface,
                  backgroundColor: AppColors.primaryOverlay,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelStyle: TextStyle(
                    color: _period == period
                        ? AppColors.primary
                        : AppColors.surface,
                  ),
                  showCheckmark: false,
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<LaporanPenjualan>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snap.hasError) {
                return ErrorState(
                  message: 'Laporan belum dapat dimuat.',
                  onRetry: () => setState(_reload),
                );
              }
              final data = snap.data!;
              return ListView(
                padding: AppSpacing.pageInsets,
                children: [
                  Card(
                    child: Padding(
                      padding: AppSpacing.cardInsets,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Penjualan',
                            style: AppText.bodySmall,
                          ),
                          Text(
                            formatRupiah(data.totalPenjualan),
                            style: AppText.poppinsDisplay.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${data.jumlahTransaksi} transaksi · rata-rata ${formatRupiah(data.rataRata)}',
                            style: AppText.body,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SalesBarChart(items: data.penjualanPerHari),
                  for (final item in data.penjualanPerHari)
                    ListCard(
                      title: item.tanggal,
                      subtitle: '${item.jumlah} transaksi',
                      trailing: Text(
                        formatRupiah(item.total),
                        style: AppText.subheading,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Produk atau Jasa Terlaris',
                    style: AppText.heading,
                  ),
                  for (final item in data.terlaris)
                    ListCard(
                      title: item.nama,
                      subtitle: '${item.jumlah} terjual',
                      trailing: Text(
                        formatRupiah(item.total),
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
