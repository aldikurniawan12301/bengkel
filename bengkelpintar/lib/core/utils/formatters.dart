import 'package:intl/intl.dart';

const _indonesianMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String formatRupiah(num amount) {
  return 'Rp${NumberFormat.decimalPattern('id_ID').format(amount.round())}';
}

String formatTanggalIndonesia(DateTime dateTime) {
  final day = dateTime.day.toString();
  final month = _indonesianMonths[dateTime.month - 1];
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day $month ${dateTime.year}, $hour:$minute';
}
