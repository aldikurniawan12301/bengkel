import '../data/mock_asset_loader.dart';
import '../data/models/gejala.dart';
import '../data/models/jasa.dart';
import '../data/models/kerusakan.dart';
import '../data/models/produk.dart';
import '../data/models/riwayat_diagnosis.dart';
import '../data/models/transaksi.dart';
import '../data/models/user.dart';
import '../data/models/kategori.dart';
import '../data/models/pengaturan_bengkel.dart';
import '../data/models/mutasi_stok.dart';

class MockStore {
  MockStore({
    required this.users,
    required this.gejala,
    required this.kerusakan,
    required this.products,
    required this.services,
    required this.histories,
    required this.transactions,
    required this.categories,
    required this.workshop,
    this.stockMovements = const [],
  });

  final List<User> users;
  final List<Gejala> gejala;
  final List<Kerusakan> kerusakan;
  final List<Produk> products;
  final List<Jasa> services;
  final List<RiwayatDiagnosis> histories;
  final List<Transaksi> transactions;
  final List<Kategori> categories;
  PengaturanBengkel workshop;
  final List<MutasiStok> stockMovements;

  static Future<MockStore> load() async {
    final userData = await readMockJson('pengguna.json') as List;
    final symptomData = await readMockJson('gejala.json') as List;
    final damageData = await readMockJson('kerusakan.json') as List;
    final productData = await readMockJson('produk.json') as List;
    final serviceData = await readMockJson('jasa.json') as List;
    final historyData = await readMockJson('riwayat_diagnosis.json') as List;
    final transactionData = await readMockJson('transaksi.json') as List;
    final categoryData = await readMockJson('kategori.json') as List;
    final workshopData =
        await readMockJson('bengkel.json') as Map<String, dynamic>;
    return MockStore(
      users: userData
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList(),
      gejala: symptomData
          .map((item) => Gejala.fromJson(item as Map<String, dynamic>))
          .toList(),
      kerusakan: damageData
          .map((item) => Kerusakan.fromJson(item as Map<String, dynamic>))
          .toList(),
      products: productData
          .map((item) => Produk.fromJson(item as Map<String, dynamic>))
          .toList(),
      services: serviceData
          .map((item) => Jasa.fromJson(item as Map<String, dynamic>))
          .toList(),
      histories: historyData
          .map(
            (item) => RiwayatDiagnosis.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      transactions: transactionData
          .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
          .toList(),
      categories: categoryData
          .map((item) => Kategori.fromJson(item as Map<String, dynamic>))
          .toList(),
      workshop: PengaturanBengkel.fromJson(workshopData),
      stockMovements: <MutasiStok>[],
    );
  }
}
