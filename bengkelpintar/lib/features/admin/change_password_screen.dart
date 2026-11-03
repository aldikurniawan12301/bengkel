import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/floating_action_bar.dart';
import '../../services/service_interfaces.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController(),
      _new = TextEditingController(),
      _confirm = TextEditingController();
  bool _loading = false;
  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_new.text.length < 6) {
      _message('Kata sandi minimal 6 karakter.');
      return;
    }
    if (_new.text != _confirm.text) {
      _message('Konfirmasi kata sandi tidak sama.');
      return;
    }
    setState(() => _loading = true);
    final ok = await context.read<AuthService>().changePassword(
      _old.text,
      _new.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    _message(ok ? 'Kata sandi berhasil diubah.' : 'Kata sandi lama salah.');
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        const BlueHeader(title: 'Ganti Password', type: BlueHeaderType.h2),
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              TextField(
                controller: _old,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Lama'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _new,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                ),
              ),
            ],
          ),
        ),
        FloatingActionBar(label: 'Simpan', onPressed: _loading ? null : _save),
      ],
    ),
  );
}
