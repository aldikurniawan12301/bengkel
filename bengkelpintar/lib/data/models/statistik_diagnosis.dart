class StatistikDiagnosisItem {
  const StatistikDiagnosisItem({
    required this.nama,
    required this.jumlah,
    required this.persentase,
  });

  final String nama;
  final int jumlah;
  final double persentase;

  factory StatistikDiagnosisItem.fromJson(Map<String, dynamic> json) =>
      StatistikDiagnosisItem(
        nama: json['nama'] as String,
        jumlah: (json['jumlah'] as num).toInt(),
        persentase: (json['persentase'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'jumlah': jumlah,
    'persentase': persentase,
  };
}

class StatistikDiagnosis {
  const StatistikDiagnosis({required this.total, required this.items});

  final int total;
  final List<StatistikDiagnosisItem> items;

  factory StatistikDiagnosis.fromJson(Map<String, dynamic> json) =>
      StatistikDiagnosis(
        total: (json['total'] as num).toInt(),
        items: (json['items'] as List)
            .map(
              (item) =>
                  StatistikDiagnosisItem.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'total': total,
    'items': items.map((item) => item.toJson()).toList(),
  };
}
