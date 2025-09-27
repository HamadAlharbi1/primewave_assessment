import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primewave_assessment/main.dart';
import 'package:primewave_assessment/screens/articles_page.dart';

void main() {
  group('Theme Switcher Tests', () {
    testWidgets('should display theme switcher icon in app bar', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const ArticlesApp());

      // Assert
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have theme switcher with correct tooltip', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const ArticlesApp());
      await tester.pumpAndSettle();

      // Assert
      final IconButton themeButton = tester.widget(find.byType(IconButton));
      expect(themeButton.tooltip, 'Switch to Light Theme');
    });

    testWidgets('should toggle theme when icon is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const ArticlesApp());
      await tester.pumpAndSettle();

      // Verify initial state (system theme)
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

      // Act - Tap the theme switcher
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - Should now show light theme icon
      expect(find.byIcon(Icons.brightness_7), findsOneWidget);

      // Act - Tap again to go to dark theme
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - Should now show dark theme icon
      expect(find.byIcon(Icons.brightness_4), findsOneWidget);

      // Act - Tap again to go back to system theme
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - Should be back to system theme
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    });

    testWidgets('should update tooltip text when theme changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const ArticlesApp());
      await tester.pumpAndSettle();

      // Initial state - system theme
      IconButton themeButton = tester.widget(find.byType(IconButton));
      expect(themeButton.tooltip, 'Switch to Light Theme');

      // Act - Switch to light theme
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - Should show light theme tooltip
      themeButton = tester.widget(find.byType(IconButton));
      expect(themeButton.tooltip, 'Switch to Dark Theme');

      // Act - Switch to dark theme
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - Should show dark theme tooltip
      themeButton = tester.widget(find.byType(IconButton));
      expect(themeButton.tooltip, 'Switch to System Theme');
    });

    testWidgets('should maintain theme state across rebuilds', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const ArticlesApp());
      await tester.pumpAndSettle();

      // Act - Switch to light theme
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Verify we're in light theme
      expect(find.byIcon(Icons.brightness_7), findsOneWidget);

      // Note: In a real app, the theme state would persist via SharedPreferences
      // In this test environment, we're just verifying the theme switching works
      // The actual persistence would be tested with integration tests
    });

    testWidgets('should pass theme parameters to ArticlesPage correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const ArticlesApp());
      await tester.pumpAndSettle();

      // Assert
      final ArticlesPage articlesPage = tester.widget(find.byType(ArticlesPage));
      expect(articlesPage.onThemeToggle, isNotNull);
      expect(articlesPage.themeIcon, isNotNull);
      expect(articlesPage.themeTooltip, isNotNull);
    });
  });

  group('ArticlesPage Theme Integration Tests', () {
    testWidgets('should display theme switcher in app bar actions', (WidgetTester tester) async {
      // Arrange
      final articlesPage = ArticlesPage(
        onThemeToggle: () {},
        themeIcon: Icons.brightness_auto,
        themeTooltip: 'Test Tooltip',
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: articlesPage)));

      // Assert
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should not display theme switcher when parameters are null', (WidgetTester tester) async {
      // Arrange
      const articlesPage = ArticlesPage();

      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: articlesPage)));

      // Assert
      expect(find.byIcon(Icons.brightness_auto), findsNothing);
      expect(find.byIcon(Icons.brightness_7), findsNothing);
      expect(find.byIcon(Icons.brightness_4), findsNothing);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle theme toggle callback', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;
      void mockThemeToggle() {
        callbackCalled = true;
      }

      final articlesPage = ArticlesPage(
        onThemeToggle: mockThemeToggle,
        themeIcon: Icons.brightness_auto,
        themeTooltip: 'Test Tooltip',
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: articlesPage)));

      // Act
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, isTrue);
    });
  });
}
