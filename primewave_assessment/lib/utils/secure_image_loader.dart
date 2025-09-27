import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Secure image loader with comprehensive security measures
/// Prevents DoS attacks and untrusted content issues
class SecureImageLoader {
  // Security constraints
  static const int _maxConcurrentDownloads = 3;
  static const int _maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int _maxImageDimension = 2048;
  static const Duration _requestTimeout = Duration(seconds: 10);
  static const int _maxCacheSize = 100;

  // Allowed domains - should be configured based on your app's needs
  static final Set<String> _allowedDomains = {
    'jsonplaceholder.typicode.com',
    'picsum.photos',
    'via.placeholder.com',
    // Add your trusted image domains here
  };

  // Concurrency control
  static int _activeDownloads = 0;

  // In-memory cache with size limit
  static final Map<String, Uint8List> _imageCache = {};

  /// Load image securely with all security checks
  static Future<Uint8List?> loadImage(String url) async {
    // Validate URL and domain
    if (!_isValidUrl(url)) {
      if (kDebugMode) {
        print('🚫 Security: Invalid or disallowed URL: $url');
      }
      throw SecurityException('Invalid or disallowed URL: $url');
    }

    // Check cache first
    if (_imageCache.containsKey(url)) {
      if (kDebugMode) {
        print('💾 Cache hit for: $url');
      }
      return _imageCache[url];
    }

    // Limit concurrent downloads
    while (_activeDownloads >= _maxConcurrentDownloads) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    _activeDownloads++;

    try {
      if (kDebugMode) {
        print('📥 Downloading image: $url');
      }

      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'NewsApp/1.0', 'Accept': 'image/*'})
          .timeout(_requestTimeout);

      // Validate HTTP response
      if (response.statusCode != 200) {
        throw NetworkException('Failed to load image: HTTP ${response.statusCode}');
      }

      // Check content size
      final contentLength = response.contentLength;
      if (contentLength != null && contentLength > _maxImageSize) {
        throw SecurityException('Image too large: $contentLength bytes (max: $_maxImageSize)');
      }

      final bytes = response.bodyBytes;

      // Additional size check on actual bytes
      if (bytes.length > _maxImageSize) {
        throw SecurityException('Image too large: ${bytes.length} bytes (max: $_maxImageSize)');
      }

      // Validate image format and dimensions
      final imageInfo = await _validateImage(bytes);
      if (!imageInfo.isValid) {
        throw SecurityException('Invalid image format or dimensions: ${imageInfo.errorMessage}');
      }

      // Cache the image (with size limit)
      if (_imageCache.length < _maxCacheSize) {
        _imageCache[url] = bytes;
        if (kDebugMode) {
          print('💾 Cached image: $url (${bytes.length} bytes)');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ Cache full, not caching: $url');
        }
      }

      return bytes;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load image $url: $e');
      }
      rethrow;
    } finally {
      _activeDownloads--;
    }
  }

  /// Validate URL format and domain whitelist
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Must use HTTPS for security
      if (uri.scheme != 'https') {
        return false;
      }

      // Check domain whitelist
      if (!_allowedDomains.contains(uri.host)) {
        return false;
      }

      // Basic URL format validation
      return uri.host.isNotEmpty && uri.path.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Validate image format and dimensions
  static Future<ImageValidationResult> _validateImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final isValidDimension = image.width <= _maxImageDimension && image.height <= _maxImageDimension;

      String? errorMessage;
      if (!isValidDimension) {
        errorMessage =
            'Dimensions too large: ${image.width}x${image.height} (max: ${_maxImageDimension}x$_maxImageDimension)';
      }

      return ImageValidationResult(
        isValid: isValidDimension,
        width: image.width,
        height: image.height,
        errorMessage: errorMessage,
      );
    } catch (e) {
      return ImageValidationResult(isValid: false, errorMessage: 'Invalid image format: $e');
    }
  }

  /// Clear cache (useful for memory management)
  static void clearCache() {
    _imageCache.clear();
    if (kDebugMode) {
      print('🗑️ Image cache cleared');
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_images': _imageCache.length,
      'cache_limit': _maxCacheSize,
      'max_image_size': _maxImageSize,
      'max_dimension': _maxImageDimension,
    };
  }

  /// Add trusted domain (useful for dynamic configuration)
  static void addTrustedDomain(String domain) {
    _allowedDomains.add(domain);
    if (kDebugMode) {
      print('✅ Added trusted domain: $domain');
    }
  }
}

/// Result of image validation
class ImageValidationResult {
  final bool isValid;
  final int? width;
  final int? height;
  final String? errorMessage;

  ImageValidationResult({required this.isValid, this.width, this.height, this.errorMessage});
}

/// Security-related exception
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

/// Network-related exception
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
