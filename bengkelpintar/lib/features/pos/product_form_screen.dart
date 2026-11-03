import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/app_switch.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/kategori.dart';
import '../../data/models/produk.dart';
import '../../services/service_interfaces.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});
  final Produk? product;
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.product?.nama,
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.product?.harga.toString(),
  );
  late final TextEditingController _stock = TextEditingController(
    text: widget.product?.stok.toString(),
  );
  Kategori? _category;
  bool _loading = false;
  bool _active = true;
  Future<List<Kategori>>? _categories;

  @override
  void initState() {
    super.initState();
    _active = widget.product?.aktif ?? true;
    _categories = context.read<KategoriService>().listCategories();
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = int.tryParse(_price.text);
    final stock = int.tryParse(_stock.text);
    if (_name.text.trim().isEmpty) return _message('Kolom ini wajib diisi.');
    if (price == null || price < 0) {
      return _message('Harga tidak boleh negatif.');
    }
    if (stock == null || stock < 0) {
      return _message('Stok tidak boleh negatif.');
    }
    if (_category == null && widget.product == null) {
      return _message('Kolom ini wajib diisi.');
    }
    setState(() => _loading = true);
    try {
      final current = widget.product;
      final item = Produk(
        id: current?.id ?? 1000,
        nama: _name.text.trim(),
        kategoriId: _category?.id ?? current!.kategoriId,
        kategoriNama: _category?.nama ?? current!.kategoriNama,
        harga: price,
        stok: stock,
        stokMinimum: current?.stokMinimum ?? 2,
        aktif: _active,
      );
      final service = context.read<ProdukService>();
      if (current == null) {
        await service.addProduct(item);
      } else {
        await service.updateProduct(item);
      }
      if (mounted) Navigator.pop(context, item);
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Bad state: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _deactivate() async {
    if (widget.product == null) return;
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
      await context.read<ProdukService>().deactivateProduct(widget.product!.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _message(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: widget.product == null ? 'Produk' : 'Ubah Produk',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: FutureBuilder<List<Kategori>>(
            future: _categories,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingSkeleton();
              }
              if (snap.hasError) {
                return ErrorState(
                  message: 'Kategori belum dapat dimuat.',
                  onRetry: () => setState(
                    () => _categories = context
                        .read<KategoriService>()
                        .listCategories(),
                  ),
                );
              }
              final categories = snap.data ?? const <Kategori>[];
              return ListView(
                padding: AppSpacing.pageInsets,
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nama Produk'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppDropdown<Kategori>(
                    value:
                        _category ??
                        (widget.product == null
                            ? null
                            : categories
                                  .where(
                                    (x) => x.id == widget.product!.kategoriId,
                                  )
                                  .firstOrNull),
                    label: 'Kategori',
                    items: [
                      for (final item in categories.where((x) => x.aktif))
                        DropdownMenuItem(value: item, child: Text(item.nama)),
                    ],
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Expanded(child: Text('Aktif')),
                      AppSwitch(
                        value: _active,
                        onChanged: (value) => setState(() => _active = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    label: 'Simpan',
                    loading: _loading,
                    onPressed: _loading ? null : _save,
                  ),
                  if (widget.product != null)
                    TextButton(
                      onPressed: _deactivate,
                      child: const Text(
                        'Nonaktifkan produk',
                        style: TextStyle(color: AppColors.danger),
                      ),
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
