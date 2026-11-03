import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/role/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/blue_header.dart';
import '../../services/service_interfaces.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Kolom ini wajib diisi.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = await context.read<AuthService>().login(
      _username.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Nama pengguna atau kata sandi salah.';
      });
      return;
    }
    final role = user.peran == 'admin' ? UserRole.admin : UserRole.mechanic;
    context.read<RoleProvider>().setRole(role);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: AppColors.background,
    body: SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.sizeOf(context).width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LoginHeader(),
            Transform.translate(
              offset: const Offset(0, -AppSpacing.loginCardOverlap),
              child: Padding(
                padding: AppInsets.page(context),
                child: _LoginCard(
                  username: _username,
                  password: _password,
                  obscure: _obscure,
                  loading: _loading,
                  error: _error,
                  onTogglePassword: () => setState(() => _obscure = !_obscure),
                  onLogin: _loading ? null : _login,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -AppSpacing.lg),
              child: Text(
                'Hanya untuk admin dan mekanik bengkel.',
                style: AppText.body.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      height: 220,
      padding: EdgeInsets.only(top: top + AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusHeader),
          bottomRight: Radius.circular(AppSpacing.radiusHeader),
        ),
      ),
      child: Stack(
        children: [
          const IgnorePointer(child: HeaderDecoration()),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [const AppLogo(size: 112)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.username,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final TextEditingController username;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 12,
    shadowColor: AppColors.shadowStrong,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('Selamat datang kembali', style: AppText.title),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Center(
            child: Text('Masuk untuk mulai bekerja', style: AppText.body),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Nama Pengguna',
            style: AppText.body.copyWith(color: AppColors.textTitle),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: username,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                AppIcons.person,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceRaised,
              hintText: 'Masukkan nama pengguna',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Kata Sandi',
            style: AppText.body.copyWith(color: AppColors.textTitle),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: password,
            obscureText: obscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.lock, color: AppColors.textMuted),
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                tooltip: obscure
                    ? 'Tampilkan kata sandi'
                    : 'Sembunyikan kata sandi',
                icon: Icon(
                  obscure ? AppIcons.visibility : AppIcons.visibilityOff,
                  color: AppColors.textMuted,
                ),
              ),
              filled: true,
              fillColor: AppColors.surfaceRaised,
              hintText: 'Kata Sandi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              error!,
              style: AppText.bodySmall.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: 'Masuk',
            icon: AppIcons.arrowForward,
            loading: loading,
            onPressed: onLogin,
          ),
        ],
      ),
    ),
  );
}
