class Kategori {
  const Kategori({required this.id, required this.nama, required this.aktif});
  final int id;
  final String nama;
  final bool aktif;
  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    id: (json['id'] as num).toInt(),
    nama: json['nama'] as String,
    aktif: json['aktif'] as bool,
  );
  Map<String, dynamic> toJson() => {'id': id, 'nama': nama, 'aktif': aktif};
}
