import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_horizontal_chip_list.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/sales_bar_chart.dart';
import '../../data/models/laporan_penjualan.dart';
import '../../data/models/transaksi.dart';
import '../../services/service_interfaces.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  late Future<_ReportData> _future;
  String _period = '7 Hari';
  DateTime? _customStart;
  DateTime? _customEnd;

  // Mock data follows the reference date used by the bundled data set.
  final _today = DateTime(2026, 10, 24);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final range = _rangeForPeriod();
    final reports = context.read<LaporanService?>();
    final transactions = context.read<TransaksiService?>();
    if (reports == null || transactions == null) {
      _future = Future.error(StateError('Laporan belum dapat dimuat.'));
      return;
    }
    _future =
        Future.wait([
          reports.salesReport(
            periodeMulai: _dateValue(range.$1),
            periodeSelesai: _dateValue(range.$2),
          ),
          transactions.listTransactions(status: 'final'),
        ]).then(
          (values) => _ReportData(
            report: values[0] as LaporanPenjualan,
            transactions: (values[1] as List<Transaksi>)
                .where(
                  (item) =>
                      !item.waktu.isBefore(range.$1) &&
                      !item.waktu.isAfter(
                        range.$2.add(const Duration(days: 1)),
                      ),
                )
                .toList(),
          ),
        );
  }

  (DateTime, DateTime) _rangeForPeriod() {
    if (_customStart != null && _customEnd != null) {
      return (_dateOnly(_customStart!), _dateOnly(_customEnd!));
    }
    return switch (_period) {
      'Hari Ini' => (_today, _today),
      'Bulan Ini' => (DateTime(_today.year, _today.month, 1), _today),
      _ => (_today.subtract(const Duration(days: 6)), _today),
    };
  }

  Future<void> _pickCustomPeriod() async {
    final previous = _period;
    final start = await showDatePicker(
      context: context,
      initialDate: _customStart ?? _today,
      firstDate: DateTime(2020),
      lastDate: _today,
      helpText: 'Pilih tanggal mulai',
      confirmText: 'Lanjut',
      cancelText: 'Batal',
    );
    if (!mounted || start == null) return;
    final end = await showDatePicker(
      context: context,
      initialDate: _customEnd != null && !_customEnd!.isBefore(start)
          ? _customEnd!
          : start,
      firstDate: start,
      lastDate: _today,
      helpText: 'Pilih tanggal selesai',
      confirmText: 'Selesai',
      cancelText: 'Batal',
    );
    if (!mounted || end == null || end.isBefore(start)) {
      setState(() => _period = previous);
      return;
    }
    setState(() {
      _customStart = start;
      _customEnd = end;
      _period = 'Kustom';
      _reload();
    });
  }

  void _selectPeriod(String period) {
    if (period == 'Kustom') {
      _pickCustomPeriod();
      return;
    }
    setState(() {
      _period = period;
      _customStart = null;
      _customEnd = null;
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Laporan',
          type: BlueHeaderType.h4,
          onBack: () => Navigator.maybePop(context),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: AppHorizontalChipList(
            children: [
              for (final period in [
                'Hari Ini',
                '7 Hari',
                'Bulan Ini',
                _customLabel,
              ])
                AppChip(
                  label: period,
                  selected:
                      _period == period ||
                      (period == 'Kustom' && _customStart != null),
                  onSelected: (_) =>
                      _selectPeriod(period == _customLabel ? 'Kustom' : period),
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<_ReportData>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snap.hasError || snap.data == null) {
                return ErrorState(
                  message: 'Laporan belum dapat dimuat.',
                  onRetry: () => setState(_reload),
                );
              }
              return _ReportContent(data: snap.data!);
            },
          ),
        ),
      ],
    ),
  );

  String get _customLabel => _customStart == null || _customEnd == null
      ? 'Kustom'
      : '${_customStart!.day}-${_customEnd!.day} ${_month(_customEnd!.month)}';

  String _dateValue(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _month(int month) => const [
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
  ][month - 1];
}

class _ReportData {
  const _ReportData({required this.report, required this.transactions});
  final LaporanPenjualan report;
  final List<Transaksi> transactions;
}

class _ReportContent extends StatefulWidget {
  const _ReportContent({required this.data});
  final _ReportData data;

  @override
  State<_ReportContent> createState() => _ReportContentState();
}

class _ReportContentState extends State<_ReportContent> {
  String _bestSellerType = 'Produk';

