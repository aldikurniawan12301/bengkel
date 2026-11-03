import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/role/role_provider.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/config/server_config.dart';
import '../../services/service_interfaces.dart';

class ServerUnreachableScreen extends StatefulWidget {
  const ServerUnreachableScreen({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  State<ServerUnreachableScreen> createState() =>
      _ServerUnreachableScreenState();
}

class _ServerUnreachableScreenState extends State<ServerUnreachableScreen> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (widget.onRetry != null) {
      widget.onRetry!();
      return;
    }
    final service = context.read<ServerService?>();
    final config = context.read<ServerConfig?>();
    if (service == null || config == null) {
      Navigator.maybePop(context);
      return;
    }
    setState(() => _retrying = true);
    final connected = await service.checkHealth(config.effectiveUrl);
    if (!mounted) return;
    setState(() => _retrying = false);
    if (connected) Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Server Tidak Terjangkau',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: AppSpacing.cardInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    AppIcons.wifiOff,
                    color: AppColors.danger,
                    size: AppSpacing.iconLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Tidak dapat terhubung ke server. Pastikan perangkat server menyala dan HP tersambung ke jaringan bengkel.',
                    textAlign: TextAlign.center,
                    style: AppText.body,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton.primary(
                    label: 'Coba lagi',
                    onPressed: _retrying ? null : _retry,
                    loading: _retrying,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (context.read<RoleProvider?>()?.role == UserRole.admin)
                    AppButton.secondary(
                      label: 'Pengaturan Server',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.serverSettings,
                      ),
                    )
                  else
                    AppButton.secondary(
                      label: 'Hubungi admin',
                      onPressed: () => Navigator.maybePop(context),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
