class MutasiStok {
  const MutasiStok({
    required this.id,
    required this.produkId,
    required this.jumlah,
    required this.alasan,
    required this.waktu,
    required this.dibuatOleh,
  });

  final int id;
  final int produkId;
  final int jumlah;
  final String alasan;
  final DateTime waktu;
  final String dibuatOleh;

  factory MutasiStok.fromJson(Map<String, dynamic> json) => MutasiStok(
    id: (json['id'] as num).toInt(),
    produkId: (json['produk_id'] as num).toInt(),
    jumlah: (json['jumlah'] as num).toInt(),
    alasan: json['alasan'] as String,
    waktu: DateTime.parse(json['waktu'] as String),
    dibuatOleh: json['dibuat_oleh'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'produk_id': produkId,
    'jumlah': jumlah,
    'alasan': alasan,
    'waktu': waktu.toIso8601String(),
    'dibuat_oleh': dibuatOleh,
  };
}
