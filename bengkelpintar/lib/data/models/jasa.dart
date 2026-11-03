class Jasa {
  const Jasa({
    required this.id,
    required this.nama,
    required this.harga,
    required this.aktif,
  });

  final int id;
  final String nama;
  final int harga;
  final bool aktif;

  factory Jasa.fromJson(Map<String, dynamic> json) => Jasa(
    id: (json['id'] as num).toInt(),
    nama: json['nama'] as String,
    harga: (json['harga'] as num).toInt(),
    aktif: json['aktif'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'harga': harga,
    'aktif': aktif,
  };
}
