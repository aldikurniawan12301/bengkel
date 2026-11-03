import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/app_switch.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/jasa.dart';
import '../../services/service_interfaces.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.service});
  final Jasa? service;
  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  late final _name = TextEditingController(text: widget.service?.nama);
  late final _price = TextEditingController(
    text: widget.service?.harga.toString(),
  );
  bool _loading = false;
  bool _active = true;
  @override
  void initState() {
    super.initState();
    _active = widget.service?.aktif ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = int.tryParse(_price.text);
    if (_name.text.trim().isEmpty) return _msg('Kolom ini wajib diisi.');
    if (price == null || price < 0) return _msg('Harga tidak boleh negatif.');
    setState(() => _loading = true);
    try {
      final item = Jasa(
        id: widget.service?.id ?? 1000,
        nama: _name.text.trim(),
        harga: price,
        aktif: _active,
      );
      if (widget.service == null) {
        await context.read<JasaService>().addService(item);
      } else {
        await context.read<JasaService>().updateService(item);
      }
      if (mounted) Navigator.pop(context, item);
    } catch (e) {
      if (mounted) _msg(e.toString().replaceFirst('Bad state: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _deactivate() async {
    if (widget.service == null) return;
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
      await context.read<JasaService>().deactivateService(widget.service!.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _msg(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: widget.service == null ? 'Jasa' : 'Ubah Jasa',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama Jasa'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  const Expanded(child: Text('Aktif')),
                  AppSwitch(
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'Simpan',
                loading: _loading,
                onPressed: _loading ? null : _save,
              ),
              if (widget.service != null)
                TextButton(
                  onPressed: _deactivate,
                  child: const Text(
                    'Nonaktifkan jasa',
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
