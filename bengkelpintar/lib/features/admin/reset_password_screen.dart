import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blue_header.dart';
import '../../data/models/user.dart';
import '../../services/service_interfaces.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.user});
  final User user;
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  bool _loading = false;
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_password.text.length < 6) {
      _msg('Kata sandi minimal 6 karakter.');
      return;
    }
    setState(() => _loading = true);
    final ok = await context.read<PenggunaService>().resetPassword(
      widget.user.id,
      _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    _msg(ok ? 'Kata sandi berhasil diubah.' : 'Reset password gagal.');
    if (ok) Navigator.pop(context);
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Reset Password',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              Text(widget.user.nama),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Simpan',
                loading: _loading,
                onPressed: _loading ? null : _save,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
