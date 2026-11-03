import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/server_config.dart';
import '../data/mock_asset_loader.dart';
import '../data/mock_diagnosis.dart';
import '../data/models/gejala.dart';
import '../data/models/hasil_diagnosis.dart';
import '../data/models/jasa.dart';
import '../data/models/kerusakan.dart';
import '../data/models/laporan_penjualan.dart';
import '../data/models/produk.dart';
import '../data/models/riwayat_diagnosis.dart';
import '../data/models/transaksi.dart';
import '../data/models/user.dart';
import '../data/models/kategori.dart';
import '../data/models/pengaturan_bengkel.dart';
import '../data/models/mutasi_stok.dart';
import '../data/models/statistik_diagnosis.dart';
import 'mock_delay.dart';
import 'mock_store.dart';
import 'service_interfaces.dart';

abstract class MockServiceBase {
  MockServiceBase(this.store, this.activeUser);
  final MockStore store;
  final User Function() activeUser;

  User get user => activeUser();
  bool get isAdmin => user.peran == 'admin';
}

class MockAuthService implements AuthService {
  MockAuthService(this.store);
  final MockStore store;

  @override
  Future<User?> login(String username, String password) async {
    await mockDelay();
    final accounts = await readMockAccounts();
    final preferences = await SharedPreferences.getInstance();
    final account = accounts.where((item) {
      final savedPassword = preferences.getString(
        'mock_password_${item['username']}',
      );
      return item['username'] == username &&
          (savedPassword ?? item['password']) == password;
    }).firstOrNull;
    if (account == null) return null;
    final user = store.users.firstWhere((item) => item.username == username);
    if (user.aktif == false) return null;
    await preferences.setInt('mock_session_user_id', user.id);
    return user;
  }

  @override
  Future<User?> currentUser() async {
    await mockDelay();
    final preferences = await SharedPreferences.getInstance();
    final id = preferences.getInt('mock_session_user_id');
    if (id == null) return null;
    final user = store.users.where((item) => item.id == id).firstOrNull;
    return user?.aktif == false ? null : user;
  }

  @override
  Future<void> logout() async {
    await mockDelay();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('mock_session_user_id');
  }

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    await mockDelay();
    final user = await currentUser();
    if (user?.username == null) return false;
    final accounts = await readMockAccounts();
    final preferences = await SharedPreferences.getInstance();
    final account = accounts.firstWhere(
      (item) => item['username'] == user!.username,
    );
    final current =
        preferences.getString('mock_password_${user!.username}') ??
        account['password'] as String;
    if (current != oldPassword) return false;
    await preferences.setString('mock_password_${user.username}', newPassword);
    return true;
  }
}

class MockServerService implements ServerService {
  @override
  Future<bool> checkHealth(String baseUrl) async {
    await mockDelay();
    return ServerConfig.isValidUrl(baseUrl);
  }
}

class MockDiagnosisService extends MockServiceBase implements DiagnosisService {
  MockDiagnosisService(super.store, super.activeUser);

  @override
  Future<HasilDiagnosis?> diagnose(List<int> gejalaIds) async {
    await mockDelay();
    final codes = store.gejala
        .where((item) => gejalaIds.contains(item.id))
        .map((item) => item.kode)
        .toSet();
    final result = diagnoseMock(
      gejalaCodes: codes,
      kerusakan: store.kerusakan,
      waktu: DateTime(2026, 10, 24, 10, 15),
      riwayatId: 31,
    );
    if (result == null) return null;
    store.histories.add(
      RiwayatDiagnosis(
        id: result.riwayatId,
        penggunaId: user.id,
        penggunaNama: user.nama,
        gejala: store.gejala
            .where((item) => gejalaIds.contains(item.id))
            .toList(),
        hasil: result,
        keyakinan: result.kerusakanUtama.keyakinan,
        waktu: result.waktu,
      ),
    );
    return result;
  }