  @override
  Widget build(BuildContext context) {
    final report = widget.data.report;
    final products = report.terlaris
        .where((item) => item.tipe == 'produk')
        .toList();
    final services = report.terlaris
        .where((item) => item.tipe == 'jasa')
        .toList();
    final best = (_bestSellerType == 'Produk' ? products : services)
        .take(5)
        .toList();
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: AppInsets.page(
        context,
        top: AppSpacing.lg,
        bottom: AppInsets.bottom(context, extra: AppSpacing.xl),
      ),
      children: [
        _TotalCard(report: report),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Transaksi',
                value: '${report.jumlahTransaksi}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetricCard(
                label: 'Rata-rata',
                value: formatRupiah(report.rataRata),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (report.penjualanPerHari.isEmpty)
          const _SectionEmpty(
            title: 'Penjualan per Hari',
            message: 'Belum ada penjualan pada periode ini.',
          )
        else
          SalesBarChart(items: report.penjualanPerHari),
        const SizedBox(height: AppSpacing.lg),
        const Text('Daftar Transaksi Final', style: AppText.heading),
        const SizedBox(height: AppSpacing.md),
        if (widget.data.transactions.isEmpty)
          const _SectionEmpty(
            title: 'Daftar Transaksi Final',
            message: 'Belum ada transaksi final pada periode ini.',
          )
        else
          for (final group in _groupTransactions(
            widget.data.transactions,
          ).entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(group.key, style: AppText.bodySmall),
            ),
            for (final transaction in group.value) ...[
              _FinalTransactionCard(transaction: transaction),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Expanded(child: Text('Terlaris', style: AppText.heading)),
            AppChip(
              label: 'Produk',
              selected: _bestSellerType == 'Produk',
              onSelected: (_) => setState(() => _bestSellerType = 'Produk'),
            ),
            const SizedBox(width: AppSpacing.xs),
            AppChip(
              label: 'Jasa',
              selected: _bestSellerType == 'Jasa',
              onSelected: (_) => setState(() => _bestSellerType = 'Jasa'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (best.isEmpty)
          const _SectionEmpty(
            title: 'Terlaris',
            message: 'Belum ada data terlaris.',
          )
        else
          for (var index = 0; index < best.length; index++)
            _BestSellerRow(rank: index + 1, item: best[index]),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.report});
  final LaporanPenjualan report;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.gradientEnd],
      ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    ),
    child: Padding(
      padding: AppSpacing.cardInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Penjualan',
            style: AppText.bodySmall.copyWith(color: AppColors.surface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(formatRupiah(report.totalPenjualan), style: AppText.statNumber),
          const SizedBox(height: AppSpacing.xs),
          Text(
            report.totalPenjualan == 0
                ? 'Belum ada perbandingan periode.'
                : 'Periode terpilih',
            style: AppText.bodySmall.copyWith(color: AppColors.primaryMuted),
          ),
        ],
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
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
          Text(label, style: AppText.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppText.subheading,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class _FinalTransactionCard extends StatelessWidget {
  const _FinalTransactionCard({required this.transaction});
  final Transaksi transaction;

  @override
  Widget build(BuildContext context) {
    final time =
        '${transaction.waktu.hour.toString().padLeft(2, '0')}:${transaction.waktu.minute.toString().padLeft(2, '0')}';
    final customer = transaction.platNomor.trim().isEmpty
        ? transaction.namaPelanggan
        : '${transaction.platNomor} · ${transaction.namaPelanggan}';
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.transactionDetail,
          arguments: transaction,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer,
                      style: AppText.subheading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${transaction.nomor} · $time',
                      style: AppText.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formatRupiah(transaction.total),
                style: AppText.transactionAmount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BestSellerRow extends StatelessWidget {
  const _BestSellerRow({required this.rank, required this.item});
  final int rank;
  final Terlaris item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SizedBox(width: 24, child: Text('$rank', style: AppText.heading)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: AppText.subheading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${item.jumlah} terjual', style: AppText.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(formatRupiah(item.total), style: AppText.subheading),
          ],
        ),
      ),
    ),
  );
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    child: Padding(
      padding: AppSpacing.cardInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: AppText.bodySmall),
        ],
      ),
    ),
  );
}

Map<String, List<Transaksi>> _groupTransactions(List<Transaksi> items) {
  final sorted = List<Transaksi>.of(items)
    ..sort((a, b) => b.waktu.compareTo(a.waktu));
  final groups = <String, List<Transaksi>>{};
  for (final item in sorted) {
    final label =
        '${item.waktu.day} ${_monthName(item.waktu.month)} ${item.waktu.year}';
    groups.putIfAbsent(label, () => []).add(item);
  }
  return groups;
}

String _monthName(int month) => const [
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
][month - 1];
