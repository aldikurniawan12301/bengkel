import 'dart:convert';

import 'package:flutter/services.dart';

Future<dynamic> readMockJson(String fileName) async {
  final content = await rootBundle.loadString('assets/mock/$fileName');
  return jsonDecode(content);
}

Future<List<Map<String, dynamic>>> readMockAccounts() async {
  // Password akun mock fase 1 dihapus saat aplikasi tersambung ke server (B-14).
  final data = await readMockJson('akun_mock.json') as List;
  return data.cast<Map<String, dynamic>>();
}
