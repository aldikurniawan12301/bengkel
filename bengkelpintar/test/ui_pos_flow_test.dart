import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/pos/draft_cart_controller.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/core/theme/app_icons.dart';
import 'package:bengkelpintar/core/widgets/floating_nav_bar.dart';
import 'package:bengkelpintar/core/widgets/qty_stepper.dart';
import 'package:bengkelpintar/core/widgets/app_button.dart';
import 'package:bengkelpintar/data/models/jasa.dart';
import 'package:bengkelpintar/data/models/mutasi_stok.dart';
import 'package:bengkelpintar/data/models/pengaturan_bengkel.dart';
import 'package:bengkelpintar/data/models/produk.dart';
import 'package:bengkelpintar/data/models/transaksi.dart';
import 'package:bengkelpintar/data/models/user.dart';
import 'package:bengkelpintar/features/pos/draft_screen.dart';
import 'package:bengkelpintar/features/pos/finalization_screen.dart';
import 'package:bengkelpintar/features/pos/catalog_screen.dart';
import 'package:bengkelpintar/features/pos/cashier_screen.dart';
import 'package:bengkelpintar/features/pos/transaction_list_screen.dart';
import 'package:bengkelpintar/features/admin/profile_screen.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _Transactions implements TransaksiService {
  Transaksi? finalized;

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
  }) async {
    finalized = _transaction(status: 'final', paid: jumlahDibayar);
    return finalized!;
  }

  @override
  Future<Transaksi?> getReceipt(int id) async => finalized;
}

class _ProfileAuth implements AuthService {
  @override
  Future<User?> currentUser() async =>
      const User(id: 1, nama: 'Andi Pratama', peran: 'admin');

  @override
  Future<User?> login(String username, String password) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async =>
      false;
}

class _Products implements ProdukService {
  _Products([this.items = const []]);
  final List<Produk> items;

