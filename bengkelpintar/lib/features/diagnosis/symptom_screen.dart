import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_horizontal_chip_list.dart';

import '../../core/widgets/app_search_bar.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/check_list_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/models/gejala.dart';
import '../../services/service_interfaces.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});
  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  late Future<List<Gejala>> _future;
  final _selected = <int>{};
  String _query = '';
  String _category = 'Semua';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Gejala>> _load() => context.read<KerusakanService>().listGejala();
  Future<void> _diagnose() async {
    if (_selected.isEmpty) return;
    final result = await context.read<DiagnosisService>().diagnose(
      _selected.toList(),
    );
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hasil diagnosis belum tersedia.')),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.diagnosis, arguments: result);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BlueHeader(
            title: 'Pilih Gejala',
            type: BlueHeaderType.h2,
            onBack: () => Navigator.maybePop(context),
            action: _selected.isEmpty
                ? null
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                    child: Text(
                      '${_selected.length} dipilih',
                      style: AppText.label.copyWith(color: AppColors.surface),
                    ),
                  ),
          ),
          Expanded(
            child: FutureBuilder<List<Gejala>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: AppSpacing.pageInsets,
                    child: LoadingSkeleton(),
                  );
                }
                if (snap.hasError) {
                  return ErrorState(
                    message: 'Data gejala belum dapat dimuat.',
                    onRetry: () => setState(() => _future = _load()),
                  );
                }
                final items = snap.data!
                    .where(
                      (g) =>
                          g.aktif &&
                          (_category == 'Semua' || g.kategori == _category) &&
                          '${g.kode} ${g.nama}'.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                    )
                    .toList();
                return ListView(
                  padding: AppInsets.page(
                    context,
                    top: AppSpacing.lg,
                    bottom: AppSpacing.xl,
                  ),
                  children: [
                    AppSearchBar(
                      hintText: 'Cari gejala ...',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppHorizontalChipList(
                      children: [
                        for (final category in [
                          'Semua',
                          'Mesin',
                          'Kelistrikan',
                          'Rem',
                          'Transmisi',
                        ])
                          AppChip(
                            label: category,
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (items.isEmpty)
                      const EmptyState(
                        title: 'Tidak ditemukan',
                        message: 'Coba kata kunci lain.',
                        icon: AppIcons.searchOff,
                      )
                    else ...[
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CheckListItem(
                            title: item.nama,
                            subtitle: item.kode,
                            value: _selected.contains(item.id),
                            onChanged: (_) => setState(
                              () => _selected.contains(item.id)
                                  ? _selected.remove(item.id)
                                  : _selected.add(item.id),
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
          AppBottomActionBar(
            info: Text('${_selected.length} dipilih', style: AppText.body),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton.primary(
                  label: 'Diagnosis',
                  expand: false,
                  onPressed: _selected.isEmpty ? null : _diagnose,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
