import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bengkelpintar/core/config/server_config.dart';
import 'package:bengkelpintar/core/theme/app_copy.dart';
import 'package:bengkelpintar/services/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('alamat bawaan dipakai tanpa timpaan', () async {
    SharedPreferences.setMockInitialValues({});
    final config = await ServerConfig.load();

    expect(config.effectiveUrl, config.defaultUrl);
    expect(config.hasOverride, isFalse);
  });

  test('alamat tersimpan tetap ada setelah penampung dibuat ulang', () async {
    SharedPreferences.setMockInitialValues({});
    final first = await ServerConfig.load();
    expect(await first.save('https://bengkel.example:8443'), isTrue);

    final second = await ServerConfig.load();
    expect(second.effectiveUrl, 'https://bengkel.example:8443');
    expect(second.hasOverride, isTrue);
  });

  test(
    'validasi alamat server menerima URL valid dan menolak bentuk invalid',
    () {
      expect(ServerConfig.isValidUrl('http://192.168.1.10:8000'), isTrue);
      expect(ServerConfig.isValidUrl('https://bengkel.example'), isTrue);
      expect(ServerConfig.isValidUrl('192.168.1.10:8000'), isFalse);
      expect(ServerConfig.isValidUrl(''), isFalse);
      expect(ServerConfig.isValidUrl('http:///health'), isFalse);
      expect(ServerConfig.isValidUrl('http://'), isFalse);
    },
  );

  test('kembalikan ke bawaan menghapus timpaan', () async {
    SharedPreferences.setMockInitialValues({});
    final config = await ServerConfig.load();
    await config.save('http://192.168.1.20:8000');
    await config.restoreDefault();

    expect(config.effectiveUrl, config.defaultUrl);
    expect(config.hasOverride, isFalse);
    expect(
      (await SharedPreferences.getInstance()).getString(
        ServerConfig.overrideKey,
      ),
      isNull,
    );
  });

  test('mock ServerService sukses untuk alamat valid dan gagal untuk alamat invalid', () async {
    final service = MockServerService();

    expect(await service.checkHealth('http://192.168.1.10:8000'), isTrue);
    expect(await service.checkHealth('alamat-tidak-valid'), isFalse);
    expect(AppCopy.invalidServerAddress, isNotEmpty);
  });
}
