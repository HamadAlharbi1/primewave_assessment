# Task 2: Robust User Model with Flexible Date Parsing

## Problem Statement

An API sometimes returns:

-   `user` as either an object or null
-   `created_at` as either epoch milliseconds or ISO string

We need to implement a User model that robustly parses these cases and validates required fields.

## Solution Implementation

### User Model Features

The implemented `User` model (`lib/models/user.dart`) provides:

1. **Flexible Date Parsing**: Handles both epoch milliseconds and ISO string formats
2. **Robust Validation**: Validates all required fields with descriptive error messages
3. **Type Safety**: Ensures proper data types for all fields
4. **Null Safety**: Handles null values gracefully with clear error messages
5. **Error Handling**: Provides detailed error messages for debugging

### Key Implementation Details

#### 1. Flexible Date Parsing

```dart
// Parse created_at - handles both epoch milliseconds and ISO string
final createdAt = json['created_at'];
DateTime parsedCreatedAt;

if (createdAt is int) {
  // Handle epoch milliseconds
  parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(createdAt);
} else if (createdAt is String) {
  // Handle ISO string format
  try {
    parsedCreatedAt = DateTime.parse(createdAt);
  } catch (e) {
    throw FormatException('Invalid ISO date format: $createdAt. Error: $e');
  }
} else {
  throw FormatException('created_at must be either epoch milliseconds (int) or ISO string, got: ${createdAt.runtimeType}');
}
```

#### 2. Comprehensive Field Validation

```dart
// Validate required fields
if (!json.containsKey('id') || json['id'] == null) {
  throw FormatException('User id is required and cannot be null');
}

if (!json.containsKey('name') || json['name'] == null) {
  throw FormatException('User name is required and cannot be null');
}

if (!json.containsKey('created_at') || json['created_at'] == null) {
  throw FormatException('User created_at is required and cannot be null');
}
```

#### 3. Type Safety

```dart
// Parse id (must be integer)
final id = json['id'];
if (id is! int) {
  throw FormatException('User id must be an integer, got: ${id.runtimeType}');
}

// Parse name (must be string)
final name = json['name'];
if (name is! String) {
  throw FormatException('User name must be a string, got: ${name.runtimeType}');
}
```

### Test Coverage

The implementation includes comprehensive unit tests (`test/models/user_test.dart`) covering:

#### Required Test Cases

1. **Epoch Milliseconds Format**:

    ```dart
    {"id": 1, "name": "A", "created_at": 1690000000000}
    ```

2. **ISO String Format**:
    ```dart
    {"id": 1, "name": "A", "created_at": "2023-07-20T10:00:00Z"}
    ```

#### Additional Test Cases

-   **Null Handling**: Tests for null user objects and null fields
-   **Missing Fields**: Tests for missing required fields
-   **Type Validation**: Tests for incorrect data types
-   **Invalid Date Formats**: Tests for malformed ISO strings
-   **Edge Cases**: Tests for various edge cases and error conditions

### Error Handling Strategy

The model provides detailed error messages for different failure scenarios:

1. **Missing Fields**: Clear indication of which required field is missing
2. **Null Values**: Specific messages for null values in required fields
3. **Type Errors**: Detailed type information for debugging
4. **Date Parsing**: Specific error messages for invalid date formats

### Usage Examples

#### Successful Parsing

```dart
// Epoch milliseconds
final user1 = User.fromJson({
  'id': 1,
  'name': 'John Doe',
  'created_at': 1690000000000,
});

// ISO string
final user2 = User.fromJson({
  'id': 2,
  'name': 'Jane Smith',
  'created_at': '2023-07-20T10:00:00Z',
});
```

#### Error Handling

```dart
try {
  final user = User.fromJson(invalidJson);
} on FormatException catch (e) {
  print('Validation error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Benefits of This Implementation

1. **Robustness**: Handles various API response formats gracefully
2. **Type Safety**: Ensures data integrity at compile time
3. **Error Clarity**: Provides clear error messages for debugging
4. **Maintainability**: Well-structured code with comprehensive tests
5. **Flexibility**: Easy to extend for additional date formats or fields

### Testing Results

All 16 unit tests pass, covering:

-   ✅ Epoch milliseconds parsing
-   ✅ ISO string parsing
-   ✅ Null value handling
-   ✅ Missing field validation
-   ✅ Type validation
-   ✅ Invalid date format handling
-   ✅ JSON serialization
-   ✅ Equality implementation
-   ✅ String representation

The implementation successfully handles the API's inconsistent response formats while maintaining data integrity and providing clear error feedback.
