import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primewave_assessment/models/article.dart';
import 'package:primewave_assessment/widgets/article_card.dart';

void main() {
  group('ArticleCard Tests', () {
    late Article testArticle;

    setUp(() {
      testArticle = Article(
        id: 1,
        title: 'Test Article Title',
        body:
            'This is a test article body with some content that is longer than 100 characters to test the preview functionality properly.',
      );
    });

    testWidgets('should display article title and body preview', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ArticleCard(article: testArticle)),
        ),
      );

      // Assert
      expect(find.text('Test Article Title'), findsOneWidget);
      expect(find.textContaining('This is a test article body with some content'), findsOneWidget);
      expect(find.text('ID: 1'), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(article: testArticle, onTap: () => tapped = true),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should display full body when showFullBody is true', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ArticleCard(article: testArticle, showFullBody: true)),
        ),
      );

      // Assert
      expect(find.text(testArticle.body), findsOneWidget);
      expect(find.text('Read more'), findsNothing);
    });

    testWidgets('should show read more indicator when showFullBody is false', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ArticleCard(article: testArticle, showFullBody: false)),
        ),
      );

      // Assert
      expect(find.text('Read more'), findsOneWidget);
    });
  });

  group('CompactArticleCard Tests', () {
    late Article testArticle;

    setUp(() {
      testArticle = Article(
        id: 2,
        title: 'Compact Test Article',
        body: 'This is a compact article body that is shorter than 80 characters.',
      );
    });

    testWidgets('should display article in compact format', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompactArticleCard(article: testArticle)),
        ),
      );

      // Assert
      expect(find.text('Compact Test Article'), findsOneWidget);
      expect(find.text('This is a compact article body that is shorter than 80 characters.'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // ID badge
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactArticleCard(article: testArticle, onTap: () => tapped = true),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });
  });
}