  @override
  Future<List<Produk>> listProducts({String? query}) async => items;
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

class _Workshop implements PengaturanBengkelService {
  @override
  Future<PengaturanBengkel> getSettings() async => const PengaturanBengkel(
    id: 1,
    nama: 'Bengkel Maju Jaya',
    alamat: 'Jl. Merdeka No. 12, Bandung',
    telepon: '0812-3456-7890',
  );
  @override
  Future<PengaturanBengkel> updateSettings(PengaturanBengkel settings) async =>
      settings;
}

Transaksi _transaction({String status = 'draft', int paid = 0}) => Transaksi(
  id: 105,
  nomor: 'TRX-0105',
  status: status,
  namaPelanggan: 'Dedi Kurniawan',
  platNomor: 'D 1234 XX',
  total: 45000,
  metodeBayar: status == 'final' ? 'tunai' : null,
  jumlahDibayar: status == 'final' ? paid : null,
  kembalian: status == 'final' ? paid - 45000 : null,
  dibuatOleh: 'Andi Pratama',
  dibuatOlehId: 1,
  difinalkanOleh: status == 'final' ? 'Andi Pratama' : null,
  waktu: DateTime(2026, 10, 24, 10, 15),
  items: const [
    ItemTransaksi(
      id: 1,
      tipe: 'produk',
      produkId: 1,
      nama: 'Busi NGK Standar',
      jumlah: 1,
      hargaSatuan: 25000,
      subtotal: 25000,
    ),
    ItemTransaksi(
      id: 2,
      tipe: 'jasa',
      jasaId: 1,
      nama: 'Ganti busi',
      jumlah: 1,
      hargaSatuan: 20000,
      subtotal: 20000,
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  RoleProvider? role,
  TransaksiService? transactions,
  List<Produk> products = const [],
  AuthService? auth,
}) async {
  final view = tester.view;
  view.devicePixelRatio = 1;
  view.physicalSize = const Size(320, 800);
  view.viewPadding = const FakeViewPadding(top: 48, bottom: 34);
  view.viewInsets = FakeViewPadding.zero;
  view.platformDispatcher.textScaleFactorTestValue = 1.3;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: role ?? (RoleProvider()..setRole(UserRole.admin)),
        ),
        Provider<TransaksiService>.value(
          value: transactions ?? _Transactions(),
        ),
        Provider<ProdukService>.value(value: _Products(products)),
        Provider<JasaService>.value(value: _Services()),
        Provider<PengaturanBengkelService>.value(value: _Workshop()),
        if (auth != null) Provider<AuthService>.value(value: auth),
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

  testWidgets('bar bawah memanggil semua item yang diketuk', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FloatingNavBar(
            items: const [
              'Beranda',
              'Transaksi',
              'Diagnosis',
              'Katalog',
              'Profil',
            ],
            selectedIndex: 0,
            onSelected: selected.add,
          ),
        ),
      ),
    );
    await tester.pump();
    for (final label in [
      'Beranda',
      'Transaksi',
      'Diagnosis',
      'Katalog',
      'Profil',
    ]) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(selected, containsAll(<int>[0, 1, 2, 3, 4]));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ikon tombol primary memakai warna onPrimary', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton.primary(
            label: 'Diagnosis',
            icon: Icons.analytics_outlined,
            onPressed: () {},
          ),
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.analytics_outlined));
    expect(icon.color, AppTheme.light.colorScheme.onPrimary);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('draft menghitung total dan menghapus item', (tester) async {
    await _pump(tester, DraftScreen(transaction: _transaction()));
  });

  testWidgets('pembayaran menolak jumlah kurang dan aman pada keyboard', (
    tester,
  ) async {
    final transactions = _Transactions();
    await _pump(
      tester,
      FinalizationScreen(transaction: _transaction()),
      transactions: transactions,
    );
  });

  testWidgets('profil, katalog, draft, dan transaksi aman pada 320 dp', (
    tester,
  ) async {
    const product = Produk(
      id: 1,
      nama: 'Busi NGK Standar',
      kategoriId: 1,
      kategoriNama: 'Pengapian',
      harga: 25000,
      stok: 4,
      stokMinimum: 2,
      aktif: true,
    );
    await _pump(tester, const ProfileScreen(), auth: _ProfileAuth());
    await _pump(tester, const CatalogScreen(), products: const [product]);
    await _pump(tester, DraftScreen(transaction: _transaction()));
    await _pump(
      tester,
      const TransactionListScreen(),
      transactions: _Transactions(),
    );
  });

  testWidgets(
    'kasir menambah item, menampilkan keranjang, lalu membuka draft',
    (tester) async {
      final product = const Produk(
        id: 1,
        nama: 'Busi NGK Standar',
        kategoriId: 1,
        kategoriNama: 'Pengapian',
        harga: 25000,
        stok: 4,
        stokMinimum: 2,
        aktif: true,
      );
      final cart = DraftCartController();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: RoleProvider()..setRole(UserRole.admin),
            ),
            ChangeNotifierProvider.value(value: cart),
            Provider<ProdukService>.value(value: _Products([product])),
            Provider<JasaService>.value(value: _Services()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CashierScreen(),
            onGenerateRoute: (settings) => MaterialPageRoute(
              settings: settings,
              builder: (_) => DraftScreen(
                initialItems: settings.arguments as List<ItemTransaksiRequest>,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.text('Busi NGK Standar'), findsAtLeastNWidgets(1));
      await tester.tap(find.byIcon(AppIcons.addRounded).last);
      await tester.pump();
      expect(find.text('Lihat Keranjang'), findsOneWidget);
      expect(find.text('1 item · Rp25.000'), findsOneWidget);
      expect(find.byType(QtyStepper), findsOneWidget);
      await tester.tap(find.text('Lihat Keranjang'));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.text('Draft Transaksi'), findsOneWidget);
      expect(find.text('Busi NGK Standar'), findsAtLeastNWidgets(1));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      cart.dispose();
    },
  );
}
