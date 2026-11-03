import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/models/gejala.dart';
import 'package:bengkelpintar/data/models/hasil_diagnosis.dart';
import 'package:bengkelpintar/data/models/jasa.dart';
import 'package:bengkelpintar/data/models/kategori.dart';
import 'package:bengkelpintar/data/models/kerusakan.dart';
import 'package:bengkelpintar/data/models/laporan_penjualan.dart';
import 'package:bengkelpintar/data/models/mutasi_stok.dart';
import 'package:bengkelpintar/data/models/pengaturan_bengkel.dart';
import 'package:bengkelpintar/data/models/produk.dart';
import 'package:bengkelpintar/data/models/riwayat_diagnosis.dart';
import 'package:bengkelpintar/data/models/transaksi.dart';
import 'package:bengkelpintar/data/models/user.dart';
import 'package:bengkelpintar/data/models/statistik_diagnosis.dart';
import 'package:bengkelpintar/features/admin/category_screen.dart';
import 'package:bengkelpintar/features/admin/change_password_screen.dart';
import 'package:bengkelpintar/features/admin/data_master_screen.dart';
import 'package:bengkelpintar/features/admin/profile_screen.dart';
import 'package:bengkelpintar/features/admin/server_unreachable_screen.dart';
import 'package:bengkelpintar/features/admin/symptom_list_screen.dart';
import 'package:bengkelpintar/features/admin/user_list_screen.dart';
import 'package:bengkelpintar/features/admin/workshop_settings_screen.dart';
import 'package:bengkelpintar/features/diagnosis/history_screen.dart';
import 'package:bengkelpintar/features/laporan/diagnosis_statistics_screen.dart';
import 'package:bengkelpintar/features/laporan/sales_report_screen.dart';
import 'package:bengkelpintar/features/pos/catalog_screen.dart';
import 'package:bengkelpintar/features/pos/draft_screen.dart';
import 'package:bengkelpintar/features/pos/finalization_screen.dart';
import 'package:bengkelpintar/features/pos/product_detail_screen.dart';
import 'package:bengkelpintar/features/pos/transaction_detail_screen.dart';
import 'package:bengkelpintar/features/pos/transaction_list_screen.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _Diagnosis implements DiagnosisService {
  @override
  Future<HasilDiagnosis?> diagnose(List<int> ids) async => null;
  @override
  Future<List<RiwayatDiagnosis>> listHistory() async => const [];
  @override
  Future<RiwayatDiagnosis?> getHistory(int id) async => null;
  @override
  Future<StatistikDiagnosis> getStatistics() async =>
      const StatistikDiagnosis(total: 0, items: []);
}

class _Products implements ProdukService {
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
  }) async => const Produk(
    id: 1,
    nama: 'Busi NGK Standar',
    kategoriId: 1,
    kategoriNama: 'Pengapian',
    harga: 25000,
    stok: 4,
    stokMinimum: 5,
    aktif: true,
  );
  @override
  Future<List<MutasiStok>> listStockMovements(int id) async => const [];
}

class _Services implements JasaService {
  @override
  Future<List<Jasa>> listServices({String? query}) async => const [];
  @override
  Future<Jasa> addService(Jasa item) async => item;
  @override
  Future<Jasa> updateService(Jasa item) async => item;
  @override
  Future<void> deactivateService(int id) async {}
}

class _Transactions implements TransaksiService {
  @override
  Future<Transaksi> createDraft({
    required String namaPelanggan,
    required String platNomor,
    required List<ItemTransaksiRequest> items,
    int? riwayatDiagnosisId,
  }) async => _transaction;
  @override
  Future<Transaksi> updateDraft(Transaksi item) async => item;
  @override
  Future<List<Transaksi>> listTransactions({
    String? status,
    String? query,
  }) async => const [];
  @override
  Future<Transaksi?> getTransaction(int id) async => _transaction;
  @override
  Future<Transaksi> finalizeTransaction(
    int id, {
    required String metodeBayar,
    required int jumlahDibayar,
  }) async => _transaction;
  @override
  Future<Transaksi?> getReceipt(int id) async => _transaction;
}

class _Reports implements LaporanService {
  @override
  Future<LaporanPenjualan> salesReport({
    required String periodeMulai,
    required String periodeSelesai,
  }) async => const LaporanPenjualan(
    periodeMulai: '2026-10-23',
    periodeSelesai: '2026-10-24',
    totalPenjualan: 0,
    jumlahTransaksi: 0,
    rataRata: 0,
    penjualanPerHari: [],
    terlaris: [],
  );
}

class _Users implements PenggunaService {
  @override
  Future<List<User>> listUsers({String? query}) async => const [];
  @override
  Future<User> addUser(User item) async => item;
  @override
  Future<User> updateUser(User item) async => item;
  @override
  Future<void> deactivateUser(int id) async {}
  @override
  Future<bool> resetPassword(int id, String password) async => true;
}

