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
import '../../services/service_interfaces.dart';
import '../../data/models/user.dart';
import '../../core/navigation/app_routes.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = context.read<PenggunaService>().listUsers();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Kelola Pengguna',
          type: BlueHeaderType.h4,
          action: CircleIconButton(
            icon: AppIcons.add,
            onHeader: true,
            tooltip: 'Tambah pengguna',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.userForm,
            ).then((_) => setState(_reload)),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<User>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snap.hasError) {
                return ErrorState(
                  message: 'Pengguna belum dapat dimuat.',
                  onRetry: () => setState(_reload),
                );
              }
              final list = snap.data ?? const <User>[];
              if (list.isEmpty) {
                return const EmptyState(
                  title: 'Belum ada pengguna',
                  message: 'Tambahkan pengguna pertama.',
                );
              }
              return ListView(
                padding: AppSpacing.pageInsets,
                children: [
                  for (final item in list)
                    ListCard(
                      title: item.nama,
                      subtitle: '${item.username ?? '-'} · ${item.peran}',
                      trailing: Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          StatusBadge(
                            status: item.aktif == true
                                ? AppStatus.aktif
                                : AppStatus.nonaktif,
                          ),
                          IconButton(
                            icon: const Icon(AppIcons.lockReset),
                            tooltip: 'Reset Password',
                            onPressed: item.username == null
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.resetPassword,
                                    arguments: item,
                                  ),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.userForm,
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
