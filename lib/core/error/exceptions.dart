class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class CacheException extends AppException {
  CacheException({String message = 'Local database error occurred'}) : super(message);
}

class NetworkException extends AppException {
  NetworkException({String message = 'Network connection failed'}) : super(message);
}
