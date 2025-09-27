import 'package:flutter/material.dart';

/// Reusable error widget with consistent styling and retry functionality
/// Provides user-friendly error messages and recovery options
class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryButtonText;
  final bool showDetails;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon,
    this.retryButtonText,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(icon ?? Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),

            // Error message
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Error details (optional)
            if (details != null && showDetails) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error widget specifically for network-related errors
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({super.key, this.onRetry, this.customMessage});

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: customMessage ?? 'Network Error',
      details: 'Please check your internet connection and try again.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      retryButtonText: 'Try Again',
      showDetails: true,
    );
  }
}

/// API error widget for server-related errors
class ApiErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final int? statusCode;
  final VoidCallback? onRetry;

  const ApiErrorWidget({super.key, this.errorMessage, this.statusCode, this.onRetry});

  @override
  Widget build(BuildContext context) {
    String message = 'Server Error';
    String details = 'Something went wrong on our end.';

    if (statusCode != null) {
      switch (statusCode) {
        case 404:
          message = 'Not Found';
          details = 'The requested resource was not found.';
          break;
        case 500:
          message = 'Server Error';
          details = 'Internal server error. Please try again later.';
          break;
        case 401:
          message = 'Unauthorized';
          details = 'Please check your credentials.';
          break;
        case 403:
          message = 'Forbidden';
          details = 'You don\'t have permission to access this resource.';
          break;
        default:
          message = 'Error $statusCode';
          details = errorMessage ?? 'An unexpected error occurred.';
      }
    } else if (errorMessage != null) {
      message = 'Error';
      details = errorMessage!;
    }

    return AppErrorWidget(
      message: message,
      details: details,
      onRetry: onRetry,
      icon: Icons.cloud_off,
      retryButtonText: 'Retry',
      showDetails: true,
    );
  }
}

/// Empty state widget for when no data is available
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? details;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({super.key, required this.message, this.details, this.icon, this.onAction, this.actionText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Icon(icon ?? Icons.inbox_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 16),

            // Empty state message
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            // Details (optional)
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button (optional)
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
