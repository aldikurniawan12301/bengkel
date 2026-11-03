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
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/confidence_ring.dart';

import '../../core/widgets/perkiraan_label.dart';
import '../../core/widgets/percentage_bar.dart';
import '../../core/widgets/urgensi_badge.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/hasil_diagnosis.dart';
import '../../data/models/riwayat_diagnosis.dart';
import '../../data/models/transaksi.dart';
import '../../data/models/produk.dart';
import '../../services/service_interfaces.dart';
import '../pos/cashier_screen.dart';

class DiagnosisResultScreen extends StatefulWidget {
  const DiagnosisResultScreen({super.key, required this.result, this.history});

  final HasilDiagnosis result;
  final RiwayatDiagnosis? history;

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  bool _saving = false;

  void _draft() {
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
    Navigator.pushNamed(
      context,
      AppRoutes.cashier,
      arguments: CashierEntry(items: items),
    ).then((_) {
      if (mounted) setState(() => _saving = false);
    });
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
            action: CircleIconButton(
              icon: AppIcons.share,
              onHeader: true,
              medium: true,
              tooltip: 'Bagikan',
              onPressed: () {},
            ),
          ),
          Expanded(
            child: ListView(
              padding: AppInsets.page(
                context,
                top: AppSpacing.contentTopGap,
                bottom: AppSpacing.xl,
              ),
              children: [
                _MainResultCard(result: result, history: widget.history),
                const SizedBox(height: AppSpacing.md),
                _InfoCard(
                  color: _urgencySoft(result.urgensi),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        AppIcons.errorRounded,
                        color: _urgencyColor(result.urgensi),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Urgensi ${_urgencyLabel(result.urgensi)}',
                              style: AppText.subheading.copyWith(
                                color: _urgencyColor(result.urgensi),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(result.urgensiKeterangan, style: AppText.body),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'Solusi',
                  child: _BulletText(text: result.solusi),
                ),
                if (result.kemungkinanLain.isNotEmpty)
                  _SectionCard(
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
                if (result.komponenTerkait.isNotEmpty)
                  _SectionCard(
                    title: 'Komponen Terkait',
                    child: Column(
                      children: [
                        for (final item in result.komponenTerkait)
                          _RelatedRow(
                            name: item.nama,
                            category: item.nama,
                            price: item.harga,
                            productId: item.produkId,
                          ),
                      ],
                    ),
                  ),
                if (result.jasaTerkait.isNotEmpty)
                  _SectionCard(
                    title: 'Jasa Terkait',
                    child: Column(
                      children: [
                        for (final item in result.jasaTerkait)
                          _RelatedRow(
                            name: item.nama,
                            service: true,
                            price: item.harga,
                          ),
                      ],
                    ),
                  ),
                _InfoCard(
                  color: AppColors.primarySoft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Estimasi biaya',
                              style: AppText.subheading,
                            ),
                          ),
                          const PerkiraanLabel(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${formatRupiah(result.estimasiBiaya.min)} - ${formatRupiah(result.estimasiBiaya.max)}',
                        style: AppText.heading,
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        'Estimasi waktu ${result.estimasiWaktuMenit} menit',
                        style: AppText.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'Hasil ini alat bantu, bukan kepastian.',
                      style: AppText.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppBottomActionBar(
            stacked: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton.primary(
                  label: 'Buat Draft Transaksi',
                  icon: AppIcons.shoppingCart,
                  loading: _saving,
                  onPressed: _saving ? null : _draft,
                ),
                if (widget.history == null)
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.diagnosis,
                    ),
                    child: const Text('Diagnosis Ulang'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainResultCard extends StatelessWidget {
  const _MainResultCard({required this.result, this.history});
  final HasilDiagnosis result;
  final RiwayatDiagnosis? history;

  @override
  Widget build(BuildContext context) => _InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UrgencyIcon(level: _urgency(result.urgensi)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.kerusakanUtama.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  UrgensiBadge(level: _urgency(result.urgensi)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ConfidenceRing(value: result.kerusakanUtama.keyakinan),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${formatTanggalIndonesia(result.waktu)} · ${history?.penggunaNama ?? 'Mekanik'}',
          style: AppText.bodySmall,
        ),
        if (history != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _SymptomSummary(history: history!),
        ],
      ],
    ),
  );
}

class _SymptomSummary extends StatefulWidget {
  const _SymptomSummary({required this.history});
  final RiwayatDiagnosis history;

  @override
  State<_SymptomSummary> createState() => _SymptomSummaryState();
}

class _SymptomSummaryState extends State<_SymptomSummary> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${widget.history.gejala.length} gejala dipilih',
                style: AppText.bodySmall,
              ),
            ),
            Icon(
              _expanded ? AppIcons.keyboardArrowDown : AppIcons.chevronRight,
              size: AppSpacing.iconSmall,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
      if (_expanded)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final symptom in widget.history.gejala)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• ${symptom.nama}', style: AppText.bodySmall),
                ),
            ],
          ),
        ),
    ],
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child, this.color = AppColors.surface});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(padding: AppSpacing.cardInsets, child: child),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md),
    child: _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    ),
  );
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Container(
          width: AppSpacing.sm,
          height: AppSpacing.sm,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text, style: AppText.body)),
    ],
  );
}

class _RelatedRow extends StatelessWidget {
  const _RelatedRow({
    required this.name,
    required this.price,
    this.category,
    this.service = false,
    this.productId,
  });
  final String name;
  final String? category;
  final int price;
  final bool service;
  final int? productId;

  @override
  Widget build(BuildContext context) {
    final products = context.read<ProdukService?>();
    return FutureBuilder<List<Produk>>(
      future: products?.listProducts(),
      builder: (context, snapshot) {
        final product = snapshot.data
            ?.where((item) => item.id == productId)
            .firstOrNull;
        final stock = product?.stok;
        final status = stock == null
            ? null
            : stock == 0
            ? AppStatus.stokHabis
            : stock <= product!.stokMinimum
            ? AppStatus.stokMenipis
            : null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              CategoryIcon(
                category: category,
                service: service,
                size: AppSpacing.circleSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body,
                    ),
                    if (!service)
                      Wrap(
                        spacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Stok ${stock ?? '—'}',
                            style: AppText.bodySmall,
                          ),
                          if (status != null) StatusBadge(status: status),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(formatRupiah(price), style: AppText.subheading),
            ],
          ),
        );
      },
    );
  }
}

class _UrgencyIcon extends StatelessWidget {
  const _UrgencyIcon({required this.level});
  final Urgensi level;

  @override
  Widget build(BuildContext context) => Container(
    width: AppSpacing.catalogIconSize,
    height: AppSpacing.catalogIconSize,
    decoration: BoxDecoration(
      color: _urgencySoft(level.name),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
    child: Icon(AppIcons.errorRounded, color: _urgencyColor(level.name)),
  );
}

Urgensi _urgency(String value) => switch (value.toLowerCase()) {
  'rendah' => Urgensi.rendah,
  'tinggi' => Urgensi.tinggi,
  _ => Urgensi.sedang,
};

String _urgencyLabel(String value) => switch (value.toLowerCase()) {
  'rendah' => 'Rendah',
  'tinggi' => 'Tinggi',
  _ => 'Sedang',
};

Color _urgencyColor(String value) => switch (value.toLowerCase()) {
  'rendah' => AppColors.success,
  'tinggi' => AppColors.danger,
  _ => AppColors.warningText,
};

Color _urgencySoft(String value) => switch (value.toLowerCase()) {
  'rendah' => AppColors.successSoft,
  'tinggi' => AppColors.dangerSoft,
  _ => AppColors.warningSoft,
};
