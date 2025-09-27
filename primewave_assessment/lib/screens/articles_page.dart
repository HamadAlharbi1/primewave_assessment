import 'package:flutter/material.dart';
import 'package:primewave_assessment/models/article.dart';
import 'package:primewave_assessment/repositories/article_repository.dart';
import 'package:primewave_assessment/widgets/article_card.dart';
import 'package:primewave_assessment/widgets/error_widget.dart';
import 'package:primewave_assessment/widgets/loading_indicator.dart';

class ArticlesPage extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final IconData? themeIcon;
  final String? themeTooltip;

  const ArticlesPage({super.key, this.onThemeToggle, this.themeIcon, this.themeTooltip});

  @override
  ArticlesPageState createState() => ArticlesPageState();
}

class ArticlesPageState extends State<ArticlesPage> {
  final ArticleRepository _repository = ArticleRepository();
  final ScrollController _scrollController = ScrollController();

  // Data state
  final List<Article> _articles = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Set to track pages currently being loaded to prevent duplicate requests
  final Set<int> _loadingPages = {};

  @override
  void initState() {
    super.initState();
    // Load first page
    _loadArticles();

    // Add scroll listener for infinite loading
    _scrollController.addListener(_scrollListener);
  }

  // Scroll listener for infinite loading
  void _scrollListener() {
    // Check if we're near the bottom of the list
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  // Load next page of articles
  void _loadNextPage() {
    if (_currentPage <= _totalPages) {
      _loadArticles();
    }
  }

  // Load articles from repository
  Future<void> _loadArticles() async {
    // Prevent duplicate loading of the same page
    if (_isLoading || _loadingPages.contains(_currentPage)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadingPages.add(_currentPage); // Mark this page as loading
    });

    try {
      final result = await _repository.getArticles(_currentPage);

      setState(() {
        // Add new articles to the list
        _articles.addAll(result.articles);
        // Update page information
        _totalPages = result.totalPages > 0 ? result.totalPages : _totalPages;
        _currentPage++;
        _isLoading = false;
        _loadingPages.remove(_currentPage - 1); // Remove from loading list
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        _loadingPages.remove(_currentPage); // Remove from loading list on error
      });
    }
  }

  // Display error UI
  Widget _buildErrorWidget() {
    return AppErrorWidget(
      message: 'Error loading articles',
      details: _errorMessage,
      onRetry: _loadArticles,
      icon: Icons.error_outline,
      retryButtonText: 'Retry',
      showDetails: true,
    );
  }

  // Build individual article item
  Widget _buildArticleItem(Article article) {
    return ArticleCard(
      article: article,
      onTap: () {
        // Handle article tap - could navigate to detail page
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on: ${article.title}')));
      },
    );
  }

  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return const ListLoadingIndicator(message: 'Loading more articles...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        actions: [
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(widget.themeIcon ?? Icons.brightness_auto),
              onPressed: widget.onThemeToggle,
              tooltip: widget.themeTooltip ?? 'Toggle Theme',
            ),
        ],
      ),
      body: _hasError
          ? _buildErrorWidget()
          : ListView.builder(
              controller: _scrollController,
              itemCount: _articles.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the end
                if (index == _articles.length) {
                  return _buildLoadingIndicator();
                }

                // Display article
                return _buildArticleItem(_articles[index]);
              },
            ),
    );
  }

  @override
  void dispose() {
    // Cleanup resources
    _scrollController.dispose();
    _repository.dispose();
    super.dispose();
  }
}
