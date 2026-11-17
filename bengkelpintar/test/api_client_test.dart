import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bengkelpintar/services/api_client.dart';
import 'package:bengkelpintar/services/api_exceptions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient dasar', () {
    test('normalisasi baseUrl membuang trailing slash', () {
      final client1 = ApiClient(baseUrlProvider: () => 'http://localhost:8000/');
      expect(client1.baseUrl, 'http://localhost:8000');

      final client2 = ApiClient(baseUrlProvider: () => 'http://localhost:8000');
      expect(client2.baseUrl, 'http://localhost:8000');
    });

    test('penyimpanan dan pembacaan token jwt', () async {
      final client = ApiClient(baseUrlProvider: () => 'http://localhost:8000');
      expect(await client.getToken(), isNull);

      await client.setToken('token-jwt-rahasia-123');
      expect(await client.getToken(), 'token-jwt-rahasia-123');

      await client.clearSession();
      expect(await client.getToken(), isNull);
    });
  });

  group('ApiClient dengan HttpServer lokal', () {
    late HttpServer server;
    late String serverUrl;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      serverUrl = 'http://${server.address.address}:${server.port}';
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('memanggil GET /health berhasil', () async {
      server.listen((HttpRequest request) {
        if (request.uri.path == '/health') {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'status': 'ok', 'versi': '1.0'}))
            ..close();
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
        }
      });

      final client = ApiClient(baseUrlProvider: () => serverUrl);
      final isHealthy = await client.checkHealth();
      expect(isHealthy, isTrue);

      final resp = await client.get('/health');
      expect(resp, isA<Map>());
      expect(resp['status'], 'ok');
      expect(resp['versi'], '1.0');
    });

    test('mengirim header X-API-Key dan Authorization', () async {
      String? receivedApiKey;
      String? receivedAuth;

      server.listen((HttpRequest request) {
        receivedApiKey = request.headers.value('X-API-Key');
        receivedAuth = request.headers.value('Authorization');
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'pesan': 'berhasil'}))
          ..close();
      });

      final client = ApiClient(
        baseUrlProvider: () => serverUrl,
        apiKey: 'kunci-tes-123',
      );
      await client.setToken('jwt-123');

      final resp = await client.get('/auth/me');
      expect(resp['pesan'], 'berhasil');
      expect(receivedApiKey, 'kunci-tes-123');
      expect(receivedAuth, 'Bearer jwt-123');
    });

    test('memetakan status 401 ke UnauthorizedException', () async {
      bool unauthorizedCalled = false;
      server.listen((HttpRequest request) {
        request.response
          ..statusCode = HttpStatus.unauthorized
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'detail': 'Token telah kedaluwarsa'}))
          ..close();
      });

      final client = ApiClient(baseUrlProvider: () => serverUrl);
      client.onUnauthorized = () {
        unauthorizedCalled = true;
      };

      expect(
        () => client.get('/rahasia'),
        throwsA(isA<UnauthorizedException>()),
      );
      await pumpEventQueue();
      expect(unauthorizedCalled, isTrue);
    });

    test('memetakan status 403 ke ForbiddenException', () async {
      bool forbiddenCalled = false;
      server.listen((HttpRequest request) {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'detail': 'Hanya admin yang boleh'}))
          ..close();
      });

      final client = ApiClient(baseUrlProvider: () => serverUrl);
      client.onForbidden = () {
        forbiddenCalled = true;
      };

      expect(
        () => client.post('/produk', body: {'nama': 'Baru'}),
        throwsA(isA<ForbiddenException>()),
      );
      await pumpEventQueue();
      expect(forbiddenCalled, isTrue);
    });

    test('memetakan status 404 ke NotFoundException', () async {
      server.listen((HttpRequest request) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'detail': 'Produk tidak ditemukan'}))
          ..close();
      });

      final client = ApiClient(baseUrlProvider: () => serverUrl);
      expect(
        () => client.get('/produk/999'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('memetakan koneksi gagal ke NetworkException', () async {
      final client = ApiClient(
        baseUrlProvider: () => 'http://127.0.0.1:59999', // Port mati
        timeout: const Duration(milliseconds: 500),
      );

      expect(
        () => client.get('/health'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
