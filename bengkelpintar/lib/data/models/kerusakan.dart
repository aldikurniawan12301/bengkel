class KomponenTerkait {
  const KomponenTerkait({
    required this.produkId,
    required this.nama,
    required this.harga,
  });

  final int produkId;
  final String nama;
  final int harga;

  factory KomponenTerkait.fromJson(Map<String, dynamic> json) =>
      KomponenTerkait(
        produkId: (json['produk_id'] as num).toInt(),
        nama: json['nama'] as String,
        harga: (json['harga'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
    'produk_id': produkId,
    'nama': nama,
    'harga': harga,
  };
}

class JasaTerkait {
  const JasaTerkait({
    required this.jasaId,
    required this.nama,
    required this.harga,
  });

  final int jasaId;
  final String nama;
  final int harga;

  factory JasaTerkait.fromJson(Map<String, dynamic> json) => JasaTerkait(
    jasaId: (json['jasa_id'] as num).toInt(),
    nama: json['nama'] as String,
    harga: (json['harga'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'jasa_id': jasaId,
    'nama': nama,
    'harga': harga,
  };
}

class Kerusakan {
  const Kerusakan({
    required this.id,
    required this.kode,
    required this.nama,
    required this.urgensi,
    required this.solusi,
    required this.estimasiWaktuMenit,
    required this.aktif,
    required this.komponenTerkait,
    required this.jasaTerkait,
  });

  final int id;
  final String kode;
  final String nama;
  final String urgensi;
  final String solusi;
  final int estimasiWaktuMenit;
  final bool aktif;
  final List<KomponenTerkait> komponenTerkait;
  final List<JasaTerkait> jasaTerkait;

  factory Kerusakan.fromJson(Map<String, dynamic> json) => Kerusakan(
    id: (json['id'] as num).toInt(),
    kode: json['kode'] as String,
    nama: json['nama'] as String,
    urgensi: json['urgensi'] as String,
    solusi: json['solusi'] as String,
    estimasiWaktuMenit: (json['estimasi_waktu_menit'] as num).toInt(),
    aktif: json['aktif'] as bool,
    komponenTerkait: (json['komponen_terkait'] as List)
        .map((item) => KomponenTerkait.fromJson(item as Map<String, dynamic>))
        .toList(),
    jasaTerkait: (json['jasa_terkait'] as List)
        .map((item) => JasaTerkait.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode': kode,
    'nama': nama,
    'urgensi': urgensi,
    'solusi': solusi,
    'estimasi_waktu_menit': estimasiWaktuMenit,
    'aktif': aktif,
    'komponen_terkait': komponenTerkait.map((item) => item.toJson()).toList(),
    'jasa_terkait': jasaTerkait.map((item) => item.toJson()).toList(),
  };
}
