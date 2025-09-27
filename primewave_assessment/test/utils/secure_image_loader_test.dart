import 'package:flutter_test/flutter_test.dart';
import 'package:primewave_assessment/utils/secure_image_loader.dart';

void main() {
  group('SecureImageLoader Tests', () {
    test('should validate URL format correctly', () {
      // Add test domain
      SecureImageLoader.addTrustedDomain('test.com');

      // Invalid URLs should throw SecurityException
      expect(
        () => SecureImageLoader.loadImage('http://test.com/image.jpg'), // HTTP not HTTPS
        throwsA(isA<SecurityException>()),
      );

      expect(
        () => SecureImageLoader.loadImage('https://malicious.com/image.jpg'), // Not in whitelist
        throwsA(isA<SecurityException>()),
      );

      expect(() => SecureImageLoader.loadImage('invalid-url'), throwsA(isA<SecurityException>()));
    });

    test('should provide cache statistics', () {
      // Act
      final stats = SecureImageLoader.getCacheStats();

      // Assert
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['cached_images'], isA<int>());
      expect(stats['cache_limit'], equals(100));
      expect(stats['max_image_size'], equals(5 * 1024 * 1024));
      expect(stats['max_dimension'], equals(2048));
    });

    test('should clear cache', () {
      // Act
      SecureImageLoader.clearCache();

      // Assert - should not throw
      expect(() => SecureImageLoader.clearCache(), returnsNormally);
    });

    test('should add trusted domains', () {
      // Act & Assert - should not throw
      expect(() => SecureImageLoader.addTrustedDomain('example.com'), returnsNormally);
    });
  });

  group('ImageValidationResult Tests', () {
    test('should create valid result', () {
      // Arrange & Act
      final result = ImageValidationResult(isValid: true, width: 100, height: 100);

      // Assert
      expect(result.isValid, isTrue);
      expect(result.width, equals(100));
      expect(result.height, equals(100));
      expect(result.errorMessage, isNull);
    });

    test('should create invalid result with error message', () {
      // Arrange & Act
      final result = ImageValidationResult(isValid: false, errorMessage: 'Image too large');

      // Assert
      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('Image too large'));
    });
  });

  group('Exception Tests', () {
    test('should create SecurityException with message', () {
      // Arrange & Act
      final exception = SecurityException('Test security error');

      // Assert
      expect(exception.message, equals('Test security error'));
      expect(exception.toString(), equals('SecurityException: Test security error'));
    });

    test('should create NetworkException with message', () {
      // Arrange & Act
      final exception = NetworkException('Test network error');

      // Assert
      expect(exception.message, equals('Test network error'));
      expect(exception.toString(), equals('NetworkException: Test network error'));
    });
  });
}
