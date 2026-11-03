import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/floating_action_bar.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../data/models/pengaturan_bengkel.dart';
import '../../services/service_interfaces.dart';

class WorkshopSettingsScreen extends StatefulWidget {
  const WorkshopSettingsScreen({super.key});
  @override
  State<WorkshopSettingsScreen> createState() => _WorkshopSettingsScreenState();
}

class _WorkshopSettingsScreenState extends State<WorkshopSettingsScreen> {
  late Future<PengaturanBengkel> _future;
  final _name = TextEditingController(),
      _address = TextEditingController(),
      _phone = TextEditingController();
  @override
  void initState() {
    super.initState();
    _future = context.read<PengaturanBengkelService>().getSettings().then((
      value,
    ) {
      _name.text = value.nama;
      _address.text = value.alamat;
      _phone.text = value.telepon;
      return value;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<PengaturanBengkelService>().updateSettings(
      PengaturanBengkel(
        id: 1,
        nama: _name.text,
        alamat: _address.text,
        telepon: _phone.text,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Pengaturan Bengkel',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: FutureBuilder<PengaturanBengkel>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snapshot.hasError) {
                return ErrorState(
                  message: 'Pengaturan bengkel belum dapat dimuat.',
                  onRetry: () => setState(
                    () => _future = context
                        .read<PengaturanBengkelService>()
                        .getSettings(),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.contentTopGap,
                  AppSpacing.pageMargin,
                  AppSpacing.xl,
                ),
                children: [
                  Text(
                    'Nama Bengkel',
                    style: AppText.label.copyWith(color: AppColors.textBody),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(hintText: 'Nama Bengkel'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Alamat',
                    style: AppText.label.copyWith(color: AppColors.textBody),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _address,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Alamat'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Nomor Telepon',
                    style: AppText.label.copyWith(color: AppColors.textBody),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _phone,
                    decoration: const InputDecoration(
                      hintText: 'Nomor Telepon',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        FloatingActionBar(label: 'Simpan', icon: null, onPressed: _save),
      ],
    ),
  );
}
