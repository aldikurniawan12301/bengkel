import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/gejala.dart';
import '../data/models/hasil_diagnosis.dart';
import '../data/models/jasa.dart';
import '../data/models/kategori.dart';
import '../data/models/kerusakan.dart';
import '../data/models/laporan_penjualan.dart';
import '../data/models/mutasi_stok.dart';
import '../data/models/pengaturan_bengkel.dart';
import '../data/models/produk.dart';
import '../data/models/riwayat_diagnosis.dart';
import '../data/models/statistik_diagnosis.dart';
import '../data/models/transaksi.dart';
import '../data/models/user.dart';
import 'api_client.dart';
import 'service_interfaces.dart';

/// Implementasi AuthService berbasis REST API FastAPI.
class ApiAuthService implements AuthService {
  ApiAuthService(this.client);

  final ApiClient client;

  @override
  Future<User?> login(String username, String password) async {
    final response = await client.post(
      '/auth/login',
      body: {
        'username': username,
        'password': password,
      },
      includeAuth: false,
    );

    if (response is Map && response['access_token'] is String) {
      final token = response['access_token'] as String;
      await client.setToken(token);

      final userData = response['user'];
      if (userData is Map<String, dynamic>) {
        final user = User.fromJson(userData);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiClient.keyUserJson, jsonEncode(user.toJson()));
        return user;
      }
    }
    return null;
  }

  @override
  Future<User?> currentUser() async {
    final token = await client.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await client.get('/auth/me');
      if (response is Map<String, dynamic>) {
        final user = User.fromJson(response);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiClient.keyUserJson, jsonEncode(user.toJson()));
        return user;
      }
    } catch (_) {
      // Jika token tidak valid / server tidak dapat dijangkau tapi ada cache user
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(ApiClient.keyUserJson);
        if (cached != null) {
          return User.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await client.clearSession();
  }

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final response = await client.post(
      '/auth/ganti-password',
      body: {
        'password_lama': oldPassword,
        'password_baru': newPassword,
      },
    );
    return response is Map && response['pesan'] != null;
  }
}

/// Implementasi ServerService untuk cek kesehatan server.
class ApiServerService implements ServerService {
  ApiServerService(this.client);

  final ApiClient client;

  @override
  Future<bool> checkHealth(String baseUrl) async {
    return client.checkHealth(baseUrl);
  }
}

/// Implementasi DiagnosisService berbasis REST API.
class ApiDiagnosisService implements DiagnosisService {
  ApiDiagnosisService(this.client);

  final ApiClient client;

  @override
  Future<HasilDiagnosis?> diagnose(List<int> gejalaIds) async {
    final response = await client.post(
      '/diagnosis/predict',
      body: {'gejala_ids': gejalaIds},
    );
    if (response is Map<String, dynamic>) {
      return HasilDiagnosis.fromJson(response);
    }
    return null;
  }

