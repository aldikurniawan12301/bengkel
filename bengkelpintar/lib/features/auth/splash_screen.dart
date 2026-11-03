import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_system_ui.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_logo.dart';
import '../../data/models/user.dart';
import '../../services/service_interfaces.dart';
import '../../core/role/role_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.sessionCheckDelay = const Duration(milliseconds: 1500),
    this.checkSession = true,
  });

  final Duration sessionCheckDelay;
  final bool checkSession;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _sessionCheckStarted = false;

  @override
  void initState() {
    super.initState();
    _startSessionCheckIfReady();
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startSessionCheckIfReady();
  }

  void _startSessionCheckIfReady() {
    if (widget.checkSession && !_sessionCheckStarted) {
      _sessionCheckStarted = true;
      _checkSession();
    }
  }

  Future<void> _checkSession() async {
    if (widget.sessionCheckDelay > Duration.zero) {
      await Future<void>.delayed(widget.sessionCheckDelay);
    }
    if (!mounted) return;
    User? user;
    try {
      user = await context.read<AuthService>().currentUser();
    } catch (_) {
      user = null;
    }
    if (!mounted) return;
    final roleProvider = context.read<RoleProvider?>();
    if (user != null && roleProvider != null) {
      roleProvider.setRole(
        user.peran == 'admin' ? UserRole.admin : UserRole.mechanic,
      );
    }
    final destination = user == null ? AppRoutes.login : AppRoutes.home;
    final role = user?.peran == 'admin' ? UserRole.admin : UserRole.mechanic;
    Navigator.pushReplacement(
      context,
      AppRouter.onGenerateRoute(RouteSettings(name: destination), role),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.overlayStyle.copyWith(
        systemNavigationBarColor: AppColors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SizedBox.expand(
          key: const ValueKey('splash-background'),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.gradientEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Padding(
                padding: AppInsets.horizontal(context),
                child: const SizedBox(width: double.infinity, child: _Logo()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('splash-content'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLogo(
          key: const ValueKey('splash-logo'),
          size: AppSpacing.splashLogo * 2,
        ),
      ],
    );
  }
}
