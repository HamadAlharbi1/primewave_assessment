# Task 1: Articles App with Infinite Scrolling

A Flutter app that implements a single-page interface displaying a paginated list of articles with infinite scrolling, retry mechanisms, and intelligent caching.

## Implementation Overview

The app fetches articles from `GET /articles?page={n}` endpoint and displays them in a scrollable list with the following features:

-   **Infinite Scrolling**: Automatically loads next page when user scrolls near bottom
-   **Exponential Backoff Retry**: Handles network failures gracefully
-   **In-Memory Caching**: Prevents duplicate API calls when scrolling back up
-   **Error Handling**: User-friendly error UI with retry functionality
-   **Clean Architecture**: Separated API client, repository, and UI layers

## API Integration

### Endpoint Format

```
GET /articles?page={n}
```

### Response Format

```json
{
	"page": 1,
	"total_pages": 10,
	"data": [
		{
			"id": 1,
			"title": "Article Title",
			"body": "Article content..."
		}
	]
}
```

### Article Model

```dart
class Article {
  final int id;
  final String title;
  final String body;

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
```

## Retry Implementation with Exponential Backoff

The app implements a robust retry system to handle temporary network errors:

### Key Features:

1. **Initial Wait Period**: 500ms default wait time
2. **Exponential Backoff**: Each failed attempt doubles the wait time (1s → 2s → 4s)
3. **Jitter**: Adds random 0-200ms to prevent thundering herd problem
4. **Smart Error Handling**: Doesn't retry 4xx errors (except 429 - Too Many Requests)
5. **Max Retries**: Limits to 3 attempts before giving up

### Implementation:

```dart
// In ArticleRepository
while (attempt < _maxRetries) {
  try {
    final responseData = await _apiClient.fetchArticles(page);
    // Success - return data
  } catch (e) {
    // Re-throw 4xx errors (except 429)
    if (e is ApiException && e.code >= 400 && e.code < 500 && e.code != 429) {
      rethrow;
    }

    // Calculate backoff with jitter
    final jitter = math.Random().nextInt(200);
    final waitTime = backoff + Duration(milliseconds: jitter);
    await Future.delayed(waitTime);
    backoff *= 2; // Double for next attempt
  }
}
```

## In-Memory Caching Strategy

A simple yet effective caching system prevents duplicate network calls:

### Implementation Details:

1. **Page-Based Caching**: Uses `Map<int, List<Article>>` with page number as key
2. **Cache-First Lookup**: Checks cache before making network requests
3. **Automatic Population**: Caches new data when received from API
4. **Memory Efficient**: Only stores articles in memory during app session

### Code Example:

```dart
// Cache implementation in ArticleRepository
final Map<int, List<Article>> _cache = {};

Future<ArticlesResult> getArticles(int page) async {
  // Check cache first
  if (_cache.containsKey(page)) {
    print('🔄 Retrieving page $page from cache');
    return ArticlesResult(
      articles: _cache[page]!,
      page: page,
      totalPages: -1, // Not returned from cache
    );
  }

  // Fetch from network and cache result
  final responseData = await _apiClient.fetchArticles(page);
  final response = ArticlesResponse.fromJson(responseData);
  _cache[page] = response.data; // Cache the result

  return ArticlesResult(
    articles: response.data,
    page: response.page,
    totalPages: response.totalPages
  );
}
```

## Infinite Scrolling Implementation

The app implements smooth infinite scrolling with the following features:

### Scroll Detection:

```dart
void _scrollListener() {
  // Load next page when 300px from bottom
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 300) {
    _loadNextPage();
  }
}
```

### Duplicate Request Prevention:

```dart
// Track pages currently being loaded
final Set<int> _loadingPages = {};

Future<void> _loadArticles() async {
  // Prevent duplicate loading of the same page
  if (_isLoading || _loadingPages.contains(_currentPage)) {
    return;
  }

  _loadingPages.add(_currentPage);
  // ... load logic
  _loadingPages.remove(_currentPage);
}
```

## Error Handling & User Experience

### Friendly Error UI:

-   Displays clear error messages to users
-   Provides retry button for failed requests
-   Shows loading indicators during network requests
-   Handles both network errors and API errors gracefully

### Error Display:

```dart
Widget _buildErrorWidget() {
  return Center(
    child: Column(
      children: [
        Icon(Icons.error_outline, size: 50, color: Colors.red),
        Text('Error loading articles'),
        Text(_errorMessage),
        ElevatedButton(
          onPressed: _loadArticles,
          child: Text('Retry')
        ),
      ],
    ),
  );
}
```

## Architecture & Code Organization

### Clean Architecture Layers:

1. **API Client** (`lib/api/api_client.dart`):

    - Handles HTTP requests and responses
    - Manages API endpoint communication
    - Converts raw JSON to structured data

2. **Repository** (`lib/repositories/article_repository.dart`):

    - Manages data caching and retry logic
    - Abstracts data source from UI layer
    - Implements business logic for data fetching

3. **UI Layer** (`lib/screens/articles_page.dart`):

    - Handles user interactions and state management
    - Implements infinite scrolling logic
    - Manages loading states and error display

4. **Models** (`lib/models/`):
    - `Article`: Data model with fromJson factory
    - `ArticlesResponse`: API response wrapper
    - Type-safe data structures

## Optimizations for Large Datasets

For handling large datasets in production, the following improvements would be implemented:

### 1. LRU (Least Recently Used) Caching

```dart
class LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _accessOrder = [];

  V? get(K key) {
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return _cache[key];
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.length >= maxSize) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
    }
    _cache[key] = value;
    _accessOrder.add(key);
  }
}
```

### 2. Persistent Storage

-   **Hive**: For simple key-value storage
-   **SQLite**: For complex queries and relationships
-   **Benefits**: Offline functionality, faster subsequent loads, reduced network usage

### 3. Virtual Scrolling

-   Implement efficient ListView with item recycling
-   Only render visible items to reduce memory usage
-   Use `ListView.builder` with proper item extent calculations

### 4. Batch Size Optimization

```dart
// Dynamic page size based on device capabilities
int getOptimalPageSize() {
  final screenHeight = MediaQuery.of(context).size.height;
  final itemHeight = 100.0; // Approximate item height
  return (screenHeight / itemHeight * 2).ceil(); // 2x screen height
}
```

### 5. Data Compression & Network Optimization

-   Request compressed responses (Gzip) from server
-   Implement request deduplication
-   Use connection pooling for HTTP requests
-   Add request/response interceptors for logging

### 6. Background Refresh & Cache Invalidation

```dart
// Background refresh strategy
class CacheManager {
  static const Duration cacheExpiry = Duration(minutes: 30);

  bool isCacheValid(DateTime lastUpdated) {
    return DateTime.now().difference(lastUpdated) < cacheExpiry;
  }

  Future<void> refreshCacheInBackground() async {
    // Refresh most recently accessed pages
    // Implement smart cache invalidation
  }
}
```

## Performance Considerations

### Memory Management:

-   Cache size limits to prevent memory leaks
-   Proper disposal of controllers and resources
-   Efficient widget rebuilding with proper keys

### Network Efficiency:

-   Request deduplication to prevent duplicate calls
-   Connection reuse and pooling
-   Proper timeout configurations

### User Experience:

-   Smooth scrolling with proper loading indicators
-   Offline-first approach with cached data
-   Graceful degradation when network is unavailable

This implementation provides a solid foundation for a production-ready articles app with excellent user experience and robust error handling.
