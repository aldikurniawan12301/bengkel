import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/models/jasa.dart';
import 'package:bengkelpintar/data/models/mutasi_stok.dart';
import 'package:bengkelpintar/data/models/produk.dart';
import 'package:bengkelpintar/data/models/transaksi.dart';
import 'package:bengkelpintar/features/pos/draft_screen.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

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

void main() {
  testWidgets('draft tidak crash saat item katalog sudah hilang', (
    tester,
  ) async {
    final transaction = Transaksi(
      id: 0,
      nomor: 'Draft Baru',
      status: 'draft',
      namaPelanggan: '',
      platNomor: '',
      total: 0,
      dibuatOleh: '',
      dibuatOlehId: 0,
      waktu: DateTime(2026, 10, 24),
      items: const [],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RoleProvider()),
          Provider<ProdukService>(create: (_) => _Products()),
          Provider<JasaService>(create: (_) => _Services()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: DraftScreen(
            transaction: transaction,
            initialItems: const [
              ItemTransaksiRequest(tipe: 'produk', id: 999, jumlah: 1),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Item sudah tidak tersedia di katalog.'), findsOneWidget);
  });
}
