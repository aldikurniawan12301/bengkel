class Produk {
  const Produk({
    required this.id,
    required this.nama,
    required this.kategoriId,
    required this.kategoriNama,
    required this.harga,
    required this.stok,
    required this.stokMinimum,
    required this.aktif,
  });

  final int id;
  final String nama;
  final int kategoriId;
  final String kategoriNama;
  final int harga;
  final int stok;
  final int stokMinimum;
  final bool aktif;

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
    id: (json['id'] as num).toInt(),
    nama: json['nama'] as String,
    kategoriId: (json['kategori_id'] as num).toInt(),
    kategoriNama: json['kategori_nama'] as String,
    harga: (json['harga'] as num).toInt(),
    stok: (json['stok'] as num).toInt(),
    stokMinimum: (json['stok_minimum'] as num).toInt(),
    aktif: json['aktif'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'kategori_id': kategoriId,
    'kategori_nama': kategoriNama,
    'harga': harga,
    'stok': stok,
    'stok_minimum': stokMinimum,
    'aktif': aktif,
  };
}
