// This model represents the complete response from API, including pagination info and data
import 'package:primewave_assessment/models/article.dart';

class ArticlesResponse {
  final int page;
  final int totalPages;
  final List<Article> data;

  ArticlesResponse({required this.page, required this.totalPages, required this.data});

  // Convert from JSON to response model
  factory ArticlesResponse.fromJson(Map<String, dynamic> json) {
    // Convert raw data list to list of Article objects
    final articlesJson = json['data'] as List;
    final articles = articlesJson.map((articleJson) => Article.fromJson(articleJson)).toList();

    return ArticlesResponse(page: json['page'] as int, totalPages: json['total_pages'] as int, data: articles);
  }
}
