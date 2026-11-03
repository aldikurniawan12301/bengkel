import 'json_helpers.dart';
import 'kerusakan.dart';

class KerusakanPrediksi {
  const KerusakanPrediksi({
    required this.id,
    required this.nama,
    required this.keyakinan,
  });

  final int id;
  final String nama;
  final double keyakinan;

  factory KerusakanPrediksi.fromJson(Map<String, dynamic> json) =>
      KerusakanPrediksi(
        id: intFromJson(json['id']!),
        nama: json['nama'] as String,
        keyakinan: doubleFromJson(json['keyakinan']!),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'keyakinan': keyakinan,
  };
}

class EstimasiBiaya {
  const EstimasiBiaya({
    required this.min,
    required this.max,
    required this.keterangan,
  });

  final int min;
  final int max;
  final String keterangan;

  factory EstimasiBiaya.fromJson(Map<String, dynamic> json) => EstimasiBiaya(
    min: intFromJson(json['min']!),
    max: intFromJson(json['max']!),
    keterangan: json['keterangan'] as String,
  );

  Map<String, dynamic> toJson() => {
    'min': min,
    'max': max,
    'keterangan': keterangan,
  };
}

class HasilDiagnosis {
  const HasilDiagnosis({
    required this.riwayatId,
    required this.kerusakanUtama,
    required this.kemungkinanLain,
    required this.urgensi,
    required this.urgensiKeterangan,
    required this.solusi,
    required this.estimasiWaktuMenit,
    required this.komponenTerkait,
    required this.jasaTerkait,
    required this.estimasiBiaya,
    required this.waktu,
  });

  final int riwayatId;
  final KerusakanPrediksi kerusakanUtama;
  final List<KerusakanPrediksi> kemungkinanLain;
  final String urgensi;
  final String urgensiKeterangan;
  final String solusi;
  final int estimasiWaktuMenit;
  final List<KomponenTerkait> komponenTerkait;
  final List<JasaTerkait> jasaTerkait;
  final EstimasiBiaya estimasiBiaya;
  final DateTime waktu;

  factory HasilDiagnosis.fromJson(Map<String, dynamic> json) => HasilDiagnosis(
    riwayatId: intFromJson(json['riwayat_id']!),
    kerusakanUtama: KerusakanPrediksi.fromJson(
      json['kerusakan_utama'] as Map<String, dynamic>,
    ),
    kemungkinanLain: (json['kemungkinan_lain'] as List)
        .map((item) => KerusakanPrediksi.fromJson(item as Map<String, dynamic>))
        .toList(),
    urgensi: json['urgensi'] as String,
    urgensiKeterangan: json['urgensi_keterangan'] as String,
    solusi: json['solusi'] as String,
    estimasiWaktuMenit: intFromJson(json['estimasi_waktu_menit']!),
    komponenTerkait: (json['komponen_terkait'] as List)
        .map((item) => KomponenTerkait.fromJson(item as Map<String, dynamic>))
        .toList(),
    jasaTerkait: (json['jasa_terkait'] as List)
        .map((item) => JasaTerkait.fromJson(item as Map<String, dynamic>))
        .toList(),
    estimasiBiaya: EstimasiBiaya.fromJson(
      json['estimasi_biaya'] as Map<String, dynamic>,
    ),
    waktu: dateTimeFromJson(json['waktu']!),
  );

  Map<String, dynamic> toJson() => {
    'riwayat_id': riwayatId,
    'kerusakan_utama': kerusakanUtama.toJson(),
    'kemungkinan_lain': kemungkinanLain.map((item) => item.toJson()).toList(),
    'urgensi': urgensi,
    'urgensi_keterangan': urgensiKeterangan,
    'solusi': solusi,
    'estimasi_waktu_menit': estimasiWaktuMenit,
    'komponen_terkait': komponenTerkait.map((item) => item.toJson()).toList(),
    'jasa_terkait': jasaTerkait.map((item) => item.toJson()).toList(),
    'estimasi_biaya': estimasiBiaya.toJson(),
    'waktu': iso8601WithoutZone(waktu),
  };
}
