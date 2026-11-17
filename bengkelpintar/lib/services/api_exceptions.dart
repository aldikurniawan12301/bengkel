/// Definisi pengecualian (exception) untuk klien API BengkelPintar.
library;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final dynamic detail;

  @override
  String toString() => message;
}

/// Kesalahan jaringan (server mati, timeout, tidak ada koneksi).
class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Tidak dapat terhubung ke server',
  ]);
}

/// Sesi habis atau kredensial salah (HTTP 401).
class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Sesi telah berakhir',
  ]) : super(statusCode: 401);
}

/// Akses ditolak karena keterbatasan peran (HTTP 403).
class ForbiddenException extends ApiException {
  const ForbiddenException([
    super.message = 'Akses ditolak',
  ]) : super(statusCode: 403);
}

/// Sumber daya tidak ditemukan (HTTP 404).
class NotFoundException extends ApiException {
  const NotFoundException([
    super.message = 'Data tidak ditemukan',
  ]) : super(statusCode: 404);
}

/// Kesalahan internal server (HTTP 500).
class ServerException extends ApiException {
  const ServerException([
    super.message = 'Terjadi kesalahan pada server',
  ]) : super(statusCode: 500);
}
