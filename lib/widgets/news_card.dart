import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';

/// Reusable widget for displaying a single news article card
/// Used in home screen, explore screen, search results, and saved articles
class NewsCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image with error handling
            _buildImage(isDark),

            // Article content (source, title, time)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source label
                  if (article.source != null)
                    Text(
                      article.source!,
                      style: TextStyle(
                        color: const Color(0xFFE53935),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Article title
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Time and author info
                  Row(
                    children: [
                      if (article.publishedAt != null) ...[
                        Text(
                          _formatTime(article.publishedAt!),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        if (article.author != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              article.author!,
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the article image with cached network loading and fallback
  Widget _buildImage(bool isDark) {
    if (article.urlToImage == null || article.urlToImage!.isEmpty) {
      // Fallback placeholder when no image is available
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: article.urlToImage!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53935)),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          child: Center(
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ),
      ),
    );
  }

  /// Format the published time to relative format (e.g., "14m ago", "2h ago")
  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return '';
    }
  }
}
