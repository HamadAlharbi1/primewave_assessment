import 'package:flutter_test/flutter_test.dart';
import 'package:primewave_assessment/models/article.dart';

void main() {
  group('Article Model Tests', () {
    test('should create article from JSON', () {
      // Arrange
      final json = {'id': 1, 'title': 'Test Article', 'body': 'This is a test article body'};

      // Act
      final article = Article.fromJson(json);

      // Assert
      expect(article.id, equals(1));
      expect(article.title, equals('Test Article'));
      expect(article.body, equals('This is a test article body'));
    });

    test('should have correct string representation', () {
      // Arrange
      final article = Article(id: 1, title: 'Test Article', body: 'Test body');

      // Act
      final stringRepresentation = article.toString();

      // Assert
      expect(stringRepresentation, contains('Article(id: 1, title: Test Article)'));
    });
  });
}
