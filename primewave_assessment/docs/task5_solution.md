# Task 5: API Consumption Best Practices and Image Security

## Part 1: Five Common Client-Side API Mistakes

### 1. **Not Handling Network Errors Gracefully**
**Mistake**: App crashes or shows blank screens when API calls fail.
**Mitigation**: Implement comprehensive error handling with retry logic, fallback UI states, and user-friendly error messages.

### 2. **Missing Request Timeouts**
**Mistake**: API calls hang indefinitely, blocking UI and consuming resources.
**Mitigation**: Set reasonable timeouts (5-30 seconds), implement cancellation tokens, and show loading indicators.

### 3. **Not Validating API Response Structure**
**Mistake**: Assuming API responses match expected format, causing runtime crashes.
**Mitigation**: Validate response structure, handle null/missing fields, use type-safe models with proper JSON parsing.

### 4. **Ignoring Rate Limiting and Caching**
**Mistake**: Making redundant API calls, hitting rate limits, and poor performance.
**Mitigation**: Implement request deduplication, respect rate limits with exponential backoff, and cache responses appropriately.

### 5. **Storing Sensitive Data in Client Storage**
**Mistake**: Storing API keys, tokens, or sensitive data in plain text or insecure storage.
**Mitigation**: Use secure storage (Keychain/Keystore), encrypt sensitive data, and implement proper token refresh mechanisms.

## Part 2: Image Loading Security and Implementation

### Security Strategy

To prevent DoS attacks and untrusted content issues when loading images from arbitrary URLs, I would implement a multi-layered defense approach:

1. **URL Validation**: Whitelist allowed domains and validate URL formats
2. **Size Limits**: Enforce maximum image dimensions and file sizes
3. **Content Type Validation**: Verify actual image format matches declared type
4. **Rate Limiting**: Limit concurrent downloads and requests per domain
5. **Sandboxing**: Load images in isolated contexts with CSP headers
6. **Caching**: Implement secure local caching with expiration and size limits

### Defensive Code Implementation

Here's a robust image loading implementation with security measures:

```dart
class SecureImageLoader {
  static const int _maxConcurrentDownloads = 3;
  static const int _maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int _maxImageDimension = 2048;
  static const Set<String> _allowedDomains = {
    'example.com', 'cdn.example.com', 'images.example.com'
  };
  
  static final Semaphore _downloadSemaphore = Semaphore(_maxConcurrentDownloads);
  static final Map<String, Uint8List> _imageCache = {};
  
  static Future<Uint8List?> loadImage(String url) async {
    // Validate URL and domain
    if (!_isValidUrl(url)) {
      throw SecurityException('Invalid or disallowed URL: $url');
    }
    
    // Check cache first
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }
    
    // Limit concurrent downloads
    await _downloadSemaphore.acquire();
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'NewsApp/1.0'},
      ).timeout(Duration(seconds: 10));
      
      // Validate response
      if (response.statusCode != 200) {
        throw NetworkException('Failed to load image: ${response.statusCode}');
      }
      
      // Check content size
      if (response.contentLength != null && response.contentLength! > _maxImageSize) {
        throw SecurityException('Image too large: ${response.contentLength} bytes');
      }
      
      final bytes = response.bodyBytes;
      
      // Validate image format and dimensions
      final imageInfo = await _validateImage(bytes);
      if (!imageInfo.isValid) {
        throw SecurityException('Invalid image format or dimensions');
      }
      
      // Cache the image (with size limit)
      if (_imageCache.length < 100) { // Limit cache size
        _imageCache[url] = bytes;
      }
      
      return bytes;
    } finally {
      _downloadSemaphore.release();
    }
  }
  
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' && _allowedDomains.contains(uri.host);
    } catch (e) {
      return false;
    }
  }
  
  static Future<ImageValidationResult> _validateImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      return ImageValidationResult(
        isValid: image.width <= _maxImageDimension && 
                 image.height <= _maxImageDimension,
        width: image.width,
        height: image.height,
      );
    } catch (e) {
      return ImageValidationResult(isValid: false);
    }
  }
}

class ImageValidationResult {
  final bool isValid;
  final int? width;
  final int? height;
  
  ImageValidationResult({required this.isValid, this.width, this.height});
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
```

### Key Security Features

1. **Domain Whitelisting**: Only allows images from trusted domains
2. **Concurrent Download Limiting**: Prevents resource exhaustion with semaphore
3. **Size and Dimension Validation**: Enforces limits to prevent memory issues
4. **Content Type Validation**: Verifies actual image format
5. **Secure Caching**: Implements size-limited cache with proper cleanup
6. **Timeout Protection**: Prevents hanging requests
7. **HTTPS Enforcement**: Only allows secure connections

This implementation provides comprehensive protection against DoS attacks, malicious content, and resource exhaustion while maintaining good performance through intelligent caching and concurrency control.
