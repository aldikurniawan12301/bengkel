import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/app_switch.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user.dart';
import '../../services/service_interfaces.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key, this.user});
  final User? user;
  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  late final _name = TextEditingController(text: widget.user?.nama);
  late final _username = TextEditingController(text: widget.user?.username);
  String _role = 'mekanik';
  bool _loading = false;
  bool _active = true;
  @override
  void initState() {
    super.initState();
    _role = widget.user?.peran ?? 'mekanik';
    _active = widget.user?.aktif ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _username.text.trim().isEmpty) {
      _msg('Kolom ini wajib diisi.');
      return;
    }
    setState(() => _loading = true);
    final item = User(
      id: widget.user?.id ?? 1000,
      nama: _name.text.trim(),
      username: _username.text.trim(),
      peran: _role,
      aktif: _active,
    );
    try {
      if (widget.user == null) {
        await context.read<PenggunaService>().addUser(item);
      } else {
        await context.read<PenggunaService>().updateUser(item);
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
    if (widget.user == null) return;
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
      await context.read<PenggunaService>().deactivateUser(widget.user!.id);
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
          title: 'Pengguna',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Nama Pengguna'),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                initialValue: _role,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'mekanik', child: Text('Mekanik')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'mekanik'),
                decoration: const InputDecoration(labelText: 'Peran'),
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
              if (widget.user != null)
                TextButton(
                  onPressed: _deactivate,
                  child: const Text(
                    'Nonaktifkan pengguna',
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
