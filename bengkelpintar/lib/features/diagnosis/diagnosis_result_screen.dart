import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/confidence_ring.dart';
import '../../core/widgets/dashed_divider.dart';
import '../../core/widgets/percentage_bar.dart';
import '../../core/widgets/perkiraan_label.dart';
import '../../core/widgets/urgensi_badge.dart';
import '../../data/models/hasil_diagnosis.dart';
import '../../data/models/riwayat_diagnosis.dart';
import '../../data/models/transaksi.dart';
import '../../services/service_interfaces.dart';

class DiagnosisResultScreen extends StatefulWidget {
  const DiagnosisResultScreen({super.key, required this.result, this.history});

  final HasilDiagnosis result;
  final RiwayatDiagnosis? history;

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  bool _saving = false;

  Future<void> _draft() async {
    setState(() => _saving = true);
    final items = [
      ...widget.result.komponenTerkait.map(
        (item) =>
            ItemTransaksiRequest(tipe: 'produk', id: item.produkId, jumlah: 1),
      ),
      ...widget.result.jasaTerkait.map(
        (item) =>
            ItemTransaksiRequest(tipe: 'jasa', id: item.jasaId, jumlah: 1),
      ),
    ];
    final transaction = await context.read<TransaksiService>().createDraft(
      namaPelanggan: 'Dedi Kurniawan',
      platNomor: 'D 1234 XX',
      items: items,
      riwayatDiagnosisId: widget.result.riwayatId,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pushNamed(context, AppRoutes.draft, arguments: transaction);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return AppScaffold(
      body: Column(
        children: [
          BlueHeader(
            title: 'Hasil Diagnosis',
            type: BlueHeaderType.h3,
            onBack: () => Navigator.maybePop(context),
            action: const Icon(AppIcons.share, color: AppColors.surface),
          ),
          Expanded(
            child: ListView(
              padding: AppInsets.page(context, bottom: AppSpacing.xl),
              children: [
                Transform.translate(
                  offset: const Offset(0, -AppSpacing.headerCardOverlap),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.history != null) ...[
                            Text(
                              formatTanggalIndonesia(widget.history!.waktu),
                              style: AppText.bodySmall,
                            ),
                            Text(
                              'Dibuat oleh ${widget.history!.penggunaNama}',
                              style: AppText.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final symptom in widget.history!.gejala)
                                  Chip(label: Text(symptom.kode)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: Container(
                              width: AppSpacing.statusIcon,
                              height: AppSpacing.statusIcon,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                AppIcons.bolt,
                                color: AppColors.surface,
                                size: AppSpacing.iconLarge,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            result.kerusakanUtama.nama,
                            textAlign: TextAlign.center,
                            style: AppText.display,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UrgensiBadge(level: _urgency(result.urgensi)),
                              const Spacer(),
                              ConfidenceRing(
                                value: result.kerusakanUtama.keyakinan,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const DashedDivider(),
                          _Section(
                            title: 'Kemungkinan Lain',
                            child: Column(
                              children: [
                                for (final item in result.kemungkinanLain)
                                  PercentageBar(
                                    label: item.nama,
                                    value: item.keyakinan,
                                  ),
                              ],
                            ),
                          ),
                          _Section(
                            title: 'Urgensi',
                            child: Text(
                              result.urgensiKeterangan,
                              style: AppText.body,
                            ),
                          ),
                          _Section(
                            title: 'Solusi',
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                border: const Border.fromBorderSide(
                                  BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    AppIcons.checkCircle,
                                    color: AppColors.success,
                                    size: AppSpacing.icon,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      result.solusi,
                                      style: AppText.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _Section(
                            title: 'Komponen Terkait',
                            child: Column(
                              children: [
                                for (final item in result.komponenTerkait)
                                  _PriceRow(name: item.nama, price: item.harga),
                              ],
                            ),
                          ),
                          _Section(
                            title: 'Jasa Terkait',
                            child: Column(
                              children: [
                                for (final item in result.jasaTerkait)
                                  _PriceRow(name: item.nama, price: item.harga),
                              ],
                            ),
                          ),
                          _Section(
                            title: 'Estimasi Biaya',
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                Text(
                                  '${formatRupiah(result.estimasiBiaya.min)} - ${formatRupiah(result.estimasiBiaya.max)}',
                                  style: AppText.heading,
                                ),
                                const PerkiraanLabel(),
                              ],
                            ),
                          ),
                          Text(
                            'Estimasi waktu ${result.estimasiWaktuMenit} menit',
                            style: AppText.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'Hasil ini alat bantu, bukan kepastian.',
                            style: AppText.bodySmall,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.diagnosis,
                              ),
                              icon: const Icon(AppIcons.refresh),
                              label: const Text('Diagnosis Ulang'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppBottomActionBar(
            info: const Text(
              'Hasil tersimpan di riwayat',
              style: AppText.bodySmall,
            ),
            child: AppButton.primary(
              label: 'Buat Draft Transaksi',
              icon: AppIcons.shoppingCart,
              loading: _saving,
              expand: false,
              onPressed: _saving ? null : _draft,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.heading),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    ),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.name, required this.price});

  final String name;
  final int price;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        const Icon(
          AppIcons.checkCircle,
          color: AppColors.success,
          size: AppSpacing.iconSmall,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(name, style: AppText.body)),
        Text(formatRupiah(price), style: AppText.subheading),
      ],
    ),
  );
}

Urgensi _urgency(String value) => switch (value.toLowerCase()) {
  'rendah' => Urgensi.rendah,
  'tinggi' => Urgensi.tinggi,
  _ => Urgensi.sedang,
};
