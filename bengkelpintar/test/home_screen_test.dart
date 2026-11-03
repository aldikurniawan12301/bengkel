import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/theme/app_icons.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/models/gejala.dart';
import 'package:bengkelpintar/data/models/hasil_diagnosis.dart';
import 'package:bengkelpintar/data/models/riwayat_diagnosis.dart';
import 'package:bengkelpintar/data/models/statistik_diagnosis.dart';
import 'package:bengkelpintar/features/home/home_screen.dart';
import 'package:bengkelpintar/core/theme/app_spacing.dart';
import 'package:bengkelpintar/core/widgets/home_stat_card.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _HomeDiagnosisService implements DiagnosisService {
  @override
  Future<HasilDiagnosis?> diagnose(List<int> gejalaIds) async => null;

  @override
  Future<RiwayatDiagnosis?> getHistory(int id) async => _history;

  @override
  Future<List<RiwayatDiagnosis>> listHistory() async => [_history];

  @override
  Future<StatistikDiagnosis> getStatistics() async =>
      const StatistikDiagnosis(total: 1, items: []);
}

final _history = RiwayatDiagnosis(
  id: 1,
  penggunaId: 2,
  penggunaNama: 'Budi Santoso',
  gejala: const [
    Gejala(
      id: 1,
      kode: 'G01',
      nama: 'Mesin sulit hidup',
      kategori: 'Mesin',
      aktif: true,
    ),
  ],
  hasil: HasilDiagnosis(
    riwayatId: 1,
    kerusakanUtama: const KerusakanPrediksi(
      id: 1,
      nama: 'Busi kotor / aus',
      keyakinan: .82,
    ),
    kemungkinanLain: const [],
    urgensi: 'sedang',
    urgensiKeterangan: 'Periksa sebelum digunakan kembali.',
    solusi: 'Bersihkan atau ganti busi.',
    estimasiWaktuMenit: 30,
    komponenTerkait: const [],
    jasaTerkait: const [],
    estimasiBiaya: const EstimasiBiaya(
      min: 25000,
      max: 50000,
      keterangan: 'Perkiraan biaya',
    ),
    waktu: DateTime(2026, 10, 31, 9, 5),
  ),
  keyakinan: .82,
  waktu: DateTime(2026, 10, 31, 9, 5),
);

Future<void> _pumpHome(
  WidgetTester tester, {
  required UserRole role,
  double width = 320,
  double textScale = 1.3,
  RouteFactory? onGenerateRoute,
}) async {
  final view = tester.view;
  view.devicePixelRatio = 1;
  view.physicalSize = Size(width, 800);
  view.platformDispatcher.textScaleFactorTestValue = textScale;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()..setRole(role)),
        Provider<DiagnosisService>.value(value: _HomeDiagnosisService()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: HomeScreen(role: role),
        onGenerateRoute: onGenerateRoute,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump(const Duration(milliseconds: 20));
}

Future<void> _disposeHome(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
  tester.view.platformDispatcher.clearTextScaleFactorTestValue();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Beranda admin menampilkan menu lain dan diagnosis terbaru', (
    tester,
  ) async {
    await _pumpHome(tester, role: UserRole.admin);

    expect(find.byIcon(AppIcons.barChart), findsAtLeastNWidgets(1));
    expect(find.byIcon(AppIcons.roundedPerson), findsAtLeastNWidgets(1));
    expect(find.byIcon(AppIcons.factCheckRounded), findsOneWidget);
    expect(find.text('Menu lain'), findsOneWidget);
    expect(find.text('Stok menipis'), findsAtLeastNWidgets(1));
    expect(find.text('Laporan'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeHome(tester);
  });

  testWidgets('Beranda mekanik menampilkan statistik dan menu sesuai peran', (
    tester,
  ) async {
    await _pumpHome(tester, role: UserRole.mechanic);

    expect(find.text('Draft Saya'), findsOneWidget);
    expect(find.text('Riwayat'), findsAtLeastNWidgets(1));
    expect(find.text('Transaksi'), findsNothing);
    expect(find.text('Produk'), findsNothing);
    expect(find.byIcon(AppIcons.history), findsAtLeastNWidgets(1));
    expect(find.text('Draft saya'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeHome(tester);
  });

  testWidgets('empat kartu statistik sama tinggi pada 320 dp dan teks 130%', (
    tester,
  ) async {
    await _pumpHome(tester, role: UserRole.admin, textScale: 1);
    final cards = find.byType(HomeStatCard);
    expect(cards, findsNWidgets(4));
    final heights = [
      for (final element in cards.evaluate())
        tester
            .getSize(
              find.byElementPredicate((candidate) => candidate == element),
            )
            .height,
    ];
    expect(heights.toSet(), hasLength(1));
    expect(
      heights.first,
      lessThanOrEqualTo(AppSpacing.homeStatLargeTextHeight),
    );
    expect(find.text('Diagnosis'), findsAtLeastNWidgets(1));
    expect(find.text('Draft'), findsAtLeastNWidgets(1));
    expect(find.text('Final'), findsAtLeastNWidgets(1));
    expect(find.text('Stok menipis'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
    await _disposeHome(tester);
  });

  testWidgets('Beranda menghapus banner Diagnosis Cepat', (tester) async {
    await _pumpHome(
      tester,
      role: UserRole.admin,
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => const Text('Form Gejala'),
      ),
    );
    expect(find.text('DIAGNOSIS CEPAT'), findsNothing);
    expect(find.text('Mau diagnosis apa hari ini?'), findsNothing);
    expect(find.text('Ringkasan Hari Ini'), findsNothing);
    await _disposeHome(tester);
  });

  testWidgets('Beranda tidak overflow pada 320, 360, dan 412 dp', (
    tester,
  ) async {
    for (final width in [320.0, 360.0, 412.0]) {
      await _pumpHome(tester, role: UserRole.admin, width: width);
      expect(tester.takeException(), isNull);
      await _disposeHome(tester);
    }
  });
}
