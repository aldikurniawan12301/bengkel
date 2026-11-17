import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import 'api_exceptions.dart';

typedef BaseUrlProvider = String Function();

class ApiClient {
  ApiClient({
    BaseUrlProvider? baseUrlProvider,
    String? apiKey,
    this.timeout = const Duration(seconds: 15),
    HttpClient? httpClient,
  })  : _baseUrlProvider = baseUrlProvider ?? (() => ApiConfig.baseUrl),
        _apiKey = apiKey ??
            const String.fromEnvironment(
              'API_KEY',
              defaultValue: 'bengkelpintar_api_key_lokal',
            ),
        _client = httpClient ?? HttpClient() {
    _client.connectionTimeout = timeout;
  }

  static const String keyToken = 'api_jwt_token';
  static const String keyUserJson = 'api_user_session';

  final BaseUrlProvider _baseUrlProvider;
  final String _apiKey;
  final Duration timeout;
  final HttpClient _client;

  String? _inMemoryToken;

  /// Callback global ketika terjadi 401 Unauthorized (token kedaluwarsa).
  void Function()? onUnauthorized;

  /// Callback global ketika terjadi 403 Forbidden.
  void Function()? onForbidden;

  /// Callback global ketika terjadi kegagalan jaringan fatal.
  void Function()? onNetworkError;

  String get baseUrl {
    final raw = _baseUrlProvider().trim();
    if (raw.endsWith('/')) {
      return raw.substring(0, raw.length - 1);
    }
    return raw;
  }

  Future<String?> getToken() async {
    if (_inMemoryToken != null) return _inMemoryToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _inMemoryToken = prefs.getString(keyToken);
      return _inMemoryToken;
    } catch (_) {
      return null;
    }
  }

  Future<void> setToken(String? token) async {
    _inMemoryToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token == null || token.isEmpty) {
        await prefs.remove(keyToken);
      } else {
        await prefs.setString(keyToken, token);
      }
    } catch (_) {}
  }

  Future<void> clearSession() async {
    _inMemoryToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyToken);
      await prefs.remove(keyUserJson);
    } catch (_) {}
  }

  Uri _resolveUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final baseUri = Uri.parse(baseUrl);

    // Filter out null query parameters
    Map<String, dynamic>? cleanedParams;
    if (queryParameters != null && queryParameters.isNotEmpty) {
      cleanedParams = {};
      queryParameters.forEach((key, value) {
        if (value != null) {
          cleanedParams![key] = value.toString();
        }
      });
    }

    return baseUri.replace(
      path: '${baseUri.path}$cleanPath'.replaceAll('//', '/'),
      queryParameters: cleanedParams?.isEmpty == true ? null : cleanedParams,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      includeAuth: includeAuth,
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(
      method: 'POST',
      path: path,
      body: body,
      queryParameters: queryParameters,
      includeAuth: includeAuth,
    );
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(
      method: 'PUT',
      path: path,
      body: body,
      queryParameters: queryParameters,
      includeAuth: includeAuth,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(
      method: 'DELETE',
      path: path,
      queryParameters: queryParameters,
      includeAuth: includeAuth,
    );
  }

  Future<dynamic> _sendRequest({
    required String method,
    required String path,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    final uri = _resolveUri(path, queryParameters);

    try {
      final request = await _client
          .openUrl(method, uri)
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Koneksi ke server melebihi batas waktu');
      });

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set('X-API-Key', _apiKey);

      if (includeAuth) {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        }
      }

      if (body != null) {
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/json; charset=utf-8',
        );
        final encodedBody = utf8.encode(jsonEncode(body));
        request.add(encodedBody);
      }

      final response = await request.close().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Respon server melebihi batas waktu');
        },
      );

      final responseBody = await utf8.decoder
          .bind(response)
          .join()
          .timeout(
            timeout,
            onTimeout: () => '',
          );

      return _handleResponse(response.statusCode, responseBody);
    } on SocketException catch (e) {
      onNetworkError?.call();
      throw NetworkException('Gagal terhubung ke server: ${e.message}');
    } on TimeoutException catch (e) {
      onNetworkError?.call();
      throw NetworkException(e.message ?? 'Waktu tunggu server habis');
    } on HandshakeException catch (e) {
      onNetworkError?.call();
      throw NetworkException('Gagal membuat koneksi aman (SSL/TLS): ${e.message}');
    } on HttpException catch (e) {
      onNetworkError?.call();
      throw NetworkException('Kesalahan protokol HTTP: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      onNetworkError?.call();
      throw NetworkException('Terjadi kesalahan jaringan: $e');
    }
  }

  dynamic _handleResponse(int statusCode, String responseBody) {
    dynamic parsed;
    if (responseBody.isNotEmpty) {
      try {
        parsed = jsonDecode(responseBody);
      } catch (_) {
        parsed = responseBody;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return parsed;
    }

    String message = 'Terjadi kesalahan (HTTP $statusCode)';
    if (parsed is Map) {
      if (parsed['detail'] is String) {
        message = parsed['detail'] as String;
      } else if (parsed['pesan'] is String) {
        message = parsed['pesan'] as String;
      } else if (parsed['error'] is String) {
        message = parsed['error'] as String;
      }
    }

    if (statusCode == 401) {
      onUnauthorized?.call();
      throw UnauthorizedException(message);
    }
    if (statusCode == 403) {
      onForbidden?.call();
      throw ForbiddenException(message);
    }
    if (statusCode == 404) {
      throw NotFoundException(message);
    }
    if (statusCode >= 500) {
      throw ServerException(message);
    }

    throw ApiException(message, statusCode: statusCode, detail: parsed);
  }

  /// Cek kesehatan server pada basis URL tertentu.
  Future<bool> checkHealth([String? targetUrl]) async {
    final clientToUse = _client;
    try {
      final base = (targetUrl ?? baseUrl).trim().replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$base/health');
      final request = await clientToUse
          .getUrl(uri)
          .timeout(const Duration(seconds: 5));
      request.headers.set('X-API-Key', _apiKey);
      final response = await request.close().timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = await utf8.decoder.bind(response).join();
        final json = jsonDecode(body);
        return json is Map && json['status'] == 'ok';
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
