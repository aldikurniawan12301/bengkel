import 'package:flutter_test/flutter_test.dart';

import 'package:bengkelpintar/data/models/transaksi.dart';
import 'package:bengkelpintar/data/models/kategori.dart';
import 'package:bengkelpintar/data/models/kerusakan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bengkelpintar/services/mock_services.dart';
import 'package:bengkelpintar/services/mock_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MockStore> store() => MockStore.load();

  test('finalisasi memotong stok tepat sesuai jumlah item', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    final service = MockTransaksiService(data, () => admin);
    final before = data.products.firstWhere((item) => item.id == 1).stok;
    final result = await service.finalizeTransaction(
      105,
      metodeBayar: 'tunai',
      jumlahDibayar: 45000,
    );

    expect(result.status, 'final');
    expect(data.products.firstWhere((item) => item.id == 1).stok, before - 1);
  });

  test('finalisasi stok kurang ditolak dan stok tidak berubah', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    final service = MockTransaksiService(data, () => admin);
    final product = data.products.firstWhere((item) => item.id == 1);
    final before = product.stok;
    final draft = await service.createDraft(
      namaPelanggan: 'Dedi Kurniawan',
      platNomor: 'D 1234 XX',
      items: [const ItemTransaksiRequest(tipe: 'produk', id: 1, jumlah: 99)],
    );

    expect(
      () => service.finalizeTransaction(
        draft.id,
        metodeBayar: 'tunai',
        jumlahDibayar: draft.total,
      ),
      throwsStateError,
    );
    expect(data.products.firstWhere((item) => item.id == 1).stok, before);
  });

  test('transaksi final tidak bisa diubah', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    final service = MockTransaksiService(data, () => admin);
    final transaction = data.transactions.firstWhere((item) => item.id == 104);

    expect(() => service.updateDraft(transaction), throwsStateError);
  });

  test('mekanik hanya melihat draft dan riwayat miliknya', () async {
    final data = await store();
    final budi = data.users.firstWhere((item) => item.id == 2);
    final rina = data.users.firstWhere((item) => item.id == 3);
    final transactions = MockTransaksiService(data, () => budi);
    final diagnosis = MockDiagnosisService(data, () => budi);

    expect(
      (await transactions.listTransactions()).every(
        (item) => item.status == 'draft' && item.dibuatOlehId == budi.id,
      ),
      isTrue,
    );
    expect(
      (await diagnosis.listHistory()).every(
        (item) => item.penggunaId == budi.id,
      ),
      isTrue,
    );
    expect(
      await MockTransaksiService(data, () => rina).getTransaction(105),
      isNull,
    );
  });

  test('admin melihat semua transaksi dan riwayat', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    final transactions = MockTransaksiService(data, () => admin);
    final diagnosis = MockDiagnosisService(data, () => admin);

    expect((await transactions.listTransactions()).length, 4);
    expect((await diagnosis.listHistory()).length, 1);
  });

  test(
    'draft dari diagnosis menyimpan referensi riwayat dan item terkait',
    () async {
      final data = await store();
      final budi = data.users.firstWhere((item) => item.id == 2);
      final service = MockTransaksiService(data, () => budi);
      final draft = await service.createDraft(
        namaPelanggan: 'Dedi Kurniawan',
        platNomor: 'D 1234 XX',
        riwayatDiagnosisId: 31,
        items: const [
          ItemTransaksiRequest(tipe: 'produk', id: 1, jumlah: 1),
          ItemTransaksiRequest(tipe: 'jasa', id: 1, jumlah: 1),
        ],
      );
      expect(draft.riwayatDiagnosisId, 31);
      expect(draft.items.map((item) => item.nama), [
        'Busi NGK Standar',
        'Ganti busi',
      ]);
    },
  );

  test('laporan hanya menghitung transaksi final', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    final report = await MockLaporanService(
      data,
      () => admin,
    ).salesReport(periodeMulai: '2026-10-23', periodeSelesai: '2026-10-24');

    expect(report.totalPenjualan, 730000);
    expect(report.jumlahTransaksi, 3);
    expect(report.rataRata, 243333);
    expect(
      report.penjualanPerHari.map((item) => item.total),
      containsAll([135000, 595000]),
    );
    expect(report.terlaris.length, lessThanOrEqualTo(5));
    expect(
      report.terlaris.first.jumlah,
      greaterThanOrEqualTo(report.terlaris.last.jumlah),
    );
  });

  test('penyesuaian stok mencatat mutasi dan menolak hasil negatif', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    final service = MockProdukService(data, () => admin);
    final updated = await service.adjustStock(
      1,
      jumlah: 10,
      alasan: 'barang masuk',
    );
    expect(updated.stok, 14);
    expect((await service.listStockMovements(1)).single.alasan, 'barang masuk');
    expect(
      () => service.adjustStock(1, jumlah: -99, alasan: 'rusak'),
      throwsStateError,
    );
  });

  test(
    'statistik diagnosis memakai kontrak khusus dan visibilitas peran',
    () async {
      final data = await store();
      final admin = data.users.firstWhere((item) => item.id == 1);
      final budi = data.users.firstWhere((item) => item.id == 2);
      final adminStats = await MockDiagnosisService(
        data,
        () => admin,
      ).getStatistics();
      final mechanicStats = await MockDiagnosisService(
        data,
        () => budi,
      ).getStatistics();
      expect(adminStats.total, 1);
      expect(adminStats.items.single.nama, 'Busi kotor / aus');
      expect(adminStats.items.single.persentase, 1);
      expect(mechanicStats.total, 1);
    },
  );

  test('data nonaktif tidak muncul pada pilihan baru', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    await MockProdukService(data, () => admin).deactivateProduct(1);
    await MockJasaService(data, () => admin).deactivateService(1);
    await MockKerusakanService(data, () => admin).deactivateGejala(1);
    await MockKerusakanService(data, () => admin).deactivateKerusakan(1);
    final category = await MockKategoriService(
      data,
      () => admin,
    ).addCategory(const Kategori(id: 1000, nama: 'Kategori Uji', aktif: true));
    await MockKategoriService(
      data,
      () => admin,
    ).deactivateCategory(category.id);
    expect(
      (await MockProdukService(
        data,
        () => admin,
      ).listProducts()).where((item) => item.aktif).any((item) => item.id == 1),
      isFalse,
    );
    expect(
      (await MockJasaService(
        data,
        () => admin,
      ).listServices()).where((item) => item.aktif).any((item) => item.id == 1),
      isFalse,
    );
    expect(
      (await MockKerusakanService(
        data,
        () => admin,
      ).listGejala()).where((item) => item.aktif).any((item) => item.id == 1),
      isFalse,
    );
    expect(
      (await MockKerusakanService(data, () => admin).listKerusakan())
          .where((item) => item.aktif)
          .any((item) => item.id == 1),
      isFalse,
    );
    expect(
      (await MockKategoriService(data, () => admin).listCategories())
          .where((item) => item.aktif)
          .any((item) => item.id == category.id),
      isFalse,
    );
  });

  test('admin tidak dapat menonaktifkan diri sendiri dan kategori aktif terpakai terlindungi', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    expect(
      () => MockPenggunaService(data, () => admin).deactivateUser(1),
      throwsStateError,
    );
    expect(
      () => MockKategoriService(data, () => admin).deactivateCategory(1),
      throwsStateError,
    );
  });

  test('pengguna nonaktif tidak dapat login', () async {
    final data = await store();
    final budi = data.users.firstWhere((item) => item.id == 2);
    data.users[data.users.indexOf(budi)] = budi.copyWith(aktif: false);
    SharedPreferences.setMockInitialValues({});
    expect(await MockAuthService(data).login('budi', 'budi123'), isNull);
  });

  test('penautan K01 berubah dan estimasi tetap Perkiraan', () async {
    final data = await store();
    final admin = data.users.firstWhere((item) => item.id == 1);
    final original = data.kerusakan.firstWhere((item) => item.kode == 'K01');
    final updated = Kerusakan(
      id: original.id,
      kode: original.kode,
      nama: original.nama,
      urgensi: original.urgensi,
      solusi: original.solusi,
      estimasiWaktuMenit: original.estimasiWaktuMenit,
      aktif: true,
      komponenTerkait: const [
        KomponenTerkait(produkId: 2, nama: 'Kabel Busi', harga: 35000),
      ],
      jasaTerkait: const [
        JasaTerkait(jasaId: 1, nama: 'Ganti busi', harga: 20000),
      ],
    );
    await MockKerusakanService(data, () => admin).updateKerusakan(updated);
    final result = await MockDiagnosisService(
      data,
      () => admin,
    ).diagnose([1, 3, 4]);
    expect(result!.komponenTerkait.single.nama, 'Kabel Busi');
    expect(result.jasaTerkait.single.nama, 'Ganti busi');
    expect(result.estimasiBiaya.keterangan, 'Perkiraan');
  });
}
