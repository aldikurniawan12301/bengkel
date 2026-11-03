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
import '../../data/models/kategori.dart';
import '../../services/service_interfaces.dart';
import '../../core/widgets/app_button.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Kategori>> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = context.read<KategoriService>().listCategories();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Kategori Produk',
          type: BlueHeaderType.h4,
          action: CircleIconButton(
            icon: AppIcons.add,
            onHeader: true,
            tooltip: 'Tambah kategori',
            onPressed: () => _edit(context),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Kategori>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snapshot.hasError) {
                return ErrorState(
                  message: 'Kategori belum dapat dimuat.',
                  onRetry: () => setState(_reload),
                );
              }
              final list = snapshot.data ?? const <Kategori>[];
              if (list.isEmpty) {
                return const EmptyState(
                  title: 'Belum ada kategori',
                  message: 'Tambahkan kategori pertama.',
                );
              }
              return ListView(
                padding: AppSpacing.pageInsets,
                children: [
                  for (final item in list)
                    ListCard(
                      title: item.nama,
                      trailing: Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          StatusBadge(
                            status: item.aktif
                                ? AppStatus.aktif
                                : AppStatus.nonaktif,
                          ),
                          if (item.aktif)
                            TextButton(
                              onPressed: () => _deactivate(item),
                              child: const Text('Nonaktifkan'),
                            ),
                        ],
                      ),
                      onTap: () => _edit(context, item),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );

  Future<void> _edit(BuildContext context, [Kategori? existing]) async {
    final service = context.read<KategoriService>();
    final controller = TextEditingController(text: existing?.nama);
    final result = await showDialog<_CategoryEditResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Tambah Kategori' : 'Ubah Kategori'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          AppButton.small(
            label: 'Simpan',
            onPressed: () => Navigator.pop(
              context,
              _CategoryEditResult(controller.text, existing?.aktif ?? true),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.name.trim().isEmpty) return;
    if (!mounted) return;
    final item = Kategori(
      id: existing?.id ?? 1000,
      nama: result.name.trim(),
      aktif: result.active,
    );
    if (existing == null) {
      await service.addCategory(item);
    } else {
      await service.updateCategory(item);
    }
    if (mounted) setState(_reload);
  }

  Future<void> _deactivate(Kategori item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Nonaktifkan item ini? Item tidak akan muncul di pilihan baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Nonaktifkan',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    try {
      await context.read<KategoriService>().deactivateCategory(item.id);
      setState(_reload);
    } catch (e) {
      _message(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _CategoryEditResult {
  const _CategoryEditResult(this.name, this.active);
  final String name;
  final bool active;
}
