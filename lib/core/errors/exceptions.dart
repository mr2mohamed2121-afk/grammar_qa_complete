
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}

class AdException implements Exception {
  final String message;
  AdException(this.message);

  @override
  String toString() => 'AdException: $message';
}

class AdminException implements Exception {
  final String message;
  AdminException(this.message);

  @override
  String toString() => 'AdminException: $message';
}
