import 'package:flutter_test/flutter_test.dart';

import 'package:bengkelpintar/core/utils/formatters.dart';
import 'package:bengkelpintar/data/mock_asset_loader.dart';
import 'package:bengkelpintar/data/mock_diagnosis.dart';
import 'package:bengkelpintar/data/models/gejala.dart';
import 'package:bengkelpintar/data/models/hasil_diagnosis.dart';
import 'package:bengkelpintar/data/models/jasa.dart';
import 'package:bengkelpintar/data/models/kerusakan.dart';
import 'package:bengkelpintar/data/models/produk.dart';
import 'package:bengkelpintar/data/models/riwayat_diagnosis.dart';
import 'package:bengkelpintar/data/models/transaksi.dart';
import 'package:bengkelpintar/data/models/user.dart';

Future<List<Map<String, dynamic>>> _listAsset(String name) async {
  final data = await readMockJson(name) as List;
  return data.cast<Map<String, dynamic>>();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('semua file mock terbaca dan jumlah data sesuai', () async {
    final accounts = await readMockAccounts();
    final users = await _listAsset('pengguna.json');
    final customers = await _listAsset('pelanggan.json');
    final symptoms = await _listAsset('gejala.json');
    final damages = await _listAsset('kerusakan.json');
    final categories = await _listAsset('kategori.json');
    final products = await _listAsset('produk.json');
    final services = await _listAsset('jasa.json');
    final transactions = await _listAsset('transaksi.json');
    final histories = await _listAsset('riwayat_diagnosis.json');
    final workshop = await readMockJson('bengkel.json') as Map<String, dynamic>;

    expect(accounts.length, 3);
    expect(users.length, 3);
    expect(customers.length, 4);
    expect(symptoms.length, 18);
    expect(damages.length, 10);
    expect(categories.length, 6);
    expect(products.length, 12);
    expect(services.length, 9);
    expect(transactions.length, 4);
    expect(histories.length, 1);
    expect(workshop['nama'], 'Bengkel Maju Jaya');
    expect(
      accounts.map((item) => item.keys.toSet()),
      everyElement({'username', 'password'}),
    );
    expect(users.every((item) => !item.containsKey('password')), isTrue);
  });

  test('round-trip fromJson dan toJson mempertahankan semua model', () async {
    final users = (await _listAsset('pengguna.json'))
        .map(User.fromJson)
        .toList();
    final symptoms = (await _listAsset('gejala.json'))
        .map(Gejala.fromJson)
        .toList();
    final damages = (await _listAsset('kerusakan.json'))
        .map(Kerusakan.fromJson)
        .toList();
    final products = (await _listAsset('produk.json'))
        .map(Produk.fromJson)
        .toList();
    final services = (await _listAsset('jasa.json'))
        .map(Jasa.fromJson)
        .toList();
    final transactions = (await _listAsset('transaksi.json'))
        .map(Transaksi.fromJson)
        .toList();
    final histories = (await _listAsset('riwayat_diagnosis.json'))
        .map(RiwayatDiagnosis.fromJson)
        .toList();

    expect(
      users.map((item) => item.toJson()),
      (await _listAsset('pengguna.json')),
    );
    expect(
      symptoms.map((item) => item.toJson()),
      (await _listAsset('gejala.json')),
    );
    expect(
      damages.map((item) => item.toJson()),
      (await _listAsset('kerusakan.json')),
    );
    expect(
      products.map((item) => item.toJson()),
      (await _listAsset('produk.json')),
    );
    expect(
      services.map((item) => item.toJson()),
      (await _listAsset('jasa.json')),
    );
    expect(
      transactions.map((item) => item.toJson()),
      (await _listAsset('transaksi.json')),
    );
    expect(
      histories.map((item) => item.toJson()),
      (await _listAsset('riwayat_diagnosis.json')),
    );

    final result = HasilDiagnosis.fromJson(histories.single.hasil.toJson());
    expect(result.toJson(), histories.single.hasil.toJson());
    final request = ItemTransaksiRequest.fromJson({
      'tipe': 'produk',
      'id': 1,
      'jumlah': 1,
    });
    expect(request.toJson(), {'tipe': 'produk', 'id': 1, 'jumlah': 1});
  });

  test(
    'transaksi memiliki total sesuai data baku dan subtotal item benar',
    () async {
      final transactions = (await _listAsset('transaksi.json'))
          .map(Transaksi.fromJson)
          .toList();

      expect(transactions.map((item) => item.total), [
        45000,
        135000,
        300000,
        295000,
      ]);
      expect(
        transactions.fold<int>(0, (sum, item) => sum + item.total),
        775000,
      );
      for (final transaction in transactions) {
        expect(
          transaction.items.fold<int>(0, (sum, item) => sum + item.subtotal),
          transaction.total,
        );
        for (final item in transaction.items) {
          expect(item.subtotal, item.jumlah * item.hargaSatuan);
          if (item.tipe == 'produk') {
            expect(item.produkId, isNotNull);
            expect(item.jasaId, isNull);
          } else {
            expect(item.produkId, isNull);
            expect(item.jasaId, isNotNull);
          }
        }
      }
    },
  );

  test('formula estimasi biaya K01 menghasilkan 45000 dan 80000', () async {
    final damages = (await _listAsset('kerusakan.json'))
        .map(Kerusakan.fromJson)
        .toList();
    final k01 = damages.singleWhere((item) => item.kode == 'K01');
    final estimate = hitungEstimasiBiaya(
      komponen: k01.komponenTerkait,
      jasa: k01.jasaTerkait,
    );

    expect(estimate.min, 45000);
    expect(estimate.max, 80000);
    expect(estimate.keterangan, 'Perkiraan');
  });

  test('aturan diagnosis mock deterministik dan sesuai contoh PRD', () async {
    final symptoms = (await _listAsset('gejala.json'))
        .map(Gejala.fromJson)
        .toList();
    final damages = (await _listAsset('kerusakan.json'))
        .map(Kerusakan.fromJson)
        .toList();
    final codes = {'G01', 'G03', 'G04'};
    final first = diagnoseMock(
      gejalaCodes: codes,
      kerusakan: damages,
      waktu: DateTime(2026, 10, 24, 10, 15),
      riwayatId: 31,
    );
    final second = diagnoseMock(
      gejalaCodes: codes,
      kerusakan: damages,
      waktu: DateTime(2026, 10, 24, 10, 15),
      riwayatId: 31,
    );

    expect(symptoms.where((item) => codes.contains(item.kode)).length, 3);
    expect(first?.toJson(), second?.toJson());
    expect(first?.kerusakanUtama.nama, 'Busi kotor / aus');
    expect(first?.kerusakanUtama.keyakinan, 0.78);
    expect(first?.kemungkinanLain.map((item) => item.keyakinan), [0.15, 0.07]);
    expect(first?.estimasiBiaya.min, 30000);
    expect(first?.estimasiBiaya.max, 80000);
    expect(first?.estimasiBiaya.keterangan, 'Perkiraan');
    expect(formatTanggalIndonesia(first!.waktu), '24 Okt 2026, 10:15');
    expect(
      diagnoseMock(
        gejalaCodes: {'G01'},
        kerusakan: damages,
        waktu: first.waktu,
        riwayatId: 32,
      ),
      isNull,
    );
  });

  test(
    'pemetaan kerusakan memakai katalog resmi tanpa produk atau jasa baru',
    () async {
      final products = (await _listAsset('produk.json'))
          .map(Produk.fromJson)
          .toSet();
      final services = (await _listAsset('jasa.json'))
          .map(Jasa.fromJson)
          .toSet();
      final damages = (await _listAsset('kerusakan.json'))
          .map(Kerusakan.fromJson);
      final productIds = products.map((item) => item.id).toSet();
      final serviceIds = services.map((item) => item.id).toSet();

      for (final damage in damages) {
        expect(urgensiKeterangan(damage.urgensi), isNotEmpty);
        expect(
          damage.komponenTerkait.every(
            (item) => productIds.contains(item.produkId),
          ),
          isTrue,
        );
        expect(
          damage.jasaTerkait.every((item) => serviceIds.contains(item.jasaId)),
          isTrue,
        );
      }
    },
  );
}
