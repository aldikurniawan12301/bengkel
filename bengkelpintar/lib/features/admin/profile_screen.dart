import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/navigation/home_menu_config.dart';
import '../../core/role/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../data/models/user.dart';
import '../../services/service_interfaces.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AuthService>().currentUser();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<User?>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: LoadingSkeleton());
      }
      if (snapshot.hasError || snapshot.data == null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: ErrorState(
            message: 'Profil belum dapat dimuat.',
            onRetry: () => setState(
              () => _future = context.read<AuthService>().currentUser(),
            ),
          ),
        );
      }
      final user = snapshot.data!;
      final admin = user.peran == 'admin';
      final role = admin ? UserRole.admin : UserRole.mechanic;
      final nav = HomeMenuConfig.bottomNavigationFor(role);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                _ProfileHeader(user: user, admin: admin),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pageMargin +
                          MediaQuery.paddingOf(context).left,
                      AppSpacing.lg,
                      AppSpacing.pageMargin +
                          MediaQuery.paddingOf(context).right,
                      AppSpacing.bottomBarClearance +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      const _SectionLabel(title: 'Akun'),
                      _ProfileCard(
                        children: [
                          _ProfileRow(
                            icon: AppIcons.lock,
                            title: 'Ganti Password',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.changePassword,
                            ),
                          ),
                        ],
                      ),
                      if (admin) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel(title: 'Bengkel'),
                        _ProfileCard(
                          children: [
                            _ProfileRow(
                              icon: AppIcons.storefront,
                              title: 'Pengaturan Bengkel',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.workshopSettings,
                              ),
                            ),
                            _ProfileRow(
                              icon: AppIcons.dns,
                              title: 'Alamat Server',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.serverSettings,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      const _SectionLabel(title: 'Aplikasi'),
                      _ProfileCard(
                        children: [
                          _ProfileRow(
                            icon: AppIcons.roundedInfo,
                            title: 'Tentang Aplikasi',
                            onTap: () => showAboutDialog(
                              context: context,
                              applicationName: 'BengkelPintar',
                              applicationVersion: '1.0.0',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(AppIcons.logout),
                        label: const Text('Keluar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          minimumSize: const Size.fromHeight(
                            AppSpacing.touchMin,
                          ),
                          side: const BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Center(
                        child: Text('Versi 1.0.0', style: AppText.bodySmall),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingNavBar(
                items: [for (final item in nav) item.label],
                selectedIndex: 4,
                onSelected: (index) {
                  final route = nav[index].route;
                  if (route != AppRoutes.profile) {
                    Navigator.pushReplacementNamed(context, route);
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda perlu masuk lagi untuk memakai aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.admin});

  final User user;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    final initials = user.nama
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final media = MediaQuery.paddingOf(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageMargin + media.left,
        media.top + AppSpacing.md,
        AppSpacing.pageMargin + media.right,
        AppSpacing.md,
      ),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSpacing.profileAvatar / 2,
            backgroundColor: AppColors.primaryMuted,
            child: Text(
              initials,
              style: AppText.title.copyWith(color: AppColors.surface),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.heading.copyWith(color: AppColors.surface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    admin ? 'Admin' : 'Mekanik',
                    style: AppText.label.copyWith(color: AppColors.surface),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
    child: Text(
      title,
      style: AppText.bodySmall.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1)
            const Divider(
              height: 1,
              thickness: 1,
              indent: AppSpacing.md + AppSpacing.circleSmall + AppSpacing.md,
            ),
        ],
      ],
    ),
  );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.circleSmall,
            height: AppSpacing.circleSmall,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppSpacing.iconSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(title, style: AppText.body)),
          const Icon(AppIcons.chevronRight, color: AppColors.textMuted),
        ],
      ),
    ),
  );
}
