/// Base exception class for all application-specific errors
class AppException implements Exception {
  final String message;
  final String code;
  final dynamic details;
  final int? statusCode;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    required this.code,
    this.details,
    this.statusCode,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $code - $message';

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'details': details,
        'statusCode': statusCode,
      };
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(String message, {dynamic details, int? statusCode})
      : super(
          message: message,
          code: 'NETWORK_ERROR',
          details: details,
          statusCode: statusCode ?? 503,
        );
}

/// CAD file processing exceptions
class CADProcessingException extends AppException {
  CADProcessingException(String message, {dynamic details})
      : super(
          message: message,
          code: 'CAD_PROCESSING_ERROR',
          details: details,
          statusCode: 422,
        );
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException(String message, {dynamic details})
      : super(
          message: message,
          code: 'VALIDATION_ERROR',
          details: details,
          statusCode: 400,
        );
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException(String message, {dynamic details})
      : super(
          message: message,
          code: 'AUTH_ERROR',
          details: details,
          statusCode: 401,
        );
}

/// Storage exceptions
class StorageException extends AppException {
  StorageException(String message, {dynamic details})
      : super(
          message: message,
          code: 'STORAGE_ERROR',
          details: details,
          statusCode: 500,
        );
}

/// Rate limiting exceptions
class RateLimitException extends AppException {
  RateLimitException(String message, {int? retryAfter})
      : super(
          message: message,
          code: 'RATE_LIMIT',
          details: {'retryAfter': retryAfter},
          statusCode: 429,
        );
}

/// File format exceptions
class FileFormatException extends AppException {
  FileFormatException(String message, {String? fileType})
      : super(
          message: message,
          code: 'FILE_FORMAT_ERROR',
          details: {'fileType': fileType},
          statusCode: 415,
        );
}

/// Processing timeout exceptions
class ProcessingTimeoutException extends AppException {
  ProcessingTimeoutException(String message, {int? timeoutSeconds})
      : super(
          message: message,
          code: 'PROCESSING_TIMEOUT',
          details: {'timeoutSeconds': timeoutSeconds},
          statusCode: 408,
        );
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  ConfigurationException(String message, {String? configKey})
      : super(
          message: message,
          code: 'CONFIG_ERROR',
          details: {'configKey': configKey},
          statusCode: 500,
        );
}

/// Resource not found exceptions
class ResourceNotFoundException extends AppException {
  ResourceNotFoundException(String resource, {String? id})
      : super(
          message: '$resource not found',
          code: 'NOT_FOUND',
          details: {'resource': resource, 'id': id},
          statusCode: 404,
        );
}

/// Concurrent modification exceptions
class ConcurrentModificationException extends AppException {
  ConcurrentModificationException(String resource)
      : super(
          message: '$resource was modified by another process',
          code: 'CONCURRENT_MODIFICATION',
          details: {'resource': resource},
          statusCode: 409,
        );
}