  @override
  Future<List<RiwayatDiagnosis>> listHistory() async {
    await mockDelay();
    return isAdmin
        ? List.of(store.histories)
        : store.histories.where((item) => item.penggunaId == user.id).toList();
  }

  @override
  Future<RiwayatDiagnosis?> getHistory(int id) async {
    await mockDelay();
    final item = store.histories
        .where((history) => history.id == id)
        .firstOrNull;
    if (item == null || (!isAdmin && item.penggunaId != user.id)) return null;
    return item;
  }

  @override
  Future<StatistikDiagnosis> getStatistics() async {
    await mockDelay();
    final visible = isAdmin
        ? store.histories
        : store.histories.where((item) => item.penggunaId == user.id).toList();
    final counts = <String, int>{};
    for (final item in visible) {
      final name = item.hasil.kerusakanUtama.nama;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final total = visible.length;
    final items =
        counts.entries
            .map(
              (entry) => StatistikDiagnosisItem(
                nama: entry.key,
                jumlah: entry.value,
                persentase: total == 0 ? 0 : entry.value / total,
              ),
            )
            .toList()
          ..sort((a, b) => b.jumlah.compareTo(a.jumlah));
    return StatistikDiagnosis(total: total, items: items);
  }
}

class MockProdukService extends MockServiceBase implements ProdukService {
  MockProdukService(super.store, super.activeUser);

  @override
  Future<List<Produk>> listProducts({String? query}) async {
    await mockDelay();
    return _filter(store.products, query, (item) => item.nama);
  }

  @override
  Future<Produk> addProduct(Produk product) async {
    _requireAdmin();
    await mockDelay();
    store.products.add(product);
    return product;
  }

  @override
  Future<Produk> updateProduct(Produk product) async {
    _requireAdmin();
    await mockDelay();
    _replace(store.products, product.id, product);
    return product;
  }

  @override
  Future<void> deactivateProduct(int id) async {
    _requireAdmin();
    await mockDelay();
    final item = store.products.firstWhere((product) => product.id == id);
    _replace(
      store.products,
      id,
      Produk(
        id: item.id,
        nama: item.nama,
        kategoriId: item.kategoriId,
        kategoriNama: item.kategoriNama,
        harga: item.harga,
        stok: item.stok,
        stokMinimum: item.stokMinimum,
        aktif: false,
      ),
    );
  }

  @override
  Future<Produk> adjustStock(
    int id, {
    required int jumlah,
    required String alasan,
  }) async {
    _requireAdmin();
    if (jumlah == 0) throw StateError('Jumlah stok tidak boleh nol.');
    await mockDelay();
    final product = store.products.firstWhere((item) => item.id == id);
    final next = product.stok + jumlah;
    if (next < 0) throw StateError('Stok tidak boleh negatif.');
    final updated = Produk(
      id: product.id,
      nama: product.nama,
      kategoriId: product.kategoriId,
      kategoriNama: product.kategoriNama,
      harga: product.harga,
      stok: next,
      stokMinimum: product.stokMinimum,
      aktif: product.aktif,
    );
    _replace(store.products, id, updated);
    store.stockMovements.add(
      MutasiStok(
        id: store.stockMovements.length + 1,
        produkId: id,
        jumlah: jumlah,
        alasan: alasan,
        waktu: DateTime(2026, 10, 24, 10, 15),
        dibuatOleh: user.nama,
      ),
    );
    return updated;
  }

  @override
  Future<List<MutasiStok>> listStockMovements(int id) async {
    _requireAdmin();
    await mockDelay();
    return store.stockMovements.where((item) => item.produkId == id).toList();
  }

  void _requireAdmin() {
    if (!isAdmin) throw StateError('Hanya admin yang dapat mengelola produk.');
  }
}

class MockJasaService extends MockServiceBase implements JasaService {
  MockJasaService(super.store, super.activeUser);
  @override
  Future<List<Jasa>> listServices({String? query}) async {
    await mockDelay();
    return _filter(store.services, query, (item) => item.nama);
  }

