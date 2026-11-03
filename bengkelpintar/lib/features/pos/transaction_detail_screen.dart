import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/role/role_provider.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/list_card.dart';
import '../../core/widgets/floating_action_bar.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/models/transaksi.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});
  final Transaksi transaction;
  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Detail Transaksi',
          type: BlueHeaderType.h3,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              ListCard(
                title: transaction.nomor,
                subtitle:
                    '${transaction.namaPelanggan} · ${transaction.platNomor}\n${formatTanggalIndonesia(transaction.waktu)}',
                trailing: Text(
                  transaction.status == 'final' ? 'Final' : 'Draft',
                  style: AppText.subheading,
                ),
              ),
              if (transaction.status == 'final' &&
                  context.read<RoleProvider?>()?.role == UserRole.mechanic)
                const SizedBox.shrink()
              else
                FloatingActionBar(
                  label: transaction.status == 'final'
                      ? 'Lihat Nota'
                      : 'Finalisasi',
                  icon: transaction.status == 'final'
                      ? AppIcons.receiptLong
                      : AppIcons.arrowForward,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    transaction.status == 'final'
                        ? AppRoutes.receipt
                        : AppRoutes.finalize,
                    arguments: transaction,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              for (final item in transaction.items)
                ListCard(
                  title: item.nama,
                  subtitle:
                      '${item.jumlah} x ${formatRupiah(item.hargaSatuan)}',
                  trailing: Text(
                    formatRupiah(item.subtotal),
                    style: AppText.subheading,
                  ),
                ),
              ListCard(
                title: 'Total',
                trailing: Text(
                  formatRupiah(transaction.total),
                  style: AppText.title,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
