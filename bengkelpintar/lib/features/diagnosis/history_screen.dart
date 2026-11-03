import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/blue_header.dart';

import '../../core/widgets/app_horizontal_chip_list.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/list_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../data/models/riwayat_diagnosis.dart';
import '../../services/service_interfaces.dart';
import '../../core/navigation/home_menu_config.dart';
import '../../core/role/role_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<RiwayatDiagnosis>> _future;
  int _tab = 0;
  @override
  void initState() {
    super.initState();
    _future = context.read<DiagnosisService>().listHistory();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<RoleProvider?>()?.role ?? UserRole.mechanic;
    final nav = HomeMenuConfig.bottomNavigationFor(role);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              BlueHeader(title: 'Riwayat Diagnosis', type: BlueHeaderType.h4),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.lg,
                  AppSpacing.pageMargin,
                  0,
                ),
                child: AppHorizontalChipList(
                  children: [
                    for (final filter in ['Semua', 'Hari Ini', 'Minggu Ini'])
                      AppChip(
                        label: filter,
                        selected:
                            _tab ==
                            ['Semua', 'Hari Ini', 'Minggu Ini'].indexOf(filter),
                        onSelected: (_) => setState(
                          () => _tab = [
                            'Semua',
                            'Hari Ini',
                            'Minggu Ini',
                          ].indexOf(filter),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<RiwayatDiagnosis>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LoadingSkeleton();
                    }
                    if (snap.hasError) {
                      return ErrorState(
                        message: 'Riwayat belum dapat dimuat.',
                        onRetry: () => setState(
                          () => _future = context
                              .read<DiagnosisService>()
                              .listHistory(),
                        ),
                      );
                    }
                    final list = snap.data!;
                    if (list.isEmpty) {
                      return const EmptyState(
                        title: 'Belum ada riwayat diagnosis',
                        message: 'Mulai diagnosis pertama Anda dari tombol di tengah.',
                      );
                    }
                    final now = DateTime(2026, 10, 24, 10, 15);
                    final filtered = list.where((item) {
                      if (_tab == 1) {
                        return item.waktu.year == now.year &&
                            item.waktu.month == now.month &&
                            item.waktu.day == now.day;
                      }
                      if (_tab == 2) {
                        return now.difference(item.waktu).inDays < 7;
                      }
                      return true;
                    }).toList()..sort((a, b) => b.waktu.compareTo(a.waktu));
                    if (filtered.isEmpty) {
                      return const EmptyState(
                        title: 'Belum ada riwayat diagnosis',
                        message: 'Mulai diagnosis pertama Anda dari tombol di tengah.',
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.pageMargin),
                      children: [
                        for (final item in filtered)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: ListCard(
                              title: item.hasil.kerusakanUtama.nama,
                              subtitle:
                                  '${formatTanggalIndonesia(item.waktu)} · ${item.penggunaNama}',
                              trailing: Text(
                                '${(item.keyakinan * 100).round()}%',
                                style: AppText.subheading,
                              ),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.historyDetail,
                                arguments: item,
                              ),
                              leading: const CircleIconButton(
                                icon: AppIcons.history,
                                tooltip: 'Riwayat',
                              ),
                            ),
                          ),
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
                if (route != AppRoutes.history) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
