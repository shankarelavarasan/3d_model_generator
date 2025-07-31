import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache entry with TTL support
class CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  final String? tag;

  const CacheEntry({
    required this.value,
    required this.expiresAt,
    this.tag,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'value': value,
        'expiresAt': expiresAt.toIso8601String(),
        'tag': tag,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        value: json['value'],
        expiresAt: DateTime.parse(json['expiresAt']),
        tag: json['tag'],
      );
}

/// Cache manager with memory and persistent storage
class CacheManager {
  static const Duration defaultTTL = Duration(hours: 1);
  static const Duration shortTTL = Duration(minutes: 5);
  static const Duration longTTL = Duration(days: 7);

  final Map<String, CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;
  final StreamController<String> _evictionController = StreamController.broadcast();

  CacheManager() {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadFromPersistent();
    } catch (e) {
      // Fallback to memory-only cache
    }
  }

  /// Get value from cache
  Future<T?> get<T>(String key) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null) {
      if (memoryEntry.isExpired) {
        _memoryCache.remove(key);
        await _removeFromPersistent(key);
        return null;
      }
      return memoryEntry.value as T;
    }

    // Check persistent storage
    if (_prefs != null) {
      final persisted = _prefs!.getString(key);
      if (persisted != null) {
        try {
          final entry = CacheEntry.fromJson(json.decode(persisted));
          if (!entry.isExpired) {
            _memoryCache[key] = entry; // Promote to memory cache
            return entry.value as T;
          } else {
            await _removeFromPersistent(key);
          }
        } catch (e) {
          await _removeFromPersistent(key);
        }
      }
    }

    return null;
  }

  /// Set value in cache
  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    String? tag,
    bool persist = false,
  }) async {
    final ttlDuration = ttl ?? defaultTTL;
    final entry = CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttlDuration),
      tag: tag,
    );

    // Always set in memory cache
    _memoryCache[key] = entry;

    // Persist if requested and available
    if (persist && _prefs != null) {
      try {
        await _prefs!.setString(key, json.encode(entry.toJson()));
      } catch (e) {
        // Ignore persistence errors
      }
    }
  }

  /// Remove specific key from cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _removeFromPersistent(key);
    _evictionController.add(key);
  }

  /// Remove all keys with specific tag
  Future<void> removeByTag(String tag) async {
    final keysToRemove = _memoryCache.entries
        .where((entry) => entry.value.tag == tag)
        .map((entry) => entry.key)
        .toList();

    for (final key in keysToRemove) {
      await remove(key);
    }
  }

  /// Clear all expired entries
  Future<void> clearExpired() async {
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      await remove(key);
    }
  }

  /// Clear entire cache
  Future<void> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      try {
        await _prefs!.clear();
      } catch (e) {
        // Ignore clear errors
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memory_entries': _memoryCache.length,
      'expired_entries': _memoryCache.values.where((e) => e.isExpired).length,
      'total_keys': _memoryCache.keys.length,
    };
  }

  /// Stream of cache eviction events
  Stream<String> get evictionStream => _evictionController.stream;

  /// Load from persistent storage
  Future<void> _loadFromPersistent() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys();
    for (final key in keys) {
      try {
        final persisted = _prefs!.getString(key);
        if (persisted != null) {
          final entry = CacheEntry.fromJson(json.decode(persisted));
          if (!entry.isExpired) {
            _memoryCache[key] = entry;
          } else {
            await _removeFromPersistent(key);
          }
        }
      } catch (e) {
        await _removeFromPersistent(key);
      }
    }
  }

  /// Remove from persistent storage
  Future<void> _removeFromPersistent(String key) async {
    if (_prefs != null) {
      try {
        await _prefs!.remove(key);
      } catch (e) {
        // Ignore removal errors
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _evictionController.close();
  }
}

/// Cache keys for common operations
class CacheKeys {
  static String userModels(String userId) => 'user_models_$userId';
  static String modelDetails(String modelId) => 'model_details_$modelId';
  static String processingStatus(String jobId) => 'processing_status_$jobId';
  static String userProfile(String userId) => 'user_profile_$userId';
  static String fileMetadata(String fileHash) => 'file_metadata_$fileHash';
}

/// Cache tags for grouping related entries
class CacheTags {
  static const String models = 'models';
  static const String userData = 'user_data';
  static const String processing = 'processing';
  static const String fileMetadata = 'file_metadata';
  static const String apiResponses = 'api_responses';
}

/// Cache TTL presets
class CacheTTL {
  static const Duration instant = Duration(seconds: 30);
  static const Duration short = Duration(minutes: 5);
  static const Duration medium = Duration(hours: 1);
  static const Duration long = Duration(days: 7);
  static const Duration permanent = Duration(days: 365);
}