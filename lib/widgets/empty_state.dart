// lib/widgets/empty_state.dart
import 'package:flutter/material.dart';

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Color? iconColor;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for no items found
class EmptyItemsState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const EmptyItemsState({
    super.key,
    this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No items found',
      message: message ?? 'Try adjusting your filters or check back later.',
      icon: Icons.shopping_bag_outlined,
      action: onRefresh != null
          ? ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            )
          : null,
    );
  }
}

/// Empty state for no internet
class EmptyOfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const EmptyOfflineState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No internet connection',
      message: 'Please check your connection and try again.',
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          : null,
    );
  }
}

