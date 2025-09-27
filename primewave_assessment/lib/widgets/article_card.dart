import 'package:flutter/material.dart';
import 'package:primewave_assessment/models/article.dart';

/// Reusable article card widget with consistent styling
/// Follows Material Design principles and supports customization
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool showFullBody;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.margin,
    this.backgroundColor,
    this.showFullBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewText = _getPreviewText();

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article title
              Text(
                article.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Article preview text
              Text(
                previewText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                maxLines: showFullBody ? null : 3,
                overflow: showFullBody ? null : TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Article metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Article ID badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ID: ${article.id}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Read more indicator
                  if (!showFullBody)
                    Row(
                      children: [
                        Text(
                          'Read more',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.primary),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPreviewText() {
    if (showFullBody) {
      return article.body;
    }

    // Show first 100 characters with ellipsis
    if (article.body.length <= 100) {
      return article.body;
    }

    return '${article.body.substring(0, 100)}...';
  }
}

/// Compact version of article card for list views
class CompactArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const CompactArticleCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewText = article.body.length > 80 ? '${article.body.substring(0, 80)}...' : article.body;

    return ListTile(
      title: Text(
        article.title,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        previewText,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${article.id}',
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
        ),
      ),
      onTap: onTap,
    );
  }
}
