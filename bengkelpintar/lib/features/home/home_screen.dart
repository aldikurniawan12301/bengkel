import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/navigation/home_menu_config.dart';
import '../../core/role/role_provider.dart';
import '../pos/cashier_screen.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_search_bar.dart';
import '../../core/widgets/app_horizontal_chip_list.dart';

import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/home_diagnosis_row.dart';
import '../../core/widgets/home_header.dart';
import '../../core/widgets/home_stat_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/urgensi_badge.dart';
import '../../services/service_interfaces.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.role});

  final UserRole? role;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _latest;
  late Future<_HomeSummary> _summary;

  @override
  void initState() {
    super.initState();
    _latest = _loadLatest();
    _summary = _loadSummary();
  }

  Future<List<dynamic>> _loadLatest() async {
    final service = context.read<DiagnosisService?>();
    if (service == null) return [];
    final history = await service.listHistory();
    return history.take(3).toList();
  }

  Future<_HomeSummary> _loadSummary() async {
    final diagnosisService = context.read<DiagnosisService?>();
    final transactionService = context.read<TransaksiService?>();
    final productService = context.read<ProdukService?>();
    final histories = diagnosisService == null
        ? <dynamic>[]
        : await diagnosisService.listHistory();
    final transactions = transactionService == null
        ? []
        : await transactionService.listTransactions();
    final products = productService == null
        ? []
        : await productService.listProducts();
    return _HomeSummary(
      diagnosisCount: histories.length,
      draftCount: transactions.where((item) => item.status == 'draft').length,
      finalCount: transactions.where((item) => item.status == 'final').length,
      lowStockCount: products
          .where((item) => item.aktif && item.stok <= item.stokMinimum)
          .length,
    );
  }

  void _open(String route, {Object? arguments}) =>
      Navigator.pushNamed(context, route, arguments: arguments);

  @override
  Widget build(BuildContext context) {
    final role =
        widget.role ??
        context.watch<RoleProvider?>()?.role ??
        UserRole.mechanic;
    final admin = role == UserRole.admin;
    final nav = HomeMenuConfig.bottomNavigationFor(role);
    final name = admin ? 'Andi Pratama' : 'Budi Santoso';
    final menus = [
      ('Katalog', AppRoutes.productCatalog, AppIcons.inventory),
      ('Laporan', AppRoutes.reports, AppIcons.barChart),
      ('Gejala dan kerusakan', AppRoutes.dataMaster, AppIcons.factCheckRounded),
      ('Pengguna', AppRoutes.manageUsers, AppIcons.roundedPerson),
      ('Kategori', AppRoutes.categoryList, AppIcons.category),
      ('Pengaturan', AppRoutes.workshopSettings, AppIcons.settings),
    ];
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              FutureBuilder<_HomeSummary>(
                future: _summary,
                builder: (context, snapshot) {
                  final summary = snapshot.data ?? const _HomeSummary();
                  final values = admin
                      ? [
                          (
                            summary.diagnosisCount,
                            'Diagnosis',
                            AppIcons.analytics,
                            AppRoutes.diagnosis,
                          ),
                          (
                            summary.draftCount,
                            'Draft',
                            AppIcons.description,
                            AppRoutes.transactions,
                          ),
                          (
                            summary.finalCount,
                            'Final',
                            AppIcons.receiptLong,
                            AppRoutes.transactions,
                          ),
                          (
                            summary.lowStockCount,
                            'Stok menipis',
                            AppIcons.inventory,
                            AppRoutes.productCatalog,
                          ),
                        ]
                      : [
                          (
                            summary.diagnosisCount,
                            'Diagnosis',
                            AppIcons.analytics,
                            AppRoutes.diagnosis,
                          ),
                          (
                            summary.draftCount,
                            'Draft Saya',
                            AppIcons.description,
                            AppRoutes.cashier,
                          ),
                          (
                            summary.finalCount,
                            'Final',
                            AppIcons.receiptLong,
                            AppRoutes.transactions,
                          ),
                          (
                            summary.diagnosisCount,
                            'Riwayat',
                            AppIcons.history,
                            AppRoutes.history,
                          ),
                        ];
                  return HomeHeader(
                    name: name,
                    role: admin ? 'Admin' : 'Mekanik',
                    onNotifications: () => ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            content: Text('Belum ada notifikasi baru.'),
                          ),
                        ),
                    stats: [
                      for (final value in values)
                        HomeStatCard(
                          value: '${value.$1}',
                          label: value.$2,
                          icon: value.$3,
                          onPrimary: true,
                          onTap: () => _open(value.$4),
                        ),
                    ],
                  );
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      setState(() => _latest = _loadLatest()),
                  child: ListView(
                    padding: AppInsets.page(
                      context,
                      top: AppSpacing.lg,
                      bottom:
                          AppSpacing.bottomBarClearance +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      const AppSearchBar(hintText: 'Cari pelanggan atau plat'),
                      const SizedBox(height: AppSpacing.lg),
                      const Text('Aksi cepat', style: AppText.heading),
                      const SizedBox(height: AppSpacing.sm),
                      _HomeCard(
                        children: [
                          _ActionRow(
                            label: 'Transaksi Baru',
                            icon: AppIcons.addRounded,
                            color: AppColors.primary,
                            showDivider: false,
                            onTap: () => _open(
                              AppRoutes.cashier,
                              arguments: const CashierEntry(clear: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (admin) ...[
                        const Text('Perlu tindakan', style: AppText.heading),
                        const SizedBox(height: AppSpacing.sm),
                        FutureBuilder<_HomeSummary>(
                          future: _summary,
                          builder: (context, snapshot) {
                            final summary = snapshot.data;
                            if (summary == null) return const SizedBox.shrink();
                            final actions = <Widget>[
                              if (summary.draftCount > 0)
                                _ActionRow(
                                  label: 'draft menunggu finalisasi',
                                  count: summary.draftCount,
                                  icon: AppIcons.description,
                                  color: AppColors.primary,
                                  showDivider: summary.lowStockCount > 0,
                                  onTap: () => _open(AppRoutes.transactions),
                                ),
                              if (summary.lowStockCount > 0)
                                _ActionRow(
                                  label: 'produk stok menipis',
                                  count: summary.lowStockCount,
                                  icon: AppIcons.inventory,
                                  color: AppColors.warning,
                                  showDivider: false,
                                  onTap: () => _open(AppRoutes.productCatalog),
                                ),
                            ];
                            return _HomeCard(
                              children: actions.isEmpty
                                  ? const [
                                      Text(
                                        'Tidak ada yang perlu ditindaklanjuti',
                                        style: AppText.body,
                                      ),
                                    ]
                                  : actions,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text('Menu lain', style: AppText.heading),
                        const SizedBox(height: AppSpacing.sm),
                        AppHorizontalChipList(
                          children: [
                            for (final menu in menus)
                              _MenuTile(
                                label: menu.$1,
                                icon: menu.$3,
                                onTap: () => _open(menu.$2),
                              ),
                          ],
                        ),
                      ] else ...[
                        const Text('Draft saya', style: AppText.heading),
                        const SizedBox(height: AppSpacing.sm),
                        _ActionRow(
                          label: 'Lihat draft saya',
                          showDivider: false,
                          onTap: () => _open(AppRoutes.transactions),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Diagnosis terbaru',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.heading,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _open(AppRoutes.history),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Lihat semua'),
                          ),
                        ],
                      ),
                      FutureBuilder<List<dynamic>>(
                        future: _latest,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Column(
                              children: [
                                LoadingSkeleton(
                                  height: AppSpacing.homeDiagnosisIcon,
                                ),
                                SizedBox(height: AppSpacing.sm),
                                LoadingSkeleton(
                                  height: AppSpacing.homeDiagnosisIcon,
                                ),
                              ],
                            );
                          }
                          if (snapshot.hasError) {
                            return ErrorState(
                              message: 'Data diagnosis belum dapat dimuat.',
                              onRetry: () =>
                                  setState(() => _latest = _loadLatest()),
                            );
                          }
                          final items = snapshot.data ?? const <dynamic>[];
                          if (items.isEmpty) {
                            return const EmptyState(
                              title: 'Belum ada diagnosis terbaru',
                              message: 'Mulai diagnosis pertama Anda dari tombol di atas.',
                            );
                          }
                          return _HomeCard(
                            children: [
                              for (
                                var index = 0;
                                index < items.take(3).length;
                                index++
                              )
                                HomeDiagnosisRow(
                                  showDivider: index < items.take(3).length - 1,
                                  title: items[index].hasil.kerusakanUtama.nama,
                                  subtitle:
                                      '${items[index].penggunaNama} · ${_formatTime(items[index].waktu)}',
                                  urgency: _urgency(items[index].hasil.urgensi),
                                  onTap: () => _open(
                                    AppRoutes.historyDetail,
                                    arguments: items[index],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavBar(
              items: [for (final item in nav) item.label],
              selectedIndex: 0,
              compact: true,
              onSelected: (index) => _open(nav[index].route),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Urgensi _urgency(String value) => switch (value.toLowerCase()) {
    'rendah' => Urgensi.rendah,
    'tinggi' => Urgensi.tinggi,
    _ => Urgensi.sedang,
  };
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.onTap,
    this.count,
    this.icon,
    this.color,
    this.showDivider = false,
  });

  final String label;
  final VoidCallback onTap;
  final int? count;
  final IconData? icon;
  final Color? color;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (icon != null)
                Container(
                  width: AppSpacing.homeActionIcon,
                  height: AppSpacing.homeActionIcon,
                  decoration: BoxDecoration(
                    color: color == AppColors.warning
                        ? AppColors.warningSoft
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(icon, color: color, size: AppSpacing.icon),
                ),
              if (icon != null) const SizedBox(width: AppSpacing.md),
              if (count != null)
                Text('$count', style: AppText.homeDiagnosisTitle),
              if (count != null) const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(label, style: AppText.body)),
              const Icon(AppIcons.chevronRight, size: AppSpacing.iconSmall),
            ],
          ),
        ),
      ),
      if (showDivider)
        const Divider(
          height: 1,
          thickness: 1,
          indent:
              AppSpacing.cardPadding +
              AppSpacing.homeActionIcon +
              AppSpacing.md,
          endIndent: AppSpacing.cardPadding,
        ),
    ],
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    child: SizedBox(
      width: AppSpacing.homeWorkItemWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.homeWorkIcon,
              height: AppSpacing.homeWorkIcon,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.icon,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: AppSpacing.homeWorkLabelHeight,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppText.label,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeSummary {
  const _HomeSummary({
    this.diagnosisCount = 0,
    this.draftCount = 0,
    this.finalCount = 0,
    this.lowStockCount = 0,
  });

  final int diagnosisCount;
  final int draftCount;
  final int finalCount;
  final int lowStockCount;
}