class _Master implements KerusakanService {
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

class _Categories implements KategoriService {
  @override
  Future<List<Kategori>> listCategories({String? query}) async => const [];
  @override
  Future<Kategori> addCategory(Kategori item) async => item;
  @override
  Future<Kategori> updateCategory(Kategori item) async => item;
  @override
  Future<void> deactivateCategory(int id) async {}
}

class _Workshop implements PengaturanBengkelService {
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

class _Auth implements AuthService {
  @override
  Future<User?> login(String username, String password) async =>
      const User(id: 1, nama: 'Andi Pratama', peran: 'admin');
  @override
  Future<User?> currentUser() async =>
      const User(id: 1, nama: 'Andi Pratama', peran: 'admin');
  @override
  Future<void> logout() async {}
  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async =>
      true;
}

final _transaction = Transaksi(
  id: 105,
  nomor: 'TRX-0105',
  status: 'draft',
  namaPelanggan: 'Dedi Kurniawan',
  platNomor: 'D 1234 XX',
  total: 0,
  dibuatOleh: 'Andi Pratama',
  dibuatOlehId: 1,
  waktu: DateTime(2026, 10, 24),
  items: const [],
);
final _product = const Produk(
  id: 1,
  nama: 'Busi NGK Standar',
  kategoriId: 1,
  kategoriNama: 'Pengapian',
  harga: 25000,
  stok: 4,
  stokMinimum: 5,
  aktif: true,
);

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  final view = tester.view;
  view.devicePixelRatio = 1;
  view.physicalSize = const Size(320, 800);
  view.platformDispatcher.textScaleFactorTestValue = 1.3;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: _Auth()),
        Provider<DiagnosisService>.value(value: _Diagnosis()),
        Provider<ProdukService>.value(value: _Products()),
        Provider<JasaService>.value(value: _Services()),
        Provider<TransaksiService>.value(value: _Transactions()),
        Provider<LaporanService>.value(value: _Reports()),
        Provider<PenggunaService>.value(value: _Users()),
        Provider<KerusakanService>.value(value: _Master()),
        Provider<KategoriService>.value(value: _Categories()),
        Provider<PengaturanBengkelService>.value(value: _Workshop()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1));
  expect(tester.takeException(), isNull);
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  view.resetPhysicalSize();
  view.resetDevicePixelRatio();
  view.platformDispatcher.clearTextScaleFactorTestValue();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'T-11 riwayat diagnosis tidak overflow',
    (t) async => pumpScreen(t, const HistoryScreen()),
  );
  testWidgets(
    'T-12 draft diagnosis tidak overflow',
    (t) async => pumpScreen(t, const DraftScreen()),
  );
  testWidgets(
    'T-13 draft transaksi tidak overflow',
    (t) async => pumpScreen(t, const DraftScreen()),
  );
  testWidgets(
    'T-14 daftar transaksi tidak overflow',
    (t) async => pumpScreen(t, const TransactionListScreen()),
  );
  testWidgets(
    'T-15 finalisasi dan nota tidak overflow',
    (t) async => pumpScreen(t, FinalizationScreen(transaction: _transaction)),
  );
  testWidgets(
    'T-16 katalog produk tidak overflow',
    (t) async => pumpScreen(t, const CatalogScreen()),
  );
  testWidgets(
    'T-17 katalog jasa tidak overflow',
    (t) async => pumpScreen(t, const CatalogScreen(services: true)),
  );
  testWidgets(
    'T-18 detail stok tidak overflow',
    (t) async => pumpScreen(t, ProductDetailScreen(product: _product)),
  );
  testWidgets(
    'T-19 menu data master tidak overflow',
    (t) async => pumpScreen(t, const DataMasterScreen()),
  );
  testWidgets(
    'T-20 kelola pengguna tidak overflow',
    (t) async => pumpScreen(t, const UserListScreen()),
  );
  testWidgets(
    'T-21 laporan penjualan tidak overflow',
    (t) async => pumpScreen(t, const SalesReportScreen()),
  );
  testWidgets(
    'T-22 statistik diagnosis tidak overflow',
    (t) async => pumpScreen(t, const DiagnosisStatisticsScreen()),
  );
  testWidgets(
    'T-23 profil tidak overflow',
    (t) async => pumpScreen(t, const ProfileScreen()),
  );
  testWidgets(
    'T-24 server unreachable tidak overflow',
    (t) async => pumpScreen(t, const ServerUnreachableScreen()),
  );
  testWidgets(
    'T-26 pengaturan bengkel tidak overflow',
    (t) async => pumpScreen(t, const WorkshopSettingsScreen()),
  );
  testWidgets(
    'T-27 ganti password tidak overflow',
    (t) async => pumpScreen(t, const ChangePasswordScreen()),
  );
  testWidgets(
    'T-28 error server tidak overflow',
    (t) async => pumpScreen(t, const ServerUnreachableScreen()),
  );
  testWidgets(
    'T-29 daftar gejala tidak overflow',
    (t) async => pumpScreen(t, const SymptomListScreen()),
  );
  testWidgets(
    'T-30 kategori produk tidak overflow',
    (t) async => pumpScreen(t, const CategoryScreen()),
  );
  testWidgets(
    'T-14 detail transaksi tidak overflow',
    (t) async =>
        pumpScreen(t, TransactionDetailScreen(transaction: _transaction)),
  );
}
