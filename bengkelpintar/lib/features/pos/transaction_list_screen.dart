import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_search_bar.dart';
import '../../core/widgets/app_horizontal_chip_list.dart';

import '../../core/widgets/blue_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/navigation/home_menu_config.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../data/models/transaksi.dart';
import '../../services/service_interfaces.dart';
import '../../core/role/role_provider.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<Transaksi>> _future;
  late Future<List<Transaksi>> _allTransactions;
  String _query = '';
  String? _status;

  @override
  void initState() {
    super.initState();
    _reload();
    _allTransactions = context.read<TransaksiService>().listTransactions();
  }

  void _reload() {
    _future = context.read<TransaksiService>().listTransactions(
      query: _query,
      status: _status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<RoleProvider?>()?.role ?? UserRole.admin;
    final nav = HomeMenuConfig.bottomNavigationFor(role);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              BlueHeader(
                title: context.read<RoleProvider?>()?.role == UserRole.mechanic
                    ? 'Draft Saya'
                    : 'Transaksi',
                type: BlueHeaderType.h4,
                action: CircleIconButton(
                  icon: AppIcons.addRounded,
                  medium: true,
                  onHeader: true,
                  tooltip: 'Transaksi baru',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.draft),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.lg,
                  AppSpacing.pageMargin,
                  0,
                ),
                child: Column(
                  children: [
                    AppSearchBar(
                      hintText: 'Cari pelanggan atau plat',
                      onChanged: (value) => setState(() {
                        _query = value;
                        _reload();
                      }),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton.primary(
                      label: 'Transaksi Baru',
                      icon: AppIcons.addRounded,
                      height: AppSpacing.inputHeight,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.draft),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FutureBuilder<List<Transaksi>>(
                      future: _allTransactions,
                      builder: (context, snapshot) {
                        final all = snapshot.data ?? const <Transaksi>[];
                        return AppHorizontalChipList(
                          children: [
                            for (final filter in [
                              (label: 'Semua', value: null),
                              if (role == UserRole.admin)
                                (label: 'Draft', value: 'draft'),
                              if (role == UserRole.admin)
                                (label: 'Final', value: 'final'),
                            ])
                              AppChip(
                                label:
                                    '${filter.label} ${filter.value == null ? all.length : all.where((item) => item.status == filter.value).length}',
                                selected: _status == filter.value,
                                onSelected: (_) => setState(() {
                                  _status = filter.value;
                                  _reload();
                                }),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Transaksi>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingSkeleton();
                    }
                    if (snapshot.hasError) {
                      return ErrorState(
                        message: 'Transaksi belum dapat dimuat.',
                        onRetry: () => setState(_reload),
                      );
                    }
                    final items = snapshot.data ?? const <Transaksi>[];
                    if (_allTransactions == _future) {
                      _allTransactions = Future.value(items);
                    }
                    if (items.isEmpty) {
                      return EmptyState(
                        title: _status == null
                            ? 'Belum ada transaksi'
                            : 'Belum ada transaksi ${_status == 'draft' ? 'draft' : 'final'}',
                        message: 'Transaksi akan muncul setelah draft dibuat.',
                      );
                    }
                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.pageMargin,
                        AppSpacing.pageMargin,
                        AppSpacing.pageMargin,
                        AppSpacing.bottomBarClearance +
                            MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        for (final group in _groupByDate(items).entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Text(group.key, style: AppText.bodySmall),
                          ),
                          for (final item in group.value)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.transactionCardGap,
                              ),
                              child: _TransactionCard(transaction: item),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavBar(
              items: [for (final item in nav) item.label],
              selectedIndex: 1,
              onSelected: (index) {
                final route = nav[index].route;
                if (route != AppRoutes.transactions) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Transaksi>> _groupByDate(List<Transaksi> transactions) {
    final sorted = [...transactions]
      ..sort((a, b) => b.waktu.compareTo(a.waktu));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<Transaksi>>{};
    for (final item in sorted) {
      final day = DateTime(item.waktu.year, item.waktu.month, item.waktu.day);
      final label = day == today
          ? 'Hari ini'
          : day == yesterday
          ? 'Kemarin'
          : formatTanggalIndonesia(item.waktu).split(',').first;
      groups.putIfAbsent(label, () => []).add(item);
    }
    return groups;
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});
  final Transaksi transaction;

  @override
  Widget build(BuildContext context) {
    final draft = transaction.status == 'draft';
    final time =
        '${transaction.waktu.hour.toString().padLeft(2, '0')}:${transaction.waktu.minute.toString().padLeft(2, '0')}';
    final shortName = transaction.dibuatOleh.split(' ').take(2).join(' ');
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
          draft ? AppRoutes.draft : AppRoutes.transactionDetail,
          arguments: transaction,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.transactionCardHeight,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: AppSpacing.transactionDraftInset,
                  color: draft ? AppColors.warning : AppColors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                transaction.platNomor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.homeDiagnosisTitle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            StatusBadge(
                              status: draft
                                  ? AppStatus.draft
                                  : AppStatus.finalised,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                '${transaction.namaPelanggan} · ${transaction.items.length} item',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              formatRupiah(transaction.total),
                              style: AppText.transactionAmount,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${transaction.nomor} · $time · $shortName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
