// lib/core/api_exceptions.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic payload;
  const ApiException(this.message, {this.statusCode, this.payload});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class CooldownException extends ApiException {
  final int? retryAfterSeconds;
  final DateTime? retryAt;

  CooldownException(
      String message, {
        int? statusCode,
        dynamic payload,
        this.retryAfterSeconds,
        this.retryAt,
      }) : super(message, statusCode: statusCode, payload: payload);
}
