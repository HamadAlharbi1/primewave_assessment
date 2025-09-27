// User model that handles various API response formats
class User {
  final int id;
  final String name;
  final DateTime createdAt;

  // Constructor with required fields
  User({required this.id, required this.name, required this.createdAt});

  // Factory constructor to parse JSON with robust error handling
  factory User.fromJson(Map<String, dynamic> json) {
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
      throw FormatException(
        'created_at must be either epoch milliseconds (int) or ISO string, got: ${createdAt.runtimeType}',
      );
    }

    return User(id: id, name: name, createdAt: parsedCreatedAt);
  }

  // Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt.toIso8601String()};
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.name == name && other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, createdAt);
  }
}
