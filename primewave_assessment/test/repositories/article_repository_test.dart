import 'package:flutter_test/flutter_test.dart';
import 'package:primewave_assessment/repositories/article_repository.dart';

void main() {
  group('Article Repository Tests', () {
    test('should create repository instance', () {
      // Arrange & Act
      final repository = ArticleRepository();

      // Assert
      expect(repository, isNotNull);
    });

    test('should have proper constructor parameters', () {
      // Arrange & Act
      final repository = ArticleRepository(maxRetries: 5, initialBackoff: Duration(milliseconds: 1000));

      // Assert
      expect(repository, isNotNull);
    });
  });
}
