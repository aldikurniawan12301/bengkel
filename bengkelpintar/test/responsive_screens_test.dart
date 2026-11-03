import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/core/config/server_config.dart';
import 'package:bengkelpintar/data/models/gejala.dart';
import 'package:bengkelpintar/data/models/hasil_diagnosis.dart';
import 'package:bengkelpintar/data/models/riwayat_diagnosis.dart';
import 'package:bengkelpintar/data/models/statistik_diagnosis.dart';
import 'package:bengkelpintar/data/models/mutasi_stok.dart';
import 'package:bengkelpintar/data/models/laporan_penjualan.dart';
import 'package:bengkelpintar/data/models/pengaturan_bengkel.dart';
import 'package:bengkelpintar/data/models/kerusakan.dart';
import 'package:bengkelpintar/data/models/jasa.dart';
import 'package:bengkelpintar/data/models/produk.dart';
import 'package:bengkelpintar/data/models/transaksi.dart';
import 'package:bengkelpintar/data/models/user.dart';
import 'package:bengkelpintar/features/auth/splash_screen.dart';
import 'package:bengkelpintar/features/auth/login_screen.dart';
import 'package:bengkelpintar/features/auth/server_settings_screen.dart';
import 'package:bengkelpintar/features/home/home_screen.dart';
import 'package:bengkelpintar/features/diagnosis/symptom_screen.dart';
import 'package:bengkelpintar/features/diagnosis/diagnosis_result_screen.dart';
import 'package:bengkelpintar/features/diagnosis/history_screen.dart';
import 'package:bengkelpintar/features/pos/draft_screen.dart';
import 'package:bengkelpintar/features/pos/transaction_list_screen.dart';
import 'package:bengkelpintar/features/pos/finalization_screen.dart';
import 'package:bengkelpintar/features/pos/catalog_screen.dart';
import 'package:bengkelpintar/features/admin/data_master_screen.dart';
import 'package:bengkelpintar/features/admin/user_list_screen.dart';
import 'package:bengkelpintar/features/laporan/sales_report_screen.dart';
import 'package:bengkelpintar/features/admin/profile_screen.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _ResponsiveAuth implements AuthService {
  @override
  Future<User?> currentUser() async =>
      const User(id: 1, nama: 'Andi Pratama', peran: 'admin');
  @override
  Future<User?> login(String username, String password) async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async =>
      true;
}

