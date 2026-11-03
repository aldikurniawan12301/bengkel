import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/list_card.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/mutasi_stok.dart';
import '../../data/models/produk.dart';
import '../../services/service_interfaces.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Produk product;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Produk _product = widget.product;
  late Future<List<MutasiStok>> _future;
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  bool _stockIn = true;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _reload() =>
      _future = context.read<ProdukService>().listStockMovements(_product.id);
  Future<void> _adjust() async {
    final amount = int.tryParse(_amount.text);
    if (amount == null || amount <= 0 || _reason.text.trim().isEmpty) {
      _msg('Kolom ini wajib diisi.');
      return;
    }
    try {
      _product = await context.read<ProdukService>().adjustStock(
        _product.id,
        jumlah: _stockIn ? amount : -amount,
        alasan: _reason.text.trim(),
      );
      _amount.clear();
      _reason.clear();
      setState(_reload);
    } catch (e) {
      _msg(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Detail Produk',
          type: BlueHeaderType.h3,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageMargin,
              AppSpacing.contentTopGap,
              AppSpacing.pageMargin,
              AppSpacing.bottomBarClearance,
            ),
            children: [
              ListCard(
                leading: CategoryIcon(
                  category: _product.kategoriNama,
                  size: AppSpacing.catalogIconSize,
                ),
                title: _product.nama,
                subtitle: formatRupiah(_product.harga),
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        StatusBadge(
                          status: _product.stok == 0
                              ? AppStatus.stokHabis
                              : _product.stok <= _product.stokMinimum
                              ? AppStatus.stokMenipis
                              : AppStatus.stokAman,
                        ),
                        Text('Stok ${_product.stok}', style: AppText.body),
                        Text(_product.kategoriNama, style: AppText.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListCard(
                title: 'Sesuaikan stok',
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Masuk')),
                        ButtonSegment(
                          value: false,
                          label: Text('Rusak/keluar'),
                        ),
                      ],
                      selected: {_stockIn},
                      showSelectedIcon: false,
                      onSelectionChanged: (values) =>
                          setState(() => _stockIn = values.first),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Jumlah',
                      style: AppText.label.copyWith(color: AppColors.textBody),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan jumlah',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Alasan',
                      style: AppText.label.copyWith(color: AppColors.textBody),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _reason,
                      decoration: const InputDecoration(
                        hintText: 'Alasan penyesuaian',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton.primary(
                      label: 'Simpan penyesuaian',
                      onPressed: _adjust,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Riwayat Mutasi', style: AppText.heading),
              FutureBuilder<List<MutasiStok>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const LoadingSkeleton();
                  }
                  if (snap.hasError) {
                    return ErrorState(
                      message: 'Mutasi belum dapat dimuat.',
                      onRetry: () => setState(_reload),
                    );
                  }
                  final list = snap.data ?? const <MutasiStok>[];
                  if (list.isEmpty) {
                    return ListCard(
                      title: 'Belum ada mutasi stok',
                      leading: const Icon(AppIcons.info),
                    );
                  }
                  return Column(
                    children: [
                      for (final item in list)
                        ListCard(
                          title:
                              '${item.jumlah > 0 ? '+' : ''}${item.jumlah} stok',
                          subtitle:
                              '${item.alasan} · ${formatTanggalIndonesia(item.waktu)}',
                          trailing: Text(
                            item.dibuatOleh,
                            style: AppText.bodySmall,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
