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

abstract interface class AuthService {
  Future<User?> login(String username, String password);
  Future<User?> currentUser();
  Future<void> logout();
  Future<bool> changePassword(String oldPassword, String newPassword);
}

abstract interface class ServerService {
  Future<bool> checkHealth(String baseUrl);
}

abstract interface class DiagnosisService {
  Future<HasilDiagnosis?> diagnose(List<int> gejalaIds);
  Future<List<RiwayatDiagnosis>> listHistory();
  Future<RiwayatDiagnosis?> getHistory(int id);
  Future<StatistikDiagnosis> getStatistics();
}

abstract interface class ProdukService {
  Future<List<Produk>> listProducts({String? query});
  Future<Produk> addProduct(Produk product);
  Future<Produk> updateProduct(Produk product);
  Future<void> deactivateProduct(int id);
  Future<Produk> adjustStock(
    int id, {
    required int jumlah,
    required String alasan,
  });
  Future<List<MutasiStok>> listStockMovements(int id);
}

abstract interface class JasaService {
  Future<List<Jasa>> listServices({String? query});
  Future<Jasa> addService(Jasa service);
  Future<Jasa> updateService(Jasa service);
  Future<void> deactivateService(int id);
}

abstract interface class TransaksiService {
  Future<Transaksi> createDraft({
    required String namaPelanggan,
    required String platNomor,
    required List<ItemTransaksiRequest> items,
    int? riwayatDiagnosisId,
  });
  Future<Transaksi> updateDraft(Transaksi transaction);
  Future<List<Transaksi>> listTransactions({String? status, String? query});
  Future<Transaksi?> getTransaction(int id);
  Future<Transaksi> finalizeTransaction(
    int id, {
    required String metodeBayar,
    required int jumlahDibayar,
  });
  Future<Transaksi?> getReceipt(int id);
}

abstract interface class LaporanService {
  Future<LaporanPenjualan> salesReport({
    required String periodeMulai,
    required String periodeSelesai,
  });
}

abstract interface class PenggunaService {
  Future<List<User>> listUsers({String? query});
  Future<User> addUser(User user);
  Future<User> updateUser(User user);
  Future<void> deactivateUser(int id);
  Future<bool> resetPassword(int id, String newPassword);
}

abstract interface class KategoriService {
  Future<List<Kategori>> listCategories({String? query});
  Future<Kategori> addCategory(Kategori category);
  Future<Kategori> updateCategory(Kategori category);
  Future<void> deactivateCategory(int id);
}

abstract interface class PengaturanBengkelService {
  Future<PengaturanBengkel> getSettings();
  Future<PengaturanBengkel> updateSettings(PengaturanBengkel settings);
}

abstract interface class KerusakanService {
  Future<List<Gejala>> listGejala({String? query});
  Future<List<Kerusakan>> listKerusakan({String? query});
  Future<Gejala> addGejala(Gejala gejala);
  Future<Gejala> updateGejala(Gejala gejala);
  Future<void> deactivateGejala(int id);
  Future<Kerusakan> addKerusakan(Kerusakan kerusakan);
  Future<Kerusakan> updateKerusakan(Kerusakan kerusakan);
  Future<void> deactivateKerusakan(int id);
}
