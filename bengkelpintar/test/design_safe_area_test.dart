import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/models/gejala.dart';
import 'package:bengkelpintar/data/models/hasil_diagnosis.dart';
import 'package:bengkelpintar/data/models/kerusakan.dart';
import 'package:bengkelpintar/data/models/jasa.dart';
import 'package:bengkelpintar/data/models/produk.dart';
import 'package:bengkelpintar/data/models/riwayat_diagnosis.dart';
import 'package:bengkelpintar/data/models/transaksi.dart';
import 'package:bengkelpintar/features/diagnosis/diagnosis_result_screen.dart';
import 'package:bengkelpintar/features/diagnosis/symptom_screen.dart';
import 'package:bengkelpintar/features/home/home_screen.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';
import 'package:bengkelpintar/data/models/statistik_diagnosis.dart';
import 'package:bengkelpintar/data/models/mutasi_stok.dart';

class _DesignDiagnosis implements DiagnosisService {
  @override
  Future<HasilDiagnosis?> diagnose(List<int> gejalaIds) async => null;
  @override
  Future<List<RiwayatDiagnosis>> listHistory() async => const [];
  @override
  Future<RiwayatDiagnosis?> getHistory(int id) async => null;
  @override
  Future<StatistikDiagnosis> getStatistics() async =>
      const StatistikDiagnosis(total: 0, items: []);
}

class _DesignMaster implements KerusakanService {
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
      id: 2,
      kode: 'G02',
      nama: 'Mesin mati mendadak',
      kategori: 'Mesin',
      aktif: true,
    ),
  ];
  @override
  Future<List<Kerusakan>> listKerusakan({String? query}) async => const [];
  @override
  Future<Gejala> addGejala(Gejala item) async => item;
  @override
  Future<Gejala> updateGejala(Gejala item) async => item;
  @override
  Future<void> deactivateGejala(int id) async {}
  @override
  Future<Kerusakan> addKerusakan(Kerusakan item) async => item;
  @override
  Future<Kerusakan> updateKerusakan(Kerusakan item) async => item;
  @override
  Future<void> deactivateKerusakan(int id) async {}
}

class _DesignTransactions implements TransaksiService {
  @override
  Future<Transaksi> createDraft({
    required String namaPelanggan,
    required String platNomor,
    required List<ItemTransaksiRequest> items,
    int? riwayatDiagnosisId,
  }) async => throw StateError('not used');
  @override
  Future<Transaksi> updateDraft(Transaksi item) async => item;
  @override
  Future<List<Transaksi>> listTransactions({
    String? status,
    String? query,
  }) async => const [];
  @override
  Future<Transaksi?> getTransaction(int id) async => null;
  @override
  Future<Transaksi> finalizeTransaction(
    int id, {
    required String metodeBayar,
    required int jumlahDibayar,
  }) async => throw StateError('not used');
  @override
  Future<Transaksi?> getReceipt(int id) async => null;
}

class _NoopProduct implements ProdukService {
  @override
  Future<List<Produk>> listProducts({String? query}) async => const [];
  @override
  Future<Produk> addProduct(Produk item) async => item;
  @override
  Future<Produk> updateProduct(Produk item) async => item;
  @override
  Future<void> deactivateProduct(int id) async {}
  @override
  Future<Produk> adjustStock(
    int id, {
    required int jumlah,
    required String alasan,
  }) async => throw StateError('not used');
  @override
  Future<List<MutasiStok>> listStockMovements(int id) async => const [];
}

class _NoopService implements JasaService {
  @override
  Future<List<Jasa>> listServices({String? query}) async => const [];
  @override
  Future<Jasa> addService(Jasa item) async => item;
  @override
  Future<Jasa> updateService(Jasa item) async => item;
  @override
  Future<void> deactivateService(int id) async {}
}

HasilDiagnosis _result() => HasilDiagnosis(
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
  komponenTerkait: const [
    KomponenTerkait(produkId: 1, nama: 'Busi NGK Standar', harga: 25000),
  ],
  jasaTerkait: const [JasaTerkait(jasaId: 1, nama: 'Ganti busi', harga: 20000)],
  estimasiBiaya: const EstimasiBiaya(
    min: 45000,
    max: 80000,
    keterangan: 'Perkiraan',
  ),
  waktu: DateTime(2026, 10, 30),
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool role = false,
  bool diagnosis = false,
  bool master = false,
  bool transactions = false,
}) async {
  final view = tester.view;
  view.devicePixelRatio = 1;
  view.physicalSize = const Size(320, 800);
  view.viewPadding = const FakeViewPadding(
    left: 8,
    top: 48,
    right: 8,
    bottom: 34,
  );
  view.viewInsets = const FakeViewPadding(bottom: 0);
  view.platformDispatcher.textScaleFactorTestValue = 1.3;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        if (role)
          ChangeNotifierProvider(
            create: (_) => RoleProvider()..setRole(UserRole.admin),
          ),
        if (diagnosis)
          Provider<DiagnosisService>.value(value: _DesignDiagnosis()),
        if (master) Provider<KerusakanService>.value(value: _DesignMaster()),
        if (transactions)
          Provider<TransaksiService>.value(value: _DesignTransactions()),
        if (transactions) Provider<ProdukService>.value(value: _NoopProduct()),
        if (transactions) Provider<JasaService>.value(value: _NoopService()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
  await tester.pump(const Duration(milliseconds: 20));
  expect(tester.takeException(), isNull);
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  view.resetPhysicalSize();
  view.resetDevicePixelRatio();
  view.viewPadding = FakeViewPadding.zero;
  view.viewInsets = FakeViewPadding.zero;
  view.platformDispatcher.clearTextScaleFactorTestValue();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('beranda aman dengan notch, gesture bar dan teks 130%', (
    tester,
  ) async {
    await _pump(
      tester,
      const HomeScreen(role: UserRole.admin),
      role: true,
      diagnosis: true,
    );
  });

  testWidgets('form gejala aman saat keyboard memakai inset bawah', (
    tester,
  ) async {
    await _pump(tester, const SymptomScreen(), diagnosis: true, master: true);
  });

  testWidgets('hasil diagnosis aman pada layar sempit dan inset besar', (
    tester,
  ) async {
    await _pump(
      tester,
      DiagnosisResultScreen(result: _result()),
      transactions: true,
    );
  });

  testWidgets('form gejala tidak overflow saat keyboard benar-benar tampil', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(320, 800);
    view.viewPadding = const FakeViewPadding(top: 48, bottom: 34);
    view.viewInsets = const FakeViewPadding(bottom: 300);
    view.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DiagnosisService>.value(value: _DesignDiagnosis()),
          Provider<KerusakanService>.value(value: _DesignMaster()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SymptomScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.viewPadding = FakeViewPadding.zero;
    view.viewInsets = FakeViewPadding.zero;
    view.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
