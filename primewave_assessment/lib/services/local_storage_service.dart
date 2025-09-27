import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local data persistence
/// Handles caching, user preferences, and offline data storage
class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;

  LocalStorageService._();

  /// Singleton instance
  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Keys for different data types
  static const String _articlesCacheKey = 'articles_cache';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _offlineDataKey = 'offline_data';

  /// Save articles to local cache
  Future<void> cacheArticles(Map<String, dynamic> articlesData) async {
    try {
      final jsonString = jsonEncode(articlesData);
      await _prefs!.setString(_articlesCacheKey, jsonString);
      await _prefs!.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

      if (kDebugMode) {
        print('💾 Articles cached successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cache articles: $e');
      }
    }
  }

  /// Retrieve cached articles
  Future<Map<String, dynamic>?> getCachedArticles() async {
    try {
      final jsonString = _prefs!.getString(_articlesCacheKey);
      if (jsonString != null) {
        final articlesData = jsonDecode(jsonString) as Map<String, dynamic>;

        // Check if cache is still valid
        if (_isCacheValid()) {
          if (kDebugMode) {
            print('📖 Retrieved articles from cache');
          }
          return articlesData;
        } else {
          if (kDebugMode) {
            print('⏰ Cache expired, removing stale data');
          }
          await clearArticlesCache();
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to retrieve cached articles: $e');
      }
      return null;
    }
  }

  /// Check if cached data is still valid
  bool _isCacheValid() {
    final lastSync = _prefs!.getInt(_lastSyncKey);
    if (lastSync == null) return false;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - lastSync;
    const cacheValidityDuration = 3600000; // 1 hour in milliseconds

    return cacheAge < cacheValidityDuration;
  }

  /// Clear articles cache
  Future<void> clearArticlesCache() async {
    await _prefs!.remove(_articlesCacheKey);
    await _prefs!.remove(_lastSyncKey);

    if (kDebugMode) {
      print('🗑️ Articles cache cleared');
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final jsonString = jsonEncode(preferences);
      await _prefs!.setString(_userPreferencesKey, jsonString);

      if (kDebugMode) {
        print('💾 User preferences saved');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save user preferences: $e');
      }
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final jsonString = _prefs!.getString(_userPreferencesKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to retrieve user preferences: $e');
      }
    }
    return {};
  }

  /// Save offline data for specific key
  Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      await _prefs!.setString('${_offlineDataKey}_$key', jsonString);

      if (kDebugMode) {
        print('💾 Offline data saved for key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save offline data: $e');
      }
    }
  }

  /// Get offline data for specific key
  Future<Map<String, dynamic>?> getOfflineData(String key) async {
    try {
      final jsonString = _prefs!.getString('${_offlineDataKey}_$key');
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to retrieve offline data: $e');
      }
    }
    return null;
  }

  /// Clear all offline data
  Future<void> clearAllOfflineData() async {
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith(_offlineDataKey)) {
        await _prefs!.remove(key);
      }
    }

    if (kDebugMode) {
      print('🗑️ All offline data cleared');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final lastSync = _prefs!.getInt(_lastSyncKey);
    final isCacheValid = lastSync != null ? _isCacheValid() : false;

    return {
      'has_cached_articles': _prefs!.containsKey(_articlesCacheKey),
      'last_sync': lastSync != null ? DateTime.fromMillisecondsSinceEpoch(lastSync).toIso8601String() : null,
      'cache_valid': isCacheValid,
      'cache_age_minutes': lastSync != null
          ? ((DateTime.now().millisecondsSinceEpoch - lastSync) / 60000).round()
          : null,
    };
  }

  /// Clear all stored data
  Future<void> clearAllData() async {
    await _prefs!.clear();

    if (kDebugMode) {
      print('🗑️ All local data cleared');
    }
  }

  /// Set a simple string value
  Future<void> setString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  /// Get a simple string value
  String? getString(String key) {
    return _prefs!.getString(key);
  }

  /// Set a boolean value
  Future<void> setBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  /// Set an integer value
  Future<void> setInt(String key, int value) async {
    await _prefs!.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    return _prefs!.getInt(key);
  }
}
