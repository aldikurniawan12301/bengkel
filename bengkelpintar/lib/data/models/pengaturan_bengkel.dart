class PengaturanBengkel {
  const PengaturanBengkel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.telepon,
  });
  final int id;
  final String nama;
  final String alamat;
  final String telepon;
  factory PengaturanBengkel.fromJson(Map<String, dynamic> json) =>
      PengaturanBengkel(
        id: (json['id'] as num?)?.toInt() ?? 1,
        nama: json['nama'] as String,
        alamat: json['alamat'] as String,
        telepon: json['telepon'] as String,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'alamat': alamat,
    'telepon': telepon,
  };
}
