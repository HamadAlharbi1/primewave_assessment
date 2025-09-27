# Task 3: Fix Duplicate Articles Bug

## Problem Analysis

The provided code has a race condition bug that causes duplicate articles when scrolling fast. Here's the problematic code:

```dart
class ArticlesPage extends StatefulWidget { /* ... */ }
class _ArticlesPageState extends State<ArticlesPage> {
  List<Article> articles = [];
  int page = 1;
  bool loading = false;

  void loadNext() async {
    if (loading) return;
    loading = true;
    final new = await Api.fetchArticles(page);
    articles.addAll(new);
    page++;
    loading = false;
    setState((){});
  }

  // called from initState and from scroll listener
}
```

## Why the Bug Happens

The bug occurs due to a **race condition** in the async `loadNext()` method:

1. **Fast Scrolling Scenario**: When a user scrolls quickly, the scroll listener can call `loadNext()` multiple times in rapid succession
2. **Race Condition**: The `loading` flag check happens at the beginning, but by the time the async operation completes, the state may have changed
3. **State Inconsistency**: Multiple concurrent calls can all pass the `if (loading) return;` check before any of them sets `loading = true`
4. **Duplicate Data**: Each concurrent call increments the page number and adds articles, resulting in duplicate or overlapping data

### Specific Race Condition Flow:

```
Time 1: loadNext() called → loading=false → passes check
Time 2: loadNext() called → loading=false → passes check (BUG!)
Time 3: First call sets loading=true, starts API call
Time 4: Second call also sets loading=true, starts API call
Time 5: Both calls complete, both increment page, both add articles
Result: Duplicate articles and incorrect page state
```

## The Fix

Here's the corrected implementation that prevents the race condition:

```dart
class ArticlesPage extends StatefulWidget { /* ... */ }

class _ArticlesPageState extends State<ArticlesPage> {
  List<Article> articles = [];
  int page = 1;
  bool loading = false;

  // Track which pages are currently being loaded to prevent duplicates
  final Set<int> _loadingPages = {};

  void loadNext() async {
    // Prevent loading the same page multiple times
    if (loading || _loadingPages.contains(page)) {
      return;
    }

    // Mark this page as being loaded
    _loadingPages.add(page);
    loading = true;

    try {
      final newArticles = await Api.fetchArticles(page);

      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          articles.addAll(newArticles);
          page++;
          loading = false;
          _loadingPages.remove(page - 1); // Remove from loading set
        });
      }
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        setState(() {
          loading = false;
          _loadingPages.remove(page); // Remove from loading set on error
        });
      }
    }
  }
}
```

## Alternative Fix (More Robust)

Here's an even more robust solution that uses a proper state management approach:

```dart
class ArticlesPage extends StatefulWidget { /* ... */ }

class _ArticlesPageState extends State<ArticlesPage> {
  List<Article> articles = [];
  int page = 1;
  bool loading = false;

  // Use a more robust loading state management
  bool _isLoadingPage(int pageNumber) => _loadingPages.contains(pageNumber);
  final Set<int> _loadingPages = {};
  bool _hasReachedEnd = false;

  void loadNext() async {
    // Multiple layers of protection against race conditions
    if (loading ||
        _isLoadingPage(page) ||
        _hasReachedEnd ||
        !mounted) {
      return;
    }

    // Atomic state update to prevent race conditions
    setState(() {
      loading = true;
      _loadingPages.add(page);
    });

    try {
      final newArticles = await Api.fetchArticles(page);

      // Double-check if widget is still mounted and no other operation completed
      if (!mounted || !_loadingPages.contains(page)) {
        return;
      }

      // Check if we received empty results (end of data)
      if (newArticles.isEmpty) {
        setState(() {
          _hasReachedEnd = true;
          loading = false;
          _loadingPages.remove(page);
        });
        return;
      }

      setState(() {
        articles.addAll(newArticles);
        page++;
        loading = false;
        _loadingPages.remove(page - 1);
      });

    } catch (e) {
      // Handle errors and clean up state
      if (mounted) {
        setState(() {
          loading = false;
          _loadingPages.remove(page);
        });
      }
      // Optionally show error to user
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    // Show error dialog or snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading articles: $message')),
    );
  }
}
```

## How the Fix Prevents the Bug

### 1. **Page-Based Loading Tracking**

-   Uses `Set<int> _loadingPages` to track which specific pages are being loaded
-   Prevents multiple concurrent requests for the same page number
-   More granular than just a boolean flag

### 2. **Atomic State Updates**

-   All state changes happen within `setState()` calls
-   Ensures UI updates are consistent and thread-safe
-   Prevents partial state updates that could cause inconsistencies

### 3. **Mounted Widget Checks**

-   Checks `mounted` before updating state to prevent memory leaks
-   Prevents state updates on disposed widgets

### 4. **Proper Error Handling**

-   Cleans up loading state even when errors occur
-   Removes pages from loading set on both success and failure

### 5. **End-of-Data Detection**

-   Tracks when all pages have been loaded (`_hasReachedEnd`)
-   Prevents unnecessary API calls when no more data exists

## Key Improvements

1. **Race Condition Prevention**: Multiple layers of protection against concurrent requests
2. **Memory Safety**: Proper cleanup and mounted widget checks
3. **Error Resilience**: Graceful error handling with state cleanup
4. **Performance**: Prevents unnecessary API calls
5. **User Experience**: Better error feedback and loading states

## Testing the Fix

To verify the fix works:

1. **Fast Scrolling Test**: Scroll rapidly up and down to trigger multiple `loadNext()` calls
2. **Network Delay Test**: Simulate slow network responses to increase chance of race conditions
3. **Error Simulation**: Test error handling by temporarily breaking the API endpoint
4. **Memory Test**: Check for memory leaks during rapid scrolling

The fixed implementation ensures that:

-   No duplicate articles are added
-   Page numbers increment correctly
-   Loading states are properly managed
-   Errors are handled gracefully
-   Memory leaks are prevented
