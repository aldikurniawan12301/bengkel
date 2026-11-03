import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/mock_diagnosis.dart';
import 'package:bengkelpintar/data/models/gejala.dart';
import 'package:bengkelpintar/data/models/hasil_diagnosis.dart';
import 'package:bengkelpintar/data/models/kerusakan.dart';
import 'package:bengkelpintar/data/models/riwayat_diagnosis.dart';
import 'package:bengkelpintar/data/models/statistik_diagnosis.dart';
import 'package:bengkelpintar/features/diagnosis/diagnosis_result_screen.dart';
import 'package:bengkelpintar/features/diagnosis/symptom_screen.dart';
import 'package:bengkelpintar/core/widgets/app_checkbox.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _DiagnosisService implements DiagnosisService {
  List<int>? receivedIds;

  @override
  Future<HasilDiagnosis?> diagnose(List<int> gejalaIds) async {
    receivedIds = gejalaIds;
    return null;
  }

  @override
  Future<List<RiwayatDiagnosis>> listHistory() async => const [];

  @override
  Future<RiwayatDiagnosis?> getHistory(int id) async => null;
  @override
  Future<StatistikDiagnosis> getStatistics() async =>
      const StatistikDiagnosis(total: 0, items: []);
}

class _GejalaService implements KerusakanService {
  @override
  Future<List<Gejala>> listGejala({String? query}) async => const [
    Gejala(
      id: 1,
      kode: 'G01',
      nama: 'Mesin susah dihidupkan',
      kategori: 'Mesin',
      aktif: true,
    ),
    Gejala(
      id: 3,
      kode: 'G03',
      nama: 'Tarikan berat',
      kategori: 'Mesin',
      aktif: true,
    ),
    Gejala(
      id: 4,
      kode: 'G04',
      nama: 'Knalpot berasap putih',
      kategori: 'Mesin',
      aktif: true,
    ),
  ];

  @override
  Future<List<Kerusakan>> listKerusakan({String? query}) async => const [];
  @override
  Future<Gejala> addGejala(Gejala gejala) async => gejala;
  @override
  Future<Gejala> updateGejala(Gejala gejala) async => gejala;
  @override
  Future<void> deactivateGejala(int id) async {}
  @override
  Future<Kerusakan> addKerusakan(Kerusakan kerusakan) async => kerusakan;
  @override
  Future<Kerusakan> updateKerusakan(Kerusakan kerusakan) async => kerusakan;
  @override
  Future<void> deactivateKerusakan(int id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('T-09 memilih G01 G03 G04 mengirim gejala_ids', (tester) async {
    final diagnosis = _DiagnosisService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<KerusakanService>.value(value: _GejalaService()),
          Provider<DiagnosisService>.value(value: diagnosis),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SymptomScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('G01'), findsNothing);
    expect(find.text('Diagnosis'), findsOneWidget);
    await tester.tap(find.byType(AppCheckbox).at(0));
    await tester.pump();
    await tester.tap(find.byType(AppCheckbox).at(1));
    await tester.pump();
    await tester.tap(find.byType(AppCheckbox).at(2));
    await tester.pump();
    await tester.tap(find.text('Diagnosis'));
    await tester.pump(const Duration(milliseconds: 10));
    expect(diagnosis.receivedIds, containsAllInOrder([1, 3, 4]));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('T-09 tidak overflow 320 dp pada teks 130%', (tester) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(320, 800);
    view.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<KerusakanService>.value(value: _GejalaService()),
          Provider<DiagnosisService>.value(value: _DiagnosisService()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SymptomScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 10));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.platformDispatcher.clearTextScaleFactorTestValue();
  });

  testWidgets('T-10 menampilkan hasil diagnosis contoh lengkap', (
    tester,
  ) async {
    final damages = <Kerusakan>[
      const Kerusakan(
        id: 1,
        kode: 'K01',
        nama: 'Busi kotor / aus',
        urgensi: 'sedang',
        solusi: 'Bersihkan atau ganti busi',
        estimasiWaktuMenit: 15,
        aktif: true,
        komponenTerkait: [
          KomponenTerkait(produkId: 1, nama: 'Busi NGK Standar', harga: 25000),
          KomponenTerkait(produkId: 2, nama: 'Kabel Busi', harga: 35000),
        ],
        jasaTerkait: [JasaTerkait(jasaId: 1, nama: 'Ganti busi', harga: 20000)],
      ),
      const Kerusakan(
        id: 2,
        kode: 'K02',
        nama: 'Karburator kotor',
        urgensi: 'sedang',
        solusi: 'Bersihkan karburator',
        estimasiWaktuMenit: 45,
        aktif: true,
        komponenTerkait: [],
        jasaTerkait: [],
      ),
      const Kerusakan(
        id: 3,
        kode: 'K03',
        nama: 'Aki lemah',
        urgensi: 'sedang',
        solusi: 'Isi ulang atau ganti aki',
        estimasiWaktuMenit: 20,
        aktif: true,
        komponenTerkait: [],
        jasaTerkait: [],
      ),
    ];
    final result = diagnoseMock(
      gejalaCodes: const {'G01', 'G03', 'G04'},
      kerusakan: damages,
      waktu: DateTime(2026, 10, 24, 10, 15),
      riwayatId: 31,
    )!;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DiagnosisResultScreen(result: result),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Busi kotor / aus'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('Karburator kotor'), findsOneWidget);
    expect(find.text('15%'), findsOneWidget);
    expect(find.text('Aki lemah'), findsOneWidget);
    expect(find.text('7%'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();
    expect(find.textContaining('30'), findsAtLeastNWidgets(1));
    expect(find.textContaining('80'), findsAtLeastNWidgets(1));
    expect(find.text('Perkiraan'), findsOneWidget);
    expect(find.textContaining('15 menit'), findsOneWidget);
    expect(find.text('Diagnosis Ulang'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('T-10 tidak overflow 320 dp pada teks 130%', (tester) async {
    final damages = <Kerusakan>[
      const Kerusakan(
        id: 1,
        kode: 'K01',
        nama: 'Busi kotor / aus',
        urgensi: 'sedang',
        solusi: 'Bersihkan atau ganti busi',
        estimasiWaktuMenit: 15,
        aktif: true,
        komponenTerkait: [
          KomponenTerkait(produkId: 1, nama: 'Busi NGK Standar', harga: 25000),
          KomponenTerkait(produkId: 2, nama: 'Kabel Busi', harga: 35000),
        ],
        jasaTerkait: [JasaTerkait(jasaId: 1, nama: 'Ganti busi', harga: 20000)],
      ),
      const Kerusakan(
        id: 2,
        kode: 'K02',
        nama: 'Karburator kotor',
        urgensi: 'sedang',
        solusi: 'Bersihkan karburator',
        estimasiWaktuMenit: 45,
        aktif: true,
        komponenTerkait: [],
        jasaTerkait: [],
      ),
      const Kerusakan(
        id: 3,
        kode: 'K03',
        nama: 'Aki lemah',
        urgensi: 'sedang',
        solusi: 'Isi ulang atau ganti aki',
        estimasiWaktuMenit: 20,
        aktif: true,
        komponenTerkait: [],
        jasaTerkait: [],
      ),
    ];
    final result = diagnoseMock(
      gejalaCodes: const {'G01', 'G03', 'G04'},
      kerusakan: damages,
      waktu: DateTime(2026, 10, 24, 10, 15),
      riwayatId: 31,
    )!;
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(320, 800);
    view.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DiagnosisResultScreen(result: result),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
