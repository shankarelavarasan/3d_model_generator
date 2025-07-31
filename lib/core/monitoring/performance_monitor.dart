import 'dart:async';
import 'dart:developer' as developer;

/// Performance metrics for operations
class PerformanceMetrics {
  final String operation;
  final Duration duration;
  final int? statusCode;
  final String? error;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PerformanceMetrics({
    required this.operation,
    required this.duration,
    this.statusCode,
    this.error,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'statusCode': statusCode,
        'error': error,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}

/// Memory usage tracking
class MemoryInfo {
  final int currentRss;
  final int maxRss;
  final DateTime timestamp;

  const MemoryInfo({
    required this.currentRss,
    required this.maxRss,
    required this.timestamp,
  });

  factory MemoryInfo.current() {
    return MemoryInfo(
      currentRss: _getCurrentRss(),
      maxRss: _getMaxRss(),
      timestamp: DateTime.now(),
    );
  }

  static int _getCurrentRss() {
    // Approximate current memory usage
    return DateTime.now().millisecondsSinceEpoch;
  }

  static int _getMaxRss() {
    // Approximate max memory usage
    return DateTime.now().millisecondsSinceEpoch * 2;
  }
}

/// Performance monitoring and analytics
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, List<PerformanceMetrics>> _metrics = {};
  final StreamController<PerformanceMetrics> _metricsController =
      StreamController.broadcast();
  final StreamController<MemoryInfo> _memoryController =
      StreamController.broadcast();
  Timer? _memoryTimer;

  /// Start monitoring memory usage
  void startMemoryMonitoring({Duration interval = const Duration(seconds: 30)}) {
    _memoryTimer?.cancel();
    _memoryTimer = Timer.periodic(interval, (_) {
      final memory = MemoryInfo.current();
      _memoryController.add(memory);
    });
  }

  /// Stop memory monitoring
  void stopMemoryMonitoring() {
    _memoryTimer?.cancel();
    _memoryTimer = null;
  }

  /// Record operation performance
  Future<T> trackOperation<T>(
    String operation,
    Future<T> Function() operationFn, {
    Map<String, dynamic>? metadata,
  }) async {
    final startTime = DateTime.now();
    int? statusCode;
    String? error;

    try {
      final result = await operationFn();
      statusCode = 200; // Success
      return result;
    } catch (e) {
      error = e.toString();
      statusCode = _getStatusCodeFromError(e);
      rethrow;
    } finally {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final metrics = PerformanceMetrics(
        operation: operation,
        duration: duration,
        statusCode: statusCode,
        error: error,
        timestamp: endTime,
        metadata: metadata,
      );

      _recordMetrics(metrics);
      _metricsController.add(metrics);

      // Log to console in debug mode
      _logMetrics(metrics);
    }
  }

  /// Record synchronous operation
  T trackSyncOperation<T>(
    String operation,
    T Function() operationFn, {
    Map<String, dynamic>? metadata,
  }) {
    final startTime = DateTime.now();
    int? statusCode;
    String? error;

    try {
      final result = operationFn();
      statusCode = 200;
      return result;
    } catch (e) {
      error = e.toString();
      statusCode = _getStatusCodeFromError(e);
      rethrow;
    } finally {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final metrics = PerformanceMetrics(
        operation: operation,
        duration: duration,
        statusCode: statusCode,
        error: error,
        timestamp: endTime,
        metadata: metadata,
      );

      _recordMetrics(metrics);
      _metricsController.add(metrics);
      _logMetrics(metrics);
    }
  }

  /// Get performance statistics for an operation
  Map<String, dynamic> getOperationStats(String operation) {
    final metrics = _metrics[operation] ?? [];
    if (metrics.isEmpty) return {};

    final durations = metrics.map((m) => m.duration.inMilliseconds).toList();
    durations.sort();

    final total = durations.length;
    final errors = metrics.where((m) => m.error != null).length;
    final avg = durations.reduce((a, b) => a + b) ~/ total;
    final p50 = durations[(total * 0.5).floor()];
    final p95 = durations[(total * 0.95).floor()];
    final p99 = durations[(total * 0.99).floor()];

    return {
      'total_requests': total,
      'error_rate': errors / total,
      'avg_duration_ms': avg,
      'p50_duration_ms': p50,
      'p95_duration_ms': p95,
      'p99_duration_ms': p99,
      'min_duration_ms': durations.first,
      'max_duration_ms': durations.last,
    };
  }

  /// Get all operation statistics
  Map<String, Map<String, dynamic>> getAllStats() {
    final stats = <String, Map<String, dynamic>>{};
    for (final operation in _metrics.keys) {
      stats[operation] = getOperationStats(operation);
    }
    return stats;
  }

  /// Clear metrics for an operation
  void clearOperationMetrics(String operation) {
    _metrics.remove(operation);
  }

  /// Clear all metrics
  void clearAllMetrics() {
    _metrics.clear();
  }

  /// Stream of performance metrics
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  /// Stream of memory usage
  Stream<MemoryInfo> get memoryStream => _memoryController.stream;

  /// Export metrics as JSON
  List<Map<String, dynamic>> exportMetrics() {
    final allMetrics = <Map<String, dynamic>>[];
    for (final operationMetrics in _metrics.values) {
      allMetrics.addAll(operationMetrics.map((m) => m.toJson()));
    }
    return allMetrics;
  }

  /// Dispose resources
  void dispose() {
    stopMemoryMonitoring();
    _metricsController.close();
    _memoryController.close();
  }

  /// Record metrics internally
  void _recordMetrics(PerformanceMetrics metrics) {
    _metrics.putIfAbsent(metrics.operation, () => []).add(metrics);

    // Keep only last 1000 metrics per operation
    if (_metrics[metrics.operation]!.length > 1000) {
      _metrics[metrics.operation] =
          _metrics[metrics.operation]!.sublist(_metrics[metrics.operation]!.length - 1000);
    }
  }

  /// Log metrics to console
  void _logMetrics(PerformanceMetrics metrics) {
    final status = metrics.error != null ? 'ERROR' : 'SUCCESS';
    developer.log(
      '${metrics.operation}: ${metrics.duration.inMilliseconds}ms [${status}]',
      name: 'PerformanceMonitor',
      level: metrics.error != null ? developer.Level.SEVERE : developer.Level.INFO,
    );
  }

  /// Extract status code from error
  int _getStatusCodeFromError(dynamic error) {
    // This is a simplified implementation
    // In real implementation, extract from HTTP exceptions, etc.
    if (error.toString().contains('timeout')) return 408;
    if (error.toString().contains('network')) return 503;
    if (error.toString().contains('not found')) return 404;
    return 500;
  }
}

/// Performance tracking utility
class PerformanceTracker {
  final String operation;
  final DateTime startTime;
  final Map<String, dynamic>? metadata;

  PerformanceTracker(this.operation, {this.metadata}) : startTime = DateTime.now();

  /// Complete tracking with result
  T complete<T>(T result, {int? statusCode}) {
    PerformanceMonitor().trackSyncOperation(
      operation,
      () => result,
      metadata: metadata,
    );
    return result;
  }

  /// Complete tracking with error
  void completeWithError(dynamic error) {
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final metrics = PerformanceMetrics(
      operation: operation,
      duration: duration,
      statusCode: 500,
      error: error.toString(),
      timestamp: endTime,
      metadata: metadata,
    );

    PerformanceMonitor()._recordMetrics(metrics);
    PerformanceMonitor()._metricsController.add(metrics);
  }
}

/// Utility function for quick performance tracking
Future<T> trackAsync<T>(
  String operation,
  Future<T> Function() fn, {
  Map<String, dynamic>? metadata,
}) async {
  return PerformanceMonitor().trackOperation(operation, fn, metadata: metadata);
}

/// Utility function for quick sync performance tracking
T trackSync<T>(
  String operation,
  T Function() fn, {
  Map<String, dynamic>? metadata,
}) {
  return PerformanceMonitor().trackSyncOperation(operation, fn, metadata: metadata);
}