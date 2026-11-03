class PenjualanPerHari {
  const PenjualanPerHari({
    required this.tanggal,
    required this.total,
    required this.jumlah,
  });

  final String tanggal;
  final int total;
  final int jumlah;

  factory PenjualanPerHari.fromJson(Map<String, dynamic> json) =>
      PenjualanPerHari(
        tanggal: json['tanggal'] as String,
        total: (json['total'] as num).toInt(),
        jumlah: (json['jumlah'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
    'tanggal': tanggal,
    'total': total,
    'jumlah': jumlah,
  };
}

class Terlaris {
  const Terlaris({
    required this.tipe,
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.total,
  });

  final String tipe;
  final int id;
  final String nama;
  final int jumlah;
  final int total;

  factory Terlaris.fromJson(Map<String, dynamic> json) => Terlaris(
    tipe: json['tipe'] as String,
    id: (json['id'] as num).toInt(),
    nama: json['nama'] as String,
    jumlah: (json['jumlah'] as num).toInt(),
    total: (json['total'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'tipe': tipe,
    'id': id,
    'nama': nama,
    'jumlah': jumlah,
    'total': total,
  };
}

class LaporanPenjualan {
  const LaporanPenjualan({
    required this.periodeMulai,
    required this.periodeSelesai,
    required this.totalPenjualan,
    required this.jumlahTransaksi,
    required this.rataRata,
    required this.penjualanPerHari,
    required this.terlaris,
  });

  final String periodeMulai;
  final String periodeSelesai;
  final int totalPenjualan;
  final int jumlahTransaksi;
  final int rataRata;
  final List<PenjualanPerHari> penjualanPerHari;
  final List<Terlaris> terlaris;

  factory LaporanPenjualan.fromJson(Map<String, dynamic> json) =>
      LaporanPenjualan(
        periodeMulai: json['periode_mulai'] as String,
        periodeSelesai: json['periode_selesai'] as String,
        totalPenjualan: (json['total_penjualan'] as num).toInt(),
        jumlahTransaksi: (json['jumlah_transaksi'] as num).toInt(),
        rataRata: (json['rata_rata'] as num).toInt(),
        penjualanPerHari: (json['penjualan_per_hari'] as List)
            .map(
              (item) => PenjualanPerHari.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        terlaris: (json['terlaris'] as List)
            .map((item) => Terlaris.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'periode_mulai': periodeMulai,
    'periode_selesai': periodeSelesai,
    'total_penjualan': totalPenjualan,
    'jumlah_transaksi': jumlahTransaksi,
    'rata_rata': rataRata,
    'penjualan_per_hari': penjualanPerHari
        .map((item) => item.toJson())
        .toList(),
    'terlaris': terlaris.map((item) => item.toJson()).toList(),
  };
}
