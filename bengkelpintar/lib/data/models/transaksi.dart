import 'json_helpers.dart';

class ItemTransaksi {
  const ItemTransaksi({
    required this.id,
    required this.tipe,
    this.produkId,
    this.jasaId,
    required this.nama,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
  });

  final int id;
  final String tipe;
  final int? produkId;
  final int? jasaId;
  final String nama;
  final int jumlah;
  final int hargaSatuan;
  final int subtotal;

  factory ItemTransaksi.fromJson(Map<String, dynamic> json) => ItemTransaksi(
    id: intFromJson(json['id']!),
    tipe: json['tipe'] as String,
    produkId: (json['produk_id'] as num?)?.toInt(),
    jasaId: (json['jasa_id'] as num?)?.toInt(),
    nama: json['nama'] as String,
    jumlah: intFromJson(json['jumlah']!),
    hargaSatuan: intFromJson(json['harga_satuan']!),
    subtotal: intFromJson(json['subtotal']!),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipe': tipe,
    'produk_id': produkId,
    'jasa_id': jasaId,
    'nama': nama,
    'jumlah': jumlah,
    'harga_satuan': hargaSatuan,
    'subtotal': subtotal,
  };
}

class ItemTransaksiRequest {
  const ItemTransaksiRequest({
    required this.tipe,
    required this.id,
    required this.jumlah,
  });

  final String tipe;
  final int id;
  final int jumlah;

  factory ItemTransaksiRequest.fromJson(Map<String, dynamic> json) =>
      ItemTransaksiRequest(
        tipe: json['tipe'] as String,
        id: intFromJson(json['id']!),
        jumlah: intFromJson(json['jumlah']!),
      );

  Map<String, dynamic> toJson() => {'tipe': tipe, 'id': id, 'jumlah': jumlah};
}

class Transaksi {
  const Transaksi({
    required this.id,
    required this.nomor,
    required this.status,
    required this.namaPelanggan,
    required this.platNomor,
    required this.total,
    this.metodeBayar,
    this.jumlahDibayar,
    this.kembalian,
    required this.dibuatOleh,
    required this.dibuatOlehId,
    this.difinalkanOleh,
    this.riwayatDiagnosisId,
    required this.waktu,
    required this.items,
  });

  final int id;
  final String nomor;
  final String status;
  final String namaPelanggan;
  final String platNomor;
  final int total;
  final String? metodeBayar;
  final int? jumlahDibayar;
  final int? kembalian;
  final String dibuatOleh;
  final int dibuatOlehId;
  final String? difinalkanOleh;
  final int? riwayatDiagnosisId;
  final DateTime waktu;
  final List<ItemTransaksi> items;

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
    id: intFromJson(json['id']!),
    nomor: json['nomor'] as String,
    status: json['status'] as String,
    namaPelanggan: json['nama_pelanggan'] as String,
    platNomor: json['plat_nomor'] as String,
    total: intFromJson(json['total']!),
    metodeBayar: json['metode_bayar'] as String?,
    jumlahDibayar: (json['jumlah_dibayar'] as num?)?.toInt(),
    kembalian: (json['kembalian'] as num?)?.toInt(),
    dibuatOleh: json['dibuat_oleh'] as String,
    dibuatOlehId: intFromJson(json['dibuat_oleh_id']!),
    difinalkanOleh: json['difinalkan_oleh'] as String?,
    riwayatDiagnosisId: (json['riwayat_diagnosis_id'] as num?)?.toInt(),
    waktu: dateTimeFromJson(json['waktu']!),
    items: (json['items'] as List)
        .map((item) => ItemTransaksi.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomor': nomor,
    'status': status,
    'nama_pelanggan': namaPelanggan,
    'plat_nomor': platNomor,
    'total': total,
    'metode_bayar': metodeBayar,
    'jumlah_dibayar': jumlahDibayar,
    'kembalian': kembalian,
    'dibuat_oleh': dibuatOleh,
    'dibuat_oleh_id': dibuatOlehId,
    'difinalkan_oleh': difinalkanOleh,
    'riwayat_diagnosis_id': riwayatDiagnosisId,
    'waktu': iso8601WithoutZone(waktu),
    'items': items.map((item) => item.toJson()).toList(),
  };
}
