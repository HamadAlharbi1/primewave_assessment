// This is the data model that represents an Article. We use it to convert JSON data to Dart objects
class Article {
  final int id;
  final String title;
  final String body;

  // Constructor that requires all mandatory fields
  Article({required this.id, required this.title, required this.body});

  // Factory constructor to convert JSON to Article object
  // We use factory because we want to return an existing object rather than creating a new one each time
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(id: json['id'] as int, title: json['title'] as String, body: json['body'] as String);
  }

  // For testing and debugging, we override toString()
  @override
  String toString() => 'Article(id: $id, title: $title)';
}