  @override
  Future<List<RiwayatDiagnosis>> listHistory() async {
    final response = await client.get('/diagnosis/riwayat');
    if (response is List) {
      return response
          .map((item) => RiwayatDiagnosis.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<RiwayatDiagnosis?> getHistory(int id) async {
    final response = await client.get('/diagnosis/riwayat/$id');
    if (response is Map<String, dynamic>) {
      return RiwayatDiagnosis.fromJson(response);
    }
    return null;
  }

  @override
  Future<StatistikDiagnosis> getStatistics() async {
    final response = await client.get('/diagnosis/statistik');
    if (response is Map<String, dynamic>) {
      return StatistikDiagnosis.fromJson(response);
    }
    return const StatistikDiagnosis(total: 0, items: []);
  }
}

/// Implementasi ProdukService berbasis REST API.
class ApiProdukService implements ProdukService {
  ApiProdukService(this.client);

  final ApiClient client;

  @override
  Future<List<Produk>> listProducts({String? query}) async {
    final response = await client.get(
      '/produk',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    if (response is List) {
      return response
          .map((item) => Produk.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Produk> addProduct(Produk product) async {
    final response = await client.post('/produk', body: product.toJson());
    return Produk.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Produk> updateProduct(Produk product) async {
    final response = await client.put('/produk/${product.id}', body: product.toJson());
    return Produk.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deactivateProduct(int id) async {
    await client.put('/produk/$id', body: {'aktif': false});
  }

  @override
  Future<Produk> adjustStock(
    int id, {
    required int jumlah,
    required String alasan,
  }) async {
    final response = await client.post(
      '/produk/$id/stok',
      body: {'jumlah': jumlah, 'alasan': alasan},
    );
    final json = response as Map<String, dynamic>;
    // Mengembalikan produk dengan stok baru
    final detail = await client.get('/produk/$id');
    if (detail is Map<String, dynamic>) {
      return Produk.fromJson(detail);
    }
    return Produk(
      id: id,
      nama: '',
      kategoriId: 0,
      kategoriNama: '',
      harga: 0,
      stok: (json['stok_baru'] as num).toInt(),
      stokMinimum: 0,
      aktif: true,
    );
  }

  @override
  Future<List<MutasiStok>> listStockMovements(int id) async {
    final response = await client.get('/produk/$id/mutasi');
    if (response is List) {
      return response
          .map((item) => MutasiStok.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

/// Implementasi JasaService berbasis REST API.
class ApiJasaService implements JasaService {
  ApiJasaService(this.client);

  final ApiClient client;

  @override
  Future<List<Jasa>> listServices({String? query}) async {
    final response = await client.get(
      '/jasa',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    if (response is List) {
      return response
          .map((item) => Jasa.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Jasa> addService(Jasa service) async {
    final response = await client.post('/jasa', body: service.toJson());
    return Jasa.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Jasa> updateService(Jasa service) async {
    final response = await client.put('/jasa/${service.id}', body: service.toJson());
    return Jasa.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deactivateService(int id) async {
    await client.put('/jasa/$id', body: {'aktif': false});
  }
}

/// Implementasi KategoriService berbasis REST API.
class ApiKategoriService implements KategoriService {
  ApiKategoriService(this.client);

  final ApiClient client;

  @override
  Future<List<Kategori>> listCategories({String? query}) async {
    final response = await client.get(
      '/kategori',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    if (response is List) {
      return response
          .map((item) => Kategori.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Kategori> addCategory(Kategori category) async {
    final response = await client.post('/kategori', body: category.toJson());
    return Kategori.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Kategori> updateCategory(Kategori category) async {
    final response = await client.put('/kategori/${category.id}', body: category.toJson());
    return Kategori.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deactivateCategory(int id) async {
    await client.put('/kategori/$id', body: {'aktif': false});
  }
}

/// Implementasi KerusakanService berbasis REST API.
class ApiKerusakanService implements KerusakanService {
  ApiKerusakanService(this.client);

  final ApiClient client;

  @override
  Future<List<Gejala>> listGejala({String? query}) async {
    final response = await client.get(
      '/gejala',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    if (response is List) {
      return response
          .map((item) => Gejala.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Kerusakan>> listKerusakan({String? query}) async {
    final response = await client.get(
      '/kerusakan',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    if (response is List) {
      return response
          .map((item) => Kerusakan.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Gejala> addGejala(Gejala gejala) async {
    final response = await client.post('/gejala', body: gejala.toJson());
    return Gejala.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Gejala> updateGejala(Gejala gejala) async {
    final response = await client.put('/gejala/${gejala.id}', body: gejala.toJson());
    return Gejala.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deactivateGejala(int id) async {
    await client.put('/gejala/$id', body: {'aktif': false});
  }

  @override
  Future<Kerusakan> addKerusakan(Kerusakan kerusakan) async {
    final response = await client.post('/kerusakan', body: kerusakan.toJson());
    return Kerusakan.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Kerusakan> updateKerusakan(Kerusakan kerusakan) async {
    final response = await client.put('/kerusakan/${kerusakan.id}', body: kerusakan.toJson());
    return Kerusakan.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deactivateKerusakan(int id) async {
    await client.put('/kerusakan/$id', body: {'aktif': false});
  }
}

/// Implementasi TransaksiService berbasis REST API.
class ApiTransaksiService implements TransaksiService {
  ApiTransaksiService(this.client);

  final ApiClient client;

  @override
  Future<Transaksi> createDraft({
    required String namaPelanggan,
    required String platNomor,
    required List<ItemTransaksiRequest> items,
    int? riwayatDiagnosisId,
  }) async {
    final body = {
      'nama_pelanggan': namaPelanggan,
      'plat_nomor': platNomor,
      'riwayat_diagnosis_id': riwayatDiagnosisId,
      'items': items.map((i) => i.toJson()).toList(),
    };
    final response = await client.post('/transaksi', body: body);
    final id = (response['id'] as num).toInt();
    final detail = await getTransaction(id);
    return detail ?? Transaksi.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Transaksi> updateDraft(Transaksi transaction) async {
    final body = {
      'nama_pelanggan': transaction.namaPelanggan,
      'plat_nomor': transaction.platNomor,
      'items': transaction.items.map((i) {
        return {
          'tipe': i.tipe,
          'id': i.produkId ?? i.jasaId,
          'jumlah': i.jumlah,
        };
      }).toList(),
    };
    await client.put('/transaksi/${transaction.id}', body: body);
    final detail = await getTransaction(transaction.id);
    return detail ?? transaction;
  }

  @override
  Future<List<Transaksi>> listTransactions({String? status, String? query}) async {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (query != null && query.isNotEmpty) params['q'] = query;

    final response = await client.get(
      '/transaksi',
      queryParameters: params.isEmpty ? null : params,
    );
    if (response is List) {
      return response
          .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Transaksi?> getTransaction(int id) async {
    final response = await client.get('/transaksi/$id');
    if (response is Map<String, dynamic>) {
      return Transaksi.fromJson(response);
    }
    return null;
  }

  @override
  Future<Transaksi> finalizeTransaction(
    int id, {
    required String metodeBayar,
    required int jumlahDibayar,
  }) async {
    final response = await client.post(
      '/transaksi/$id/finalisasi',
      body: {
        'metode_bayar': metodeBayar,
        'jumlah_dibayar': jumlahDibayar,
      },
    );
    return Transaksi.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Transaksi?> getReceipt(int id) async {
    final response = await client.get('/transaksi/$id/nota');
    if (response is Map<String, dynamic>) {
      return Transaksi.fromJson(response);
    }
    return null;
  }
}

/// Implementasi LaporanService berbasis REST API.
class ApiLaporanService implements LaporanService {
  ApiLaporanService(this.client);

  final ApiClient client;

  @override
  Future<LaporanPenjualan> salesReport({
    required String periodeMulai,
    required String periodeSelesai,
  }) async {
    final response = await client.get(
      '/laporan/penjualan',
      queryParameters: {
        'periode_mulai': periodeMulai,
        'periode_selesai': periodeSelesai,
      },
    );
    return LaporanPenjualan.fromJson(response as Map<String, dynamic>);
  }
}

/// Implementasi PenggunaService berbasis REST API.
class ApiPenggunaService implements PenggunaService {
  ApiPenggunaService(this.client);

  final ApiClient client;

  @override
  Future<List<User>> listUsers({String? query}) async {
    final response = await client.get(
      '/pengguna',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    if (response is List) {
      return response
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<User> addUser(User user) async {
    final body = {
      'nama': user.nama,
      'username': user.username,
      'password': user.username ?? 'bengkel123',
      'peran': user.peran,
    };
    final response = await client.post('/pengguna', body: body);
    return User.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<User> updateUser(User user) async {
    final response = await client.put('/pengguna/${user.id}', body: user.toJson());
    return User.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deactivateUser(int id) async {
    await client.put('/pengguna/$id', body: {'aktif': false});
  }

  @override
  Future<bool> resetPassword(int id, String newPassword) async {
    final response = await client.post(
      '/pengguna/$id/reset-password',
      body: {'password_baru': newPassword},
    );
    return response is Map && response['pesan'] != null;
  }
}

/// Implementasi PengaturanBengkelService berbasis REST API.
class ApiPengaturanBengkelService implements PengaturanBengkelService {
  ApiPengaturanBengkelService(this.client);

  final ApiClient client;

  @override
  Future<PengaturanBengkel> getSettings() async {
    final response = await client.get('/pengaturan-bengkel');
    return PengaturanBengkel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PengaturanBengkel> updateSettings(PengaturanBengkel settings) async {
    final response = await client.put('/pengaturan-bengkel', body: settings.toJson());
    return PengaturanBengkel.fromJson(response as Map<String, dynamic>);
  }
}
