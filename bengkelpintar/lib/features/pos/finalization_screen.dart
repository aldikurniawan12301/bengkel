import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/floating_action_bar.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/transaksi.dart';
import '../../services/service_interfaces.dart';
import '../../data/models/pengaturan_bengkel.dart';
import 'receipt_screen.dart';
import '../../core/widgets/dashed_divider.dart';

class FinalizationScreen extends StatefulWidget {
  const FinalizationScreen({super.key, required this.transaction});
  final Transaksi transaction;
  @override
  State<FinalizationScreen> createState() => _FinalizationScreenState();
}

class _FinalizationScreenState extends State<FinalizationScreen> {
  String _method = 'tunai';
  final _paid = TextEditingController();
  bool _loading = false;
  Transaksi? _finalized;
  late Future<PengaturanBengkel> _settings;
  @override
  void dispose() {
    _paid.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _settings = context.read<PengaturanBengkelService>().getSettings();
  }

  Future<void> _finalize() async {
    final paid = _paidAmount;
    if (paid < widget.transaction.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah dibayar belum mencukupi.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalisasi transaksi?'),
        content: const Text(
          'Finalisasi transaksi? Stok akan berkurang dan draft tidak bisa diubah lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          AppButton.primary(
            label: 'Finalisasi',
            expand: false,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      final result = await context.read<TransaksiService>().finalizeTransaction(
        widget.transaction.id,
        metodeBayar: _method,
        jumlahDibayar: paid,
      );
      if (mounted) setState(() => _finalized = result);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  int get _paidAmount =>
      int.tryParse(_paid.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
      widget.transaction.total;

  @override
  Widget build(BuildContext context) {
    final item = _finalized ?? widget.transaction;
    if (_finalized != null) {
      return FutureBuilder<PengaturanBengkel>(
        future: _settings,
        builder: (context, snapshot) =>
            ReceiptScreen(transaction: item, settings: snapshot.data),
      );
    }
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const BlueHeader(title: 'Pembayaran', type: BlueHeaderType.h2),
          Expanded(
            child: ListView(
              padding: AppSpacing.pageInsets,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: AppSpacing.cardInsets,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nomor, style: AppText.subheading),
                        Text(item.namaPelanggan, style: AppText.body),
                        Text(item.platNomor, style: AppText.bodySmall),
                        const SizedBox(height: AppSpacing.sm),
                        const DashedDivider(),
                        for (final line in item.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(line.nama, style: AppText.body),
                                ),
                                Text(
                                  formatRupiah(line.subtotal),
                                  style: AppText.body,
                                ),
                              ],
                            ),
                          ),
                        const DashedDivider(),
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Total', style: AppText.heading),
                            ),
                            Flexible(
                              child: Text(
                                formatRupiah(item.total),
                                textAlign: TextAlign.end,
                                style: AppText.title,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('Metode Pembayaran', style: AppText.heading),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('Tunai'),
                      selected: _method == 'tunai',
                      onSelected: (_) => setState(() => _method = 'tunai'),
                    ),
                    ChoiceChip(
                      label: const Text('Transfer'),
                      selected: _method == 'transfer',
                      onSelected: (_) => setState(() => _method = 'transfer'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _paid,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Dibayar',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Kembalian ${formatRupiah(_paidAmount - item.total)}',
                  style: AppText.heading.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
          FloatingActionBar(
            label: 'Finalisasi Transaksi',
            onPressed: _loading ? null : _finalize,
          ),
        ],
      ),
    );
  }
}
