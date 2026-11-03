import 'gejala.dart';
import 'hasil_diagnosis.dart';
import 'json_helpers.dart';

class RiwayatDiagnosis {
  const RiwayatDiagnosis({
    required this.id,
    required this.penggunaId,
    required this.penggunaNama,
    required this.gejala,
    required this.hasil,
    required this.keyakinan,
    required this.waktu,
  });

  final int id;
  final int penggunaId;
  final String penggunaNama;
  final List<Gejala> gejala;
  final HasilDiagnosis hasil;
  final double keyakinan;
  final DateTime waktu;

  factory RiwayatDiagnosis.fromJson(Map<String, dynamic> json) =>
      RiwayatDiagnosis(
        id: intFromJson(json['id']!),
        penggunaId: intFromJson(json['pengguna_id']!),
        penggunaNama: json['pengguna_nama'] as String,
        gejala: (json['gejala'] as List)
            .map((item) => Gejala.fromJson(item as Map<String, dynamic>))
            .toList(),
        hasil: HasilDiagnosis.fromJson(json['hasil'] as Map<String, dynamic>),
        keyakinan: doubleFromJson(json['keyakinan']!),
        waktu: dateTimeFromJson(json['waktu']!),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'pengguna_id': penggunaId,
    'pengguna_nama': penggunaNama,
    'gejala': gejala.map((item) => item.toJson()).toList(),
    'hasil': hasil.toJson(),
    'keyakinan': keyakinan,
    'waktu': iso8601WithoutZone(waktu),
  };
}
