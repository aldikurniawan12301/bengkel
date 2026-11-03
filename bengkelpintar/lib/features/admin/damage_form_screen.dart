import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_switch.dart';
import '../../core/widgets/blue_header.dart';
import '../../data/models/jasa.dart';
import '../../data/models/kerusakan.dart';
import '../../data/models/produk.dart';
import '../../services/service_interfaces.dart';
import '../../core/widgets/app_scaffold.dart';

class DamageFormScreen extends StatefulWidget {
  const DamageFormScreen({super.key, this.damage});
  final Kerusakan? damage;
  @override
  State<DamageFormScreen> createState() => _DamageFormScreenState();
}

class _DamageFormScreenState extends State<DamageFormScreen> {
  late final _code = TextEditingController(text: widget.damage?.kode);
  late final _name = TextEditingController(text: widget.damage?.nama);
  late final _solution = TextEditingController(text: widget.damage?.solusi);
  late final _minutes = TextEditingController(
    text: widget.damage?.estimasiWaktuMenit.toString(),
  );
  String _urgency = 'sedang';
  bool _active = true;
  bool _loading = false;
  List<KomponenTerkait> _components = [];
  List<JasaTerkait> _services = [];

  @override
  void initState() {
    super.initState();
    final item = widget.damage;
    _urgency = item?.urgensi ?? 'sedang';
    _active = item?.aktif ?? true;
    _components = List.of(item?.komponenTerkait ?? const []);
    _services = List.of(item?.jasaTerkait ?? const []);
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _solution.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _pickRelated() async {
    final productService = context.read<ProdukService>();
    final jasaService = context.read<JasaService>();
    final products = (await productService.listProducts())
        .where((item) => item.aktif)
        .toList();
    final services = (await jasaService.listServices())
        .where((item) => item.aktif)
        .toList();
    if (!mounted) return;
    final selectedProducts = _components.map((item) => item.produkId).toSet();
    final selectedServices = _services.map((item) => item.jasaId).toSet();
    final result = await showModalBottomSheet<_RelatedSelection>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AppSheetPadding(
        child: _RelatedPicker(
          products: products,
          services: services,
          selectedProducts: selectedProducts,
          selectedServices: selectedServices,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _components = [
        for (final item in products.where(
          (item) => result.products.contains(item.id),
        ))
          KomponenTerkait(
            produkId: item.id,
            nama: item.nama,
            harga: item.harga,
          ),
      ];
      _services = [
        for (final item in services.where(
          (item) => result.services.contains(item.id),
        ))
          JasaTerkait(jasaId: item.id, nama: item.nama, harga: item.harga),
      ];
    });
  }

  Future<void> _save() async {
    final minutes = int.tryParse(_minutes.text);
    if (_code.text.trim().isEmpty ||
        _name.text.trim().isEmpty ||
        _solution.text.trim().isEmpty ||
        minutes == null ||
        minutes < 0) {
      _message('Kolom ini wajib diisi.');
      return;
    }
    setState(() => _loading = true);
    final item = Kerusakan(
      id: widget.damage?.id ?? 1000,
      kode: _code.text.trim(),
      nama: _name.text.trim(),
      urgensi: _urgency,
      solusi: _solution.text.trim(),
      estimasiWaktuMenit: minutes,
      aktif: _active,
      komponenTerkait: _components,
      jasaTerkait: _services,
    );
    try {
      final service = context.read<KerusakanService>();
      if (widget.damage == null) {
        await service.addKerusakan(item);
      } else {
        await service.updateKerusakan(item);
      }
      if (mounted) Navigator.pop(context, item);
    } catch (e) {
      if (mounted) _message(e.toString().replaceFirst('Bad state: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deactivate() async {
    if (widget.damage == null) return;
    final yes = await _confirm(
      'Nonaktifkan item ini? Item tidak akan muncul di pilihan baru.',
    );
    if (yes != true || !mounted) return;
    try {
      await context.read<KerusakanService>().deactivateKerusakan(
        widget.damage!.id,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _message(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<bool?> _confirm(String text) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi'),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        AppButton.small(
          label: 'Nonaktifkan',
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: widget.damage == null ? 'Kerusakan' : 'Ubah Kerusakan',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              TextField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Kode'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama Kerusakan'),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                initialValue: _urgency,
                items: const [
                  DropdownMenuItem(value: 'rendah', child: Text('Rendah')),
                  DropdownMenuItem(value: 'sedang', child: Text('Sedang')),
                  DropdownMenuItem(value: 'tinggi', child: Text('Tinggi')),
                ],
                onChanged: (v) => setState(() => _urgency = v ?? 'sedang'),
                decoration: const InputDecoration(labelText: 'Urgensi'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _solution,
                decoration: const InputDecoration(labelText: 'Solusi'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _minutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimasi Waktu (menit)',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.tonal(
                label: 'Pilih Komponen dan Jasa',
                icon: AppIcons.tune,
                onPressed: _pickRelated,
              ),
              for (final item in _components)
                Text(
                  '${item.nama} · Rp${item.harga}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              for (final item in _services)
                Text(
                  '${item.nama} · Rp${item.harga}',
                  style: Theme.of(context).textTheme.bodySmall,
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
              if (widget.damage != null)
                TextButton(
                  onPressed: _deactivate,
                  child: const Text(
                    'Nonaktifkan kerusakan',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RelatedSelection {
  const _RelatedSelection(this.products, this.services);
  final Set<int> products;
  final Set<int> services;
}

class _RelatedPicker extends StatefulWidget {
  const _RelatedPicker({
    required this.products,
    required this.services,
    required this.selectedProducts,
    required this.selectedServices,
  });
  final List<Produk> products;
  final List<Jasa> services;
  final Set<int> selectedProducts;
  final Set<int> selectedServices;
  @override
  State<_RelatedPicker> createState() => _RelatedPickerState();
}

class _RelatedPickerState extends State<_RelatedPicker> {
  late final Set<int> _products = {...widget.selectedProducts};
  late final Set<int> _services = {...widget.selectedServices};
  String _query = '';
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: AppSpacing.cardInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Cari produk atau jasa',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final item in widget.products.where(
                  (item) =>
                      item.nama.toLowerCase().contains(_query.toLowerCase()),
                ))
                  CheckboxListTile(
                    value: _products.contains(item.id),
                    title: Text(item.nama),
                    subtitle: const Text('Komponen'),
                    onChanged: (value) => setState(
                      () => value == true
                          ? _products.add(item.id)
                          : _products.remove(item.id),
                    ),
                  ),
                for (final item in widget.services.where(
                  (item) =>
                      item.nama.toLowerCase().contains(_query.toLowerCase()),
                ))
                  CheckboxListTile(
                    value: _services.contains(item.id),
                    title: Text(item.nama),
                    subtitle: const Text('Jasa'),
                    onChanged: (value) => setState(
                      () => value == true
                          ? _services.add(item.id)
                          : _services.remove(item.id),
                    ),
                  ),
              ],
            ),
          ),
          AppButton.primary(
            label: 'Pilih',
            onPressed: () =>
                Navigator.pop(context, _RelatedSelection(_products, _services)),
          ),
        ],
      ),
    ),
  );
}
