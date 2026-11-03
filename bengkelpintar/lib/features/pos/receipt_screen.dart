import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/transaksi.dart';
import '../../data/models/pengaturan_bengkel.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.transaction, this.settings});
  final Transaksi transaction;
  final PengaturanBengkel? settings;
  Future<void> _share() async {
    final workshop =
        settings ??
        const PengaturanBengkel(
          id: 1,
          nama: 'Bengkel Maju Jaya',
          alamat: 'Jl. Merdeka No. 12, Bandung',
          telepon: '0812-3456-7890',
        );
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          children: [
            pw.Text(workshop.nama),
            pw.Text(workshop.alamat),
            pw.Text(transaction.nomor),
            pw.Text(transaction.namaPelanggan),
            for (final item in transaction.items)
              pw.Text('${item.nama} ${item.jumlah} x ${item.hargaSatuan}'),
            pw.Text('TOTAL ${transaction.total}'),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: '${transaction.nomor}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BlueHeader(
            title: 'Transaksi Berhasil',
            type: BlueHeaderType.h2,
            onBack: () => Navigator.maybePop(context),
            action: const Icon(AppIcons.checkCircle, color: AppColors.surface),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pageInsets,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: AppSpacing.cardInsets,
                  child: Column(
                    children: [
                      Text(
                        settings?.nama ?? 'Bengkel Maju Jaya',
                        style: AppText.heading,
                      ),
                      Text(
                        settings?.alamat ?? 'Jl. Merdeka No. 12, Bandung',
                        style: AppText.bodySmall,
                      ),
                      Text(
                        settings?.telepon ?? '0812-3456-7890',
                        style: AppText.bodySmall,
                      ),
                      for (final item in transaction.items)
                        ListTile(
                          title: Text(item.nama),
                          subtitle: Text(
                            '${item.jumlah} x ${formatRupiah(item.hargaSatuan)}',
                          ),
                          trailing: Text(formatRupiah(item.subtotal)),
                        ),
                      const Divider(),
                      Text(
                        'TOTAL ${formatRupiah(transaction.total)}',
                        style: AppText.title,
                      ),
                      const Text(
                        'Terima kasih telah mempercayakan motor Anda kepada kami.',
                        style: AppText.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageMargin,
              AppSpacing.md,
              AppSpacing.pageMargin,
              AppInsets.bottom(context, extra: AppSpacing.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton.primary(
                    label: 'Bagikan PDF',
                    icon: AppIcons.share,
                    onPressed: _share,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton.secondary(
                    label: 'Selesai',
                    onPressed: () => Navigator.popUntil(
                      context,
                      ModalRoute.withName(AppRoutes.home),
                    ),
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
