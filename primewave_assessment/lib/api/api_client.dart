import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// This layer is responsible for direct API communication and handling HTTP requests
class ApiClient {
  final String baseUrl;
  final http.Client httpClient;

  // Constructor - allows injecting http client and URL for testing
  ApiClient({
    this.baseUrl = 'https://jsonplaceholder.typicode.com', // Using JSONPlaceholder for demo
    http.Client? client,
  }) : httpClient = client ?? http.Client();

  // Method to fetch articles from API
  Future<Map<String, dynamic>> fetchArticles(int page) async {
    // JSONPlaceholder uses _start and _limit for pagination
    final int startIndex = (page - 1) * 10;
    final url = Uri.parse('$baseUrl/posts?_start=$startIndex&_limit=10');

    try {
      // Make GET request
      final response = await httpClient.get(url);

      // Check response status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse the response
        final List<dynamic> articles = jsonDecode(response.body) as List<dynamic>;

        // Get total count for pagination (JSONPlaceholder has 100 posts)
        final int totalCount = 100;
        final int totalPages = (totalCount / 10).ceil();

        // Return in the exact format required by Task 1
        return {
          'page': page,
          'total_pages': totalPages,
          'data': articles
              .map((article) => {'id': article['id'], 'title': article['title'], 'body': article['body']})
              .toList(),
        };
      } else {
        // Server or client error
        throw ApiException(code: response.statusCode, message: 'Failed to load articles: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw custom exceptions as is
      if (e is ApiException) rethrow;

      // Log detailed error information for debugging
      if (kDebugMode) {
        print('API Error Details: $e');
        print('Error Type: ${e.runtimeType}');
      }

      // Convert other exceptions to ApiException with more details
      throw ApiException(
        code: 0, // General error code for non-HTTP errors
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Cleanup - important for closing HTTP connections
  void dispose() {
    httpClient.close();
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final int code;
  final String message;

  ApiException({required this.code, required this.message});

  @override
  String toString() => 'ApiException($code): $message';
}