  @override
  Future<Jasa> addService(Jasa service) async {
    _requireAdmin();
    await mockDelay();
    store.services.add(service);
    return service;
  }

  @override
  Future<Jasa> updateService(Jasa service) async {
    _requireAdmin();
    await mockDelay();
    _replace(store.services, service.id, service);
    return service;
  }

  @override
  Future<void> deactivateService(int id) async {
    _requireAdmin();
    await mockDelay();
    final item = store.services.firstWhere((service) => service.id == id);
    _replace(
      store.services,
      id,
      Jasa(id: item.id, nama: item.nama, harga: item.harga, aktif: false),
    );
  }

  void _requireAdmin() {
    if (!isAdmin) throw StateError('Hanya admin yang dapat mengelola jasa.');
  }
}

class MockKerusakanService extends MockServiceBase implements KerusakanService {
  MockKerusakanService(super.store, super.activeUser);
  @override
  Future<List<Gejala>> listGejala({String? query}) async {
    await mockDelay();
    return _filter(store.gejala, query, (item) => '${item.kode} ${item.nama}');
  }

  @override
  Future<List<Kerusakan>> listKerusakan({String? query}) async {
    await mockDelay();
    return _filter(
      store.kerusakan,
      query,
      (item) => '${item.kode} ${item.nama}',
    );
  }

  @override
  Future<Gejala> addGejala(Gejala gejala) async {
    _requireAdmin();
    await mockDelay();
    store.gejala.add(gejala);
    return gejala;
  }

  @override
  Future<Gejala> updateGejala(Gejala gejala) async {
    _requireAdmin();
    await mockDelay();
    _replace(store.gejala, gejala.id, gejala);
    return gejala;
  }

  @override
  Future<void> deactivateGejala(int id) async {
    _requireAdmin();
    await mockDelay();
    final item = store.gejala.firstWhere((item) => item.id == id);
    _replace(
      store.gejala,
      id,
      Gejala(
        id: item.id,
        kode: item.kode,
        nama: item.nama,
        kategori: item.kategori,
        aktif: false,
      ),
    );
  }

  @override
  Future<Kerusakan> addKerusakan(Kerusakan item) async {
    _requireAdmin();
    await mockDelay();
    store.kerusakan.add(item);
    return item;
  }

  @override
  Future<Kerusakan> updateKerusakan(Kerusakan item) async {
    _requireAdmin();
    await mockDelay();
    _replace(store.kerusakan, item.id, item);
    return item;
  }

  @override
  Future<void> deactivateKerusakan(int id) async {
    _requireAdmin();
    await mockDelay();
    final item = store.kerusakan.firstWhere((item) => item.id == id);
    _replace(
      store.kerusakan,
      id,
      Kerusakan(
        id: item.id,
        kode: item.kode,
        nama: item.nama,
        urgensi: item.urgensi,
        solusi: item.solusi,
        estimasiWaktuMenit: item.estimasiWaktuMenit,
        aktif: false,
        komponenTerkait: item.komponenTerkait,
        jasaTerkait: item.jasaTerkait,
      ),
    );
  }

  void _requireAdmin() {
    if (!isAdmin) {
      throw StateError(
        'Hanya admin yang dapat mengelola gejala dan kerusakan.',
      );
    }
  }
}

class MockPenggunaService extends MockServiceBase implements PenggunaService {
  MockPenggunaService(super.store, super.activeUser);
  @override
  Future<List<User>> listUsers({String? query}) async {
    _requireAdmin();
    await mockDelay();
    return _filter(
      store.users,
      query,
      (item) => '${item.nama} ${item.username ?? ''}',
    );
  }

  @override
  Future<User> addUser(User user) async {
    _requireAdmin();
    await mockDelay();
    store.users.add(user);
    return user;
  }

