import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/config/server_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_copy.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/floating_action_bar.dart';
import '../../services/service_interfaces.dart';
import '../../services/mock_failure.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({super.key});

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  late final TextEditingController _controller;
  bool _checking = false;
  bool? _connectionSucceeded;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ServerConfig>().editableUrl,
    )..addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    if (_connectionSucceeded != null) {
      setState(() => _connectionSucceeded = null);
    }
    setState(() {});
  }

  bool get _valid => ServerConfig.isValidUrl(_controller.text);

  Future<void> _checkConnection() async {
    if (!_valid) return;
    setState(() {
      _checking = true;
      _connectionSucceeded = null;
    });
    bool succeeded;
    try {
      succeeded = await context.read<ServerService>().checkHealth(
        _controller.text.trim(),
      );
    } catch (_) {
      succeeded = false;
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _connectionSucceeded = succeeded;
    });
  }

  Future<void> _save() async {
    if (!_valid) return;
    await context.read<ServerConfig>().save(_controller.text);
    if (mounted) Navigator.maybePop(context);
  }

  Future<void> _restoreDefault() async {
    final config = context.read<ServerConfig>();
    await config.restoreDefault();
    _controller.text = config.defaultUrl;
    if (mounted) setState(() => _connectionSucceeded = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BlueHeader(
            title: 'Pengaturan Server',
            type: BlueHeaderType.h3,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.xl,
                AppSpacing.pageMargin,
                AppSpacing.sm,
              ),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                child: Padding(
                  padding: AppSpacing.cardInsets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        AppIcons.dns,
                        color: AppColors.primary,
                        size: AppSpacing.iconLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text('Alamat Server', style: AppText.title),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Alamat server tempat data disimpan. Ubah hanya jika diminta.',
                        style: AppText.body,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Alamat Server',
                          hintText: 'http://192.168.1.10:8000',
                          errorText: _valid
                              ? null
                              : AppCopy.invalidServerAddress,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton.secondary(
                        label: 'Tes Koneksi',
                        onPressed: _valid && !_checking
                            ? _checkConnection
                            : null,
                        loading: _checking,
                      ),
                      if (_connectionSucceeded != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ConnectionStatus(succeeded: _connectionSucceeded!),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _restoreDefault,
                        child: const Text('Kembalikan ke bawaan'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Builder(
                        builder: (context) {
                          final failure = context
                              .watch<MockFailureController?>();
                          return SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Simulasikan server gagal'),
                            subtitle: const Text(
                              'Untuk menguji keadaan error di semua layar data.',
                            ),
                            value: failure?.enabled ?? false,
                            onChanged: failure?.setEnabled,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FloatingActionBar(label: 'Simpan', onPressed: _valid ? _save : null),
        ],
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus({required this.succeeded});

  final bool succeeded;

  @override
  Widget build(BuildContext context) {
    final color = succeeded ? AppColors.success : AppColors.danger;
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: succeeded ? AppColors.successSoft : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            succeeded ? AppIcons.checkCircle : AppIcons.roundedError,
            color: color,
            size: AppSpacing.icon,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              succeeded
                  ? AppCopy.serverConnected
                  : AppCopy.serverConnectionError,
              style: AppText.body.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
