import 'package:flutter_test/flutter_test.dart';
import 'package:primewave_assessment/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('should parse user with epoch milliseconds created_at', () {
      // Arrange
      final json = {'id': 1, 'name': 'A', 'created_at': 1690000000000};

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, equals(1));
      expect(user.name, equals('A'));
      expect(user.createdAt, equals(DateTime.fromMillisecondsSinceEpoch(1690000000000)));
    });

    test('should parse user with ISO string created_at', () {
      // Arrange
      final json = {'id': 1, 'name': 'A', 'created_at': '2023-07-20T10:00:00Z'};

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, equals(1));
      expect(user.name, equals('A'));
      expect(user.createdAt, equals(DateTime.parse('2023-07-20T10:00:00Z')));
    });

    test('should handle user object being null', () {
      // Arrange
      final json = null;

      // Act & Assert
      expect(() => User.fromJson(json!), throwsA(isA<TypeError>()));
    });

    test('should throw FormatException when id is missing', () {
      // Arrange
      final json = {'name': 'A', 'created_at': 1690000000000};

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'User id is required and cannot be null')),
      );
    });

    test('should throw FormatException when name is missing', () {
      // Arrange
      final json = {'id': 1, 'created_at': 1690000000000};

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'User name is required and cannot be null')),
      );
    });

    test('should throw FormatException when created_at is missing', () {
      // Arrange
      final json = {'id': 1, 'name': 'A'};

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(
          isA<FormatException>().having((e) => e.message, 'message', 'User created_at is required and cannot be null'),
        ),
      );
    });

    test('should throw FormatException when id is null', () {
      // Arrange
      final json = {'id': null, 'name': 'A', 'created_at': 1690000000000};

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'User id is required and cannot be null')),
      );
    });

    test('should throw FormatException when name is null', () {
      // Arrange
      final json = {'id': 1, 'name': null, 'created_at': 1690000000000};

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'User name is required and cannot be null')),
      );
    });

    test('should throw FormatException when created_at is null', () {
      // Arrange
      final json = {'id': 1, 'name': 'A', 'created_at': null};

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(
          isA<FormatException>().having((e) => e.message, 'message', 'User created_at is required and cannot be null'),
        ),
      );
    });

    test('should throw FormatException when id is not an integer', () {
      // Arrange
      final json = {
        'id': '1', // String instead of int
        'name': 'A',
        'created_at': 1690000000000,
      };

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'User id must be an integer, got: String')),
      );
    });

    test('should throw FormatException when name is not a string', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 123, // Number instead of string
        'created_at': 1690000000000,
      };

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'User name must be a string, got: int')),
      );
    });

    test('should throw FormatException when created_at is neither int nor string', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'A',
        'created_at': true, // Boolean instead of int/string
      };

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'created_at must be either epoch milliseconds (int) or ISO string, got: bool',
          ),
        ),
      );
    });

    test('should throw FormatException for invalid ISO date format', () {
      // Arrange
      final json = {'id': 1, 'name': 'A', 'created_at': 'invalid-date-format'};

      // Act & Assert
      expect(
        () => User.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Invalid ISO date format: invalid-date-format'),
          ),
        ),
      );
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final user = User(id: 1, name: 'A', createdAt: DateTime.fromMillisecondsSinceEpoch(1690000000000));

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], equals(1));
      expect(json['name'], equals('A'));
      expect(json['created_at'], equals('2023-07-22T07:26:40.000'));
    });

    test('should implement equality correctly', () {
      // Arrange
      final user1 = User(id: 1, name: 'A', createdAt: DateTime.fromMillisecondsSinceEpoch(1690000000000));
      final user2 = User(id: 1, name: 'A', createdAt: DateTime.fromMillisecondsSinceEpoch(1690000000000));
      final user3 = User(id: 2, name: 'B', createdAt: DateTime.fromMillisecondsSinceEpoch(1690000000000));

      // Act & Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1.hashCode, isNot(equals(user3.hashCode)));
    });

    test('should have correct string representation', () {
      // Arrange
      final user = User(id: 1, name: 'A', createdAt: DateTime.fromMillisecondsSinceEpoch(1690000000000));

      // Act
      final stringRepresentation = user.toString();

      // Assert
      expect(stringRepresentation, contains('User(id: 1, name: A, createdAt:'));
    });
  });
}
