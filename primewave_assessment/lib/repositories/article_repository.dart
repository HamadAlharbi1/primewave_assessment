import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:primewave_assessment/api/api_client.dart';
import 'package:primewave_assessment/models/article.dart';
import 'package:primewave_assessment/models/article_response.dart';

// This layer is responsible for data management, caching, and retry logic
class ArticleRepository {
  final ApiClient _apiClient;

  // In-memory cache - key is page number
  final Map<int, List<Article>> _cache = {};

  // Retry settings
  final int _maxRetries;
  final Duration _initialBackoff;

  ArticleRepository({ApiClient? apiClient, int maxRetries = 3, Duration? initialBackoff})
    : _apiClient = apiClient ?? ApiClient(),
      _maxRetries = maxRetries,
      _initialBackoff = initialBackoff ?? Duration(milliseconds: 500);

  // Fetch articles with caching and retry
  Future<ArticlesResult> getArticles(int page) async {
    // Check cache first
    if (_cache.containsKey(page)) {
      if (kDebugMode) {
        print('🔄 Retrieving page $page from cache');
      }
      return ArticlesResult(
        articles: _cache[page]!,
        page: page,
        totalPages: -1, // Not returned from cache
      );
    }

    // Data not found in cache, must fetch from network
    if (kDebugMode) {
      print('📡 Fetching page $page from network');
      final startIndex = (page - 1) * 10;
      print('🌐 API URL: ${_apiClient.baseUrl}/posts?_start=$startIndex&_limit=10');
    }

    // Implement retry with exponential backoff
    int attempt = 0;
    Duration backoff = _initialBackoff;

    while (attempt < _maxRetries) {
      try {
        final responseData = await _apiClient.fetchArticles(page);
        final response = ArticlesResponse.fromJson(responseData);

        // Cache the result
        _cache[page] = response.data;

        return ArticlesResult(articles: response.data, page: response.page, totalPages: response.totalPages);
      } catch (e) {
        attempt++;

        if (kDebugMode) {
          print('❌ Error on attempt $attempt: $e');
          print('❌ Error type: ${e.runtimeType}');
        }

        // Re-throw error if it's a 4xx error (except 429 - Too Many Requests)
        if (e is ApiException && e.code >= 400 && e.code < 500 && e.code != 429) {
          rethrow;
        }

        // If we've reached max retries, re-throw the error
        if (attempt >= _maxRetries) rethrow;

        // Calculate wait time with exponential backoff
        // Add small random element to avoid all clients retrying at same time
        final jitter = math.Random().nextInt(200); // jitter between 0-200ms
        final waitTime = backoff + Duration(milliseconds: jitter);

        if (kDebugMode) {
          print('⚠️ Request failed, retrying $attempt/$_maxRetries after ${waitTime.inMilliseconds}ms');
        }
        await Future.delayed(waitTime);

        // Double wait time for next attempt
        backoff *= 2;
      }
    }

    // Will never reach here due to rethrow inside loop
    throw Exception('Failed to fetch articles after multiple attempts');
  }

  // Cleanup resources
  void dispose() {
    _apiClient.dispose();
  }
}

// Result object for articles
class ArticlesResult {
  final List<Article> articles;
  final int page;
  final int totalPages;

  ArticlesResult({required this.articles, required this.page, required this.totalPages});
}
