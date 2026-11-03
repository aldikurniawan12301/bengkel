String iso8601WithoutZone(DateTime value) {
  final date =
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
  final time =
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}:'
      '${value.second.toString().padLeft(2, '0')}';
  return '${date}T$time';
}

DateTime dateTimeFromJson(Object value) => DateTime.parse(value as String);

int intFromJson(Object value) => (value as num).toInt();

double doubleFromJson(Object value) => (value as num).toDouble();
