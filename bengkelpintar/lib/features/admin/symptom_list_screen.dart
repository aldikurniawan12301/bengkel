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
import '../../core/widgets/status_badge.dart';
import '../../data/models/gejala.dart';
import '../../services/service_interfaces.dart';
import '../../core/navigation/app_routes.dart';

class SymptomListScreen extends StatefulWidget {
  const SymptomListScreen({super.key});
  @override
  State<SymptomListScreen> createState() => _SymptomListScreenState();
}

class _SymptomListScreenState extends State<SymptomListScreen> {
  late Future<List<Gejala>> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = context.read<KerusakanService>().listGejala();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Daftar Gejala',
          type: BlueHeaderType.h4,
          action: CircleIconButton(
            icon: AppIcons.add,
            onHeader: true,
            tooltip: 'Tambah gejala',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.symptomForm,
            ).then((_) => setState(_reload)),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Gejala>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snap.hasError) {
                return ErrorState(
                  message: 'Gejala belum dapat dimuat.',
                  onRetry: () => setState(_reload),
                );
              }
              final list = snap.data ?? const <Gejala>[];
              if (list.isEmpty) {
                return const EmptyState(
                  title: 'Belum ada gejala',
                  message: 'Tambahkan gejala pertama.',
                );
              }
              return ListView(
                padding: AppSpacing.pageInsets,
                children: [
                  for (final item in list)
                    ListCard(
                      title: '${item.kode} · ${item.nama}',
                      subtitle: item.kategori,
                      trailing: StatusBadge(
                        status: item.aktif
                            ? AppStatus.aktif
                            : AppStatus.nonaktif,
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.symptomForm,
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
