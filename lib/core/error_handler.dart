import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:io';

enum ErrorType {
  network,
  authentication,
  upload,
  processing,
  validation,
  timeout,
  storage,
  unknown
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, details: $details, timestamp: $timestamp)';
  }
}

class ErrorHandler {
  static final List<AppError> _errorLog = [];
  static const int _maxLogSize = 100;

  /// Main error handling method
  static void handleError(BuildContext context, dynamic error, {ErrorType? type}) {
    final appError = _categorizeError(error, type);
    _logError(appError);
    _showErrorToUser(context, appError);
  }

  /// Handle authentication specific errors
  static void handleAuthError(BuildContext context, dynamic error) {
    handleError(context, error, type: ErrorType.authentication);
  }

  /// Handle upload specific errors
  static void handleUploadError(BuildContext context, dynamic error) {
    handleError(context, error, type: ErrorType.upload);
  }

  /// Handle processing specific errors
  static void handleProcessingError(BuildContext context, dynamic error) {
    handleError(context, error, type: ErrorType.processing);
  }

  /// Handle network specific errors
  static void handleNetworkError(BuildContext context, dynamic error) {
    handleError(context, error, type: ErrorType.network);
  }

  /// Show success message
  static void handleSuccess(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration ?? Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show warning message
  static void handleWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Categorize error based on type and content
  static AppError _categorizeError(dynamic error, ErrorType? type) {
    if (type != null) {
      return AppError(
        type: type,
        message: _getErrorMessage(error, type),
        details: error.toString(),
        originalError: error,
        stackTrace: StackTrace.current,
      );
    }

    // Auto-categorize based on error content
    final errorString = error.toString().toLowerCase();
    
    if (error is AuthException) {
      return AppError(
        type: ErrorType.authentication,
        message: _getAuthErrorMessage(error),
        details: error.message,
        originalError: error,
        stackTrace: StackTrace.current,
      );
    }
    
    if (error is SocketException || errorString.contains('network') || 
        errorString.contains('connection') || errorString.contains('timeout')) {
      return AppError(
        type: ErrorType.network,
        message: 'Network connection error. Please check your internet connection.',
        details: error.toString(),
        originalError: error,
        stackTrace: StackTrace.current,
      );
    }
    
    if (errorString.contains('upload') || errorString.contains('storage')) {
      return AppError(
        type: ErrorType.upload,
        message: 'File upload failed. Please try again.',
        details: error.toString(),
        originalError: error,
        stackTrace: StackTrace.current,
      );
    }
    
    if (errorString.contains('processing') || errorString.contains('generation')) {
      return AppError(
        type: ErrorType.processing,
        message: '3D model processing failed. Please try again.',
        details: error.toString(),
        originalError: error,
        stackTrace: StackTrace.current,
      );
    }
    
    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return AppError(
        type: ErrorType.validation,
        message: 'Invalid input. Please check your data and try again.',
        details: error.toString(),
        originalError: error,
        stackTrace: StackTrace.current,
      );
    }
    
    return AppError(
      type: ErrorType.unknown,
      message: 'An unexpected error occurred. Please try again.',
      details: error.toString(),
      originalError: error,
      stackTrace: StackTrace.current,
    );
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error, ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Network connection error. Please check your internet connection.';
      case ErrorType.authentication:
        return _getAuthErrorMessage(error);
      case ErrorType.upload:
        return 'File upload failed. Please check your file and try again.';
      case ErrorType.processing:
        return '3D model processing failed. Please try again later.';
      case ErrorType.validation:
        return 'Invalid input. Please check your data and try again.';
      case ErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ErrorType.storage:
        return 'Storage error. Please try again later.';
      case ErrorType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get authentication specific error message
  static String _getAuthErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'Invalid email or password. Please try again.';
        case 'email not confirmed':
          return 'Please check your email and confirm your account.';
        case 'user already registered':
          return 'An account with this email already exists.';
        case 'weak password':
          return 'Password is too weak. Please use a stronger password.';
        default:
          return error.message;
      }
    }
    return 'Authentication failed. Please try again.';
  }

  /// Log error for debugging
  static void _logError(AppError error) {
    // Add to internal log
    _errorLog.add(error);
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }

    // Log to console in debug mode
    developer.log(
      'Error: ${error.message}',
      name: 'ErrorHandler',
      error: error.originalError,
      stackTrace: error.stackTrace,
      level: 1000, // Error level
    );
  }

  /// Show error to user
  static void _showErrorToUser(BuildContext context, AppError error) {
    final color = _getErrorColor(error.type);
    final icon = _getErrorIcon(error.type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.message,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (error.details != null && error.details!.isNotEmpty)
                    Text(
                      error.details!,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: error.type == ErrorType.network ? 5 : 4),
        behavior: SnackBarBehavior.floating,
        action: error.type == ErrorType.network
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  // Could implement retry logic here
                },
              )
            : null,
      ),
    );
  }

  /// Get error color based on type
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.upload:
        return Colors.deepOrange;
      case ErrorType.processing:
        return Colors.purple;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.timeout:
        return Colors.brown;
      case ErrorType.storage:
        return Colors.indigo;
      case ErrorType.unknown:
      default:
        return Colors.red;
    }
  }

  /// Get error icon based on type
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.upload:
        return Icons.cloud_upload;
      case ErrorType.processing:
        return Icons.settings;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.timeout:
        return Icons.timer;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.unknown:
      default:
        return Icons.error;
    }
  }

  /// Get error log for debugging
  static List<AppError> getErrorLog() => List.unmodifiable(_errorLog);

  /// Clear error log
  static void clearErrorLog() => _errorLog.clear();

  /// Get error statistics
  static Map<ErrorType, int> getErrorStats() {
    final stats = <ErrorType, int>{};
    for (final error in _errorLog) {
      stats[error.type] = (stats[error.type] ?? 0) + 1;
    }
    return stats;
  }
}
