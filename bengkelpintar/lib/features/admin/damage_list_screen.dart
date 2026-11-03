import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/list_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/urgensi_badge.dart';
import '../../data/models/kerusakan.dart';
import '../../services/service_interfaces.dart';
import '../../core/navigation/app_routes.dart';

class DamageListScreen extends StatefulWidget {
  const DamageListScreen({super.key});
  @override
  State<DamageListScreen> createState() => _DamageListScreenState();
}

class _DamageListScreenState extends State<DamageListScreen> {
  late Future<List<Kerusakan>> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = context.read<KerusakanService>().listKerusakan();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Daftar Kerusakan',
          type: BlueHeaderType.h4,
          action: CircleIconButton(
            icon: AppIcons.add,
            onHeader: true,
            tooltip: 'Tambah kerusakan',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.damageForm,
            ).then((_) => setState(_reload)),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Kerusakan>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snap.hasError) {
                return ErrorState(
                  message: 'Kerusakan belum dapat dimuat.',
                  onRetry: () => setState(_reload),
                );
              }
              final list = snap.data ?? const <Kerusakan>[];
              if (list.isEmpty) {
                return const EmptyState(
                  title: 'Belum ada kerusakan',
                  message: 'Tambahkan kerusakan pertama.',
                );
              }
              return ListView(
                padding: AppSpacing.pageInsets,
                children: [
                  for (final item in list)
                    ListCard(
                      title: '${item.kode} · ${item.nama}',
                      subtitle:
                          '${item.komponenTerkait.length} komponen terkait',
                      trailing: UrgensiBadge(
                        level: switch (item.urgensi) {
                          'tinggi' => Urgensi.tinggi,
                          'rendah' => Urgensi.rendah,
                          _ => Urgensi.sedang,
                        },
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.damageForm,
                        arguments: item,
                      ).then((_) => setState(_reload)),
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
