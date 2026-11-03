class Gejala {
  const Gejala({
    required this.id,
    required this.kode,
    required this.nama,
    required this.kategori,
    required this.aktif,
  });

  final int id;
  final String kode;
  final String nama;
  final String kategori;
  final bool aktif;

  factory Gejala.fromJson(Map<String, dynamic> json) => Gejala(
    id: (json['id'] as num).toInt(),
    kode: json['kode'] as String,
    nama: json['nama'] as String,
    kategori: json['kategori'] as String,
    aktif: json['aktif'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode': kode,
    'nama': nama,
    'kategori': kategori,
    'aktif': aktif,
  };
}
