import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/app_switch.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/gejala.dart';
import '../../services/service_interfaces.dart';

class SymptomFormScreen extends StatefulWidget {
  const SymptomFormScreen({super.key, this.symptom});
  final Gejala? symptom;
  @override
  State<SymptomFormScreen> createState() => _SymptomFormScreenState();
}

class _SymptomFormScreenState extends State<SymptomFormScreen> {
  late final _code = TextEditingController(text: widget.symptom?.kode);
  late final _name = TextEditingController(text: widget.symptom?.nama);
  late final _category = TextEditingController(text: widget.symptom?.kategori);
  bool _loading = false;
  bool _active = true;
  @override
  void initState() {
    super.initState();
    _active = widget.symptom?.aktif ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_code.text.trim().isEmpty ||
        _name.text.trim().isEmpty ||
        _category.text.trim().isEmpty) {
      _msg('Kolom ini wajib diisi.');
      return;
    }
    setState(() => _loading = true);
    final item = Gejala(
      id: widget.symptom?.id ?? 1000,
      kode: _code.text.trim(),
      nama: _name.text.trim(),
      kategori: _category.text.trim(),
      aktif: _active,
    );
    try {
      if (widget.symptom == null) {
        await context.read<KerusakanService>().addGejala(item);
      } else {
        await context.read<KerusakanService>().updateGejala(item);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _msg(e.toString().replaceFirst('Bad state: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  Future<void> _deactivate() async {
    if (widget.symptom == null) return;
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
      await context.read<KerusakanService>().deactivateGejala(
        widget.symptom!.id,
      );
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
          title: 'Gejala',
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
                decoration: const InputDecoration(labelText: 'Nama Gejala'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
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
              if (widget.symptom != null)
                TextButton(
                  onPressed: _deactivate,
                  child: const Text(
                    'Nonaktifkan gejala',
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
