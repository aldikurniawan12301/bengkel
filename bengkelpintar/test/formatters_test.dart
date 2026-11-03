import 'package:flutter_test/flutter_test.dart';

import 'package:bengkelpintar/core/utils/formatters.dart';

void main() {
  test('memformat rupiah tanpa desimal', () {
    expect(formatRupiah(30000), 'Rp30.000');
  });

  test('memformat tanggal Indonesia', () {
    expect(
      formatTanggalIndonesia(DateTime(2026, 10, 24, 10, 15)),
      '24 Okt 2026, 10:15',
    );
  });
}