class _ResponsiveDiagnosis implements DiagnosisService {
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

class _ResponsiveMaster implements KerusakanService {
  @override
  Future<List<Gejala>> listGejala({String? query}) async => const [];
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

class _ResponsiveTransactions implements TransaksiService {
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

class _ResponsiveProducts implements ProdukService {
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

class _ResponsiveServices implements JasaService {
  @override
  Future<List<Jasa>> listServices({String? query}) async => const [];
  @override
  Future<Jasa> addService(Jasa item) async => item;
  @override
  Future<Jasa> updateService(Jasa item) async => item;
  @override
  Future<void> deactivateService(int id) async {}
}

class _ResponsiveUsers implements PenggunaService {
  @override
  Future<List<User>> listUsers({String? query}) async => const [];
  @override
  Future<User> addUser(User item) async => item;
  @override
  Future<User> updateUser(User item) async => item;
  @override
  Future<void> deactivateUser(int id) async {}
  @override
  Future<bool> resetPassword(int id, String newPassword) async => true;
}

class _ResponsiveWorkshop implements PengaturanBengkelService {
  @override
  Future<PengaturanBengkel> getSettings() async => const PengaturanBengkel(
    id: 1,
    nama: 'Bengkel Maju Jaya',
    alamat: 'Jl. Merdeka No. 12, Bandung',
    telepon: '0812-3456-7890',
  );
  @override
  Future<PengaturanBengkel> updateSettings(PengaturanBengkel item) async =>
      item;
}

class _ResponsiveReports implements LaporanService {
  @override
  Future<LaporanPenjualan> salesReport({
    required String periodeMulai,
    required String periodeSelesai,
  }) async => LaporanPenjualan(
    periodeMulai: periodeMulai,
    periodeSelesai: periodeSelesai,
    totalPenjualan: 0,
    jumlahTransaksi: 0,
    rataRata: 0,
    penjualanPerHari: const [],
    terlaris: const [],
  );
}

HasilDiagnosis _result() => HasilDiagnosis(
  riwayatId: 1,
  kerusakanUtama: const KerusakanPrediksi(
    id: 1,
    nama: 'Busi kotor / aus',
    keyakinan: .78,
  ),
  kemungkinanLain: const [],
  urgensi: 'sedang',
  urgensiKeterangan: 'Masih bisa dipakai, segera cek',
  solusi: 'Bersihkan atau ganti busi',
  estimasiWaktuMenit: 15,
  komponenTerkait: const [],
  jasaTerkait: const [],
  estimasiBiaya: const EstimasiBiaya(
    min: 30000,
    max: 80000,
    keterangan: 'Perkiraan',
  ),
  waktu: DateTime(2026, 10, 24, 10, 15),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final screens = <String, Widget>{
    '1 Splash': const SplashScreen(sessionCheckDelay: Duration.zero),
    '2 Server': const ServerSettingsScreen(),
    '3 Login': const LoginScreen(),
    '4 Home': const HomeScreen(role: UserRole.admin),
    '5 Symptoms': const SymptomScreen(),
    '6 Result': DiagnosisResultScreen(result: _result()),
    '7 History': const HistoryScreen(),
    '8 Draft': DraftScreen(transaction: _transaction()),
    '9 Transactions': const TransactionListScreen(),
    '10 Payment': FinalizationScreen(transaction: _transaction()),
    '11 Catalog': const CatalogScreen(),
    '12 Services': const CatalogScreen(services: true),
    '13 Master': const DataMasterScreen(),
    '14 Users': const UserListScreen(),
    '15 Reports': const SalesReportScreen(),
    '16 Profile': const ProfileScreen(),
  };

  for (final width in [320.0, 360.0, 412.0]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} aman di $width dp pada teks 130%', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        final serverConfig = await ServerConfig.load();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 800);
        tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
        tester.view.platformDispatcher.textScaleFactorTestValue = 1.3;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => RoleProvider()..setRole(UserRole.admin),
              ),
              Provider<AuthService>.value(value: _ResponsiveAuth()),
              Provider<DiagnosisService>.value(value: _ResponsiveDiagnosis()),
              Provider<KerusakanService>.value(value: _ResponsiveMaster()),
              Provider<TransaksiService>.value(
                value: _ResponsiveTransactions(),
              ),
              Provider<ProdukService>.value(value: _ResponsiveProducts()),
              Provider<JasaService>.value(value: _ResponsiveServices()),
              ChangeNotifierProvider<ServerConfig>.value(value: serverConfig),
              Provider<PengaturanBengkelService>.value(
                value: _ResponsiveWorkshop(),
              ),
              Provider<PenggunaService>.value(value: _ResponsiveUsers()),
              Provider<LaporanService>.value(value: _ResponsiveReports()),
            ],
            child: MaterialApp(theme: AppTheme.light, home: entry.value),
          ),
        );
        await tester.pump(const Duration(milliseconds: 20));
        expect(tester.takeException(), isNull);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.viewPadding = FakeViewPadding.zero;
        tester.view.platformDispatcher.clearTextScaleFactorTestValue();
      });
    }
  }
}

Transaksi _transaction() => Transaksi(
  id: 105,
  nomor: 'TRX-0105',
  status: 'draft',
  namaPelanggan: 'Dedi Kurniawan',
  platNomor: 'D 1234 XX',
  total: 45000,
  dibuatOleh: 'Budi Santoso',
  dibuatOlehId: 2,
  waktu: DateTime(2026, 10, 24, 10, 15),
  items: [
    ItemTransaksi(
      id: 1,
      tipe: 'produk',
      produkId: 1,
      nama: 'Busi NGK Standar',
      jumlah: 1,
      hargaSatuan: 25000,
      subtotal: 25000,
    ),
  ],
);