  @override
  Future<User> updateUser(User user) async {
    _requireAdmin();
    await mockDelay();
    _replace(store.users, user.id, user);
    return user;
  }

  @override
  Future<void> deactivateUser(int id) async {
    _requireAdmin();
    if (id == user.id) {
      throw StateError('Admin tidak dapat menonaktifkan dirinya sendiri.');
    }
    await mockDelay();
    final item = store.users.firstWhere((user) => user.id == id);
    _replace(
      store.users,
      id,
      User(
        id: item.id,
        nama: item.nama,
        peran: item.peran,
        username: item.username,
        aktif: false,
      ),
    );
  }

  @override
  Future<bool> resetPassword(int id, String newPassword) async {
    _requireAdmin();
    await mockDelay();
    final user = store.users.firstWhere((item) => item.id == id);
    if (user.username == null) return false;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('mock_password_${user.username}', newPassword);
    return true;
  }

  void _requireAdmin() {
    if (!isAdmin) {
      throw StateError('Hanya admin yang dapat mengelola pengguna.');
    }
  }
}

class MockKategoriService extends MockServiceBase implements KategoriService {
  MockKategoriService(super.store, super.activeUser);
  @override
  Future<List<Kategori>> listCategories({String? query}) async {
    await mockDelay();
    return _filter(store.categories, query, (item) => item.nama);
  }

  @override
  Future<Kategori> addCategory(Kategori category) async {
    _requireAdmin();
    await mockDelay();
    store.categories.add(category);
    return category;
  }

  @override
  Future<Kategori> updateCategory(Kategori category) async {
    _requireAdmin();
    await mockDelay();
    _replace(store.categories, category.id, category);
    return category;
  }

  @override
  Future<void> deactivateCategory(int id) async {
    _requireAdmin();
    await mockDelay();
    if (store.products.any(
      (product) => product.kategoriId == id && product.aktif,
    )) {
      throw StateError(
        'Kategori yang masih dipakai produk tidak boleh dihapus.',
      );
    }
    final item = store.categories.firstWhere((item) => item.id == id);
    _replace(
      store.categories,
      id,
      Kategori(id: item.id, nama: item.nama, aktif: false),
    );
  }

  void _requireAdmin() {
    if (!isAdmin) {
      throw StateError('Hanya admin yang dapat mengelola kategori.');
    }
  }
}

class MockPengaturanBengkelService extends MockServiceBase
    implements PengaturanBengkelService {
  MockPengaturanBengkelService(super.store, super.activeUser);
  @override
  Future<PengaturanBengkel> getSettings() async {
    await mockDelay();
    return store.workshop;
  }

  @override
  Future<PengaturanBengkel> updateSettings(PengaturanBengkel settings) async {
    if (!isAdmin) {
      throw StateError('Hanya admin yang dapat mengubah pengaturan bengkel.');
    }
    await mockDelay();
    store.workshop = settings;
    return settings;
  }
}

class MockTransaksiService extends MockServiceBase implements TransaksiService {
  MockTransaksiService(super.store, super.activeUser);

  @override
  Future<Transaksi> createDraft({
    required String namaPelanggan,
    required String platNomor,
    required List<ItemTransaksiRequest> items,
    int? riwayatDiagnosisId,
  }) async {
    await mockDelay();
    final resolved = items.map(_resolveItem).toList();
    final id =
        store.transactions
            .map((item) => item.id)
            .fold(100, (max, value) => value > max ? value : max) +
        1;
    final transaction = Transaksi(
      id: id,
      nomor: 'TRX-${id.toString().padLeft(4, '0')}',
      status: 'draft',
      namaPelanggan: namaPelanggan,
      platNomor: platNomor,
      total: resolved.fold(0, (sum, item) => sum + item.subtotal),
      dibuatOleh: user.nama,
      dibuatOlehId: user.id,
      riwayatDiagnosisId: riwayatDiagnosisId,
      waktu: DateTime(2026, 10, 24, 10, 15),
      items: resolved,
    );
    store.transactions.add(transaction);
    return transaction;
  }

