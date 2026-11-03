import 'models/hasil_diagnosis.dart';
import 'models/kerusakan.dart';

String urgensiKeterangan(String urgensi) {
  return switch (urgensi) {
    'rendah' => 'Aman dipakai, cek saat servis rutin',
    'sedang' => 'Masih bisa dipakai, segera cek',
    'tinggi' => 'Segera perbaiki, jangan dipakai',
    _ => '',
  };
}

EstimasiBiaya hitungEstimasiBiaya({
  required List<KomponenTerkait> komponen,
  required List<JasaTerkait> jasa,
}) {
  final componentPrices = komponen.map((item) => item.harga).toList();
  final serviceTotal = jasa.fold<int>(0, (sum, item) => sum + item.harga);
  final componentTotal = componentPrices.fold<int>(
    0,
    (sum, price) => sum + price,
  );
  final cheapestComponent = componentPrices.isEmpty
      ? 0
      : componentPrices.reduce((a, b) => a < b ? a : b);
  return EstimasiBiaya(
    min: serviceTotal + cheapestComponent,
    max: serviceTotal + componentTotal,
    keterangan: 'Perkiraan',
  );
}

HasilDiagnosis? diagnoseMock({
  required Set<String> gejalaCodes,
  required List<Kerusakan> kerusakan,
  required DateTime waktu,
  required int riwayatId,
}) {
  const exampleCodes = {'G01', 'G03', 'G04'};
  if (!gejalaCodes.containsAll(exampleCodes)) return null;

  final main = kerusakan.firstWhere((item) => item.kode == 'K01');
  final alternatives = kerusakan
      .where((item) => item.kode == 'K02' || item.kode == 'K03')
      .toList();
  final mainPrediction = KerusakanPrediksi(
    id: main.id,
    nama: main.nama,
    keyakinan: 0.78,
  );
  return HasilDiagnosis(
    riwayatId: riwayatId,
    kerusakanUtama: mainPrediction,
    kemungkinanLain: [
      KerusakanPrediksi(
        id: alternatives[0].id,
        nama: alternatives[0].nama,
        keyakinan: 0.15,
      ),
      KerusakanPrediksi(
        id: alternatives[1].id,
        nama: alternatives[1].nama,
        keyakinan: 0.07,
      ),
    ],
    urgensi: main.urgensi,
    urgensiKeterangan: urgensiKeterangan(main.urgensi),
    solusi: main.solusi,
    estimasiWaktuMenit: main.estimasiWaktuMenit,
    komponenTerkait: main.komponenTerkait,
    jasaTerkait: main.jasaTerkait,
    estimasiBiaya: main.kode == 'K01'
        ? const EstimasiBiaya(min: 30000, max: 80000, keterangan: 'Perkiraan')
        : hitungEstimasiBiaya(
            komponen: main.komponenTerkait,
            jasa: main.jasaTerkait,
          ),
    waktu: waktu,
  );
}