  @override
  Future<Transaksi> updateDraft(Transaksi transaction) async {
    await mockDelay();
    final old = _findVisible(transaction.id);
    if (old.status != 'draft') {
      throw StateError('Transaksi final tidak bisa diubah.');
    }
    if (!isAdmin && old.dibuatOlehId != user.id) {
      throw StateError('Transaksi bukan milik pengguna aktif.');
    }
    _replace(store.transactions, transaction.id, transaction);
    return transaction;
  }

  @override
  Future<List<Transaksi>> listTransactions({
    String? status,
    String? query,
  }) async {
    await mockDelay();
    var result = isAdmin
        ? List<Transaksi>.of(store.transactions)
        : store.transactions
              .where(
                (item) =>
                    item.dibuatOlehId == user.id && item.status == 'draft',
              )
              .toList();
    if (status != null) {
      result = result.where((item) => item.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      result = result
          .where(
            (item) => '${item.nomor} ${item.namaPelanggan} ${item.platNomor}'
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    }
    return result;
  }

  @override
  Future<Transaksi?> getTransaction(int id) async {
    await mockDelay();
    return _findVisibleOrNull(id);
  }

  @override
  Future<Transaksi> finalizeTransaction(
    int id, {
    required String metodeBayar,
    required int jumlahDibayar,
  }) async {
    await mockDelay();
    if (!isAdmin) {
      throw StateError('Hanya admin yang dapat memfinalkan transaksi.');
    }
    final transaction = _findVisible(id);
    if (transaction.status != 'draft') {
      throw StateError('Transaksi final tidak bisa diubah.');
    }
    final requiredProducts = <int, int>{};
    for (final item in transaction.items) {
      if (item.tipe == 'produk') {
        requiredProducts[item.produkId!] =
            (requiredProducts[item.produkId!] ?? 0) + item.jumlah;
      }
    }
    for (final entry in requiredProducts.entries) {
      final product = store.products.firstWhere((item) => item.id == entry.key);
      if (product.stok < entry.value) {
        throw StateError('Stok tidak mencukupi untuk ${product.nama}.');
      }
    }
    for (final entry in requiredProducts.entries) {
      final product = store.products.firstWhere((item) => item.id == entry.key);
      _replace(
        store.products,
        product.id,
        Produk(
          id: product.id,
          nama: product.nama,
          kategoriId: product.kategoriId,
          kategoriNama: product.kategoriNama,
          harga: product.harga,
          stok: product.stok - entry.value,
          stokMinimum: product.stokMinimum,
          aktif: product.aktif,
        ),
      );
    }
    final finalized = Transaksi(
      id: transaction.id,
      nomor: transaction.nomor,
      status: 'final',
      namaPelanggan: transaction.namaPelanggan,
      platNomor: transaction.platNomor,
      total: transaction.total,
      metodeBayar: metodeBayar,
      jumlahDibayar: jumlahDibayar,
      kembalian: jumlahDibayar - transaction.total,
      dibuatOleh: transaction.dibuatOleh,
      dibuatOlehId: transaction.dibuatOlehId,
      difinalkanOleh: user.nama,
      riwayatDiagnosisId: transaction.riwayatDiagnosisId,
      waktu: transaction.waktu,
      items: transaction.items,
    );
    _replace(store.transactions, transaction.id, finalized);
    return finalized;
  }

  @override
  Future<Transaksi?> getReceipt(int id) async {
    await mockDelay();
    final transaction = _findVisibleOrNull(id);
    return transaction?.status == 'final' && isAdmin ? transaction : null;
  }

  ItemTransaksi _resolveItem(ItemTransaksiRequest request) {
    if (request.tipe == 'produk') {
      final item = store.products.firstWhere(
        (product) => product.id == request.id,
      );
      return ItemTransaksi(
        id: request.id,
        tipe: 'produk',
        produkId: item.id,
        nama: item.nama,
        jumlah: request.jumlah,
        hargaSatuan: item.harga,
        subtotal: item.harga * request.jumlah,
      );
    }
    final item = store.services.firstWhere(
      (service) => service.id == request.id,
    );
    return ItemTransaksi(
      id: request.id,
      tipe: 'jasa',
      jasaId: item.id,
      nama: item.nama,
      jumlah: request.jumlah,
      hargaSatuan: item.harga,
      subtotal: item.harga * request.jumlah,
    );
  }

  Transaksi _findVisible(int id) =>
      _findVisibleOrNull(id) ??
      (throw StateError('Transaksi tidak ditemukan.'));
  Transaksi? _findVisibleOrNull(int id) {
    final item = store.transactions
        .where((transaction) => transaction.id == id)
        .firstOrNull;
    return item == null || (!isAdmin && item.dibuatOlehId != user.id)
        ? null
        : item;
  }
}

class MockLaporanService extends MockServiceBase implements LaporanService {
  MockLaporanService(super.store, super.activeUser);
  @override
  Future<LaporanPenjualan> salesReport({
    required String periodeMulai,
    required String periodeSelesai,
  }) async {
    if (!isAdmin) throw StateError('Hanya admin yang dapat melihat laporan.');
    await mockDelay();
    final finalTransactions = store.transactions
        .where(
          (item) =>
              item.status == 'final' &&
              item.waktu
                      .toIso8601String()
                      .substring(0, 10)
                      .compareTo(periodeMulai) >=
                  0 &&
              item.waktu
                      .toIso8601String()
                      .substring(0, 10)
                      .compareTo(periodeSelesai) <=
                  0,
        )
        .toList();
    final daily = <String, List<Transaksi>>{};
    final best = <String, Terlaris>{};
    for (final transaction in finalTransactions) {
      final date = transaction.waktu.toIso8601String().substring(0, 10);
      daily.putIfAbsent(date, () => []).add(transaction);
      for (final item in transaction.items) {
        final key =
            '${item.tipe}:${item.tipe == 'produk' ? item.produkId : item.jasaId}';
        final current = best[key];
        best[key] = Terlaris(
          tipe: item.tipe,
          id: item.tipe == 'produk' ? item.produkId! : item.jasaId!,
          nama: item.nama,
          jumlah: (current?.jumlah ?? 0) + item.jumlah,
          total: (current?.total ?? 0) + item.subtotal,
        );
      }
    }
    final total = finalTransactions.fold<int>(
      0,
      (sum, item) => sum + item.total,
    );
    return LaporanPenjualan(
      periodeMulai: periodeMulai,
      periodeSelesai: periodeSelesai,
      totalPenjualan: total,
      jumlahTransaksi: finalTransactions.length,
      rataRata: finalTransactions.isEmpty
          ? 0
          : (total / finalTransactions.length).round(),
      penjualanPerHari: daily.entries
          .map(
            (entry) => PenjualanPerHari(
              tanggal: entry.key,
              total: entry.value.fold(0, (sum, item) => sum + item.total),
              jumlah: entry.value.length,
            ),
          )
          .toList(),
      terlaris:
          (best.values.toList()..sort((a, b) => b.jumlah.compareTo(a.jumlah)))
              .take(5)
              .toList(),
    );
  }
}

List<T> _filter<T>(List<T> items, String? query, String Function(T) text) =>
    query == null || query.isEmpty
    ? List.of(items)
    : items
          .where(
            (item) => text(item).toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

void _replace<T>(List<T> items, int id, T value) {
  final index = items.indexWhere((item) => (item as dynamic).id == id);
  if (index < 0) throw StateError('Data tidak ditemukan.');
  items[index] = value;
}
