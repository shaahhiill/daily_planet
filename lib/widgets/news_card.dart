import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';

/// Reusable news article card widget
/// Used in search results, explore screen, and other list views
class NewsCard extends StatelessWidget {
  final Article article; // Article data to display
  final VoidCallback onTap; // Callback when card is tapped

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark; // Check current theme

    return GestureDetector(
      onTap: onTap, // Navigate to article detail on tap
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Space between cards
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A1A)
              : Colors.white, // Card background
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image at the top
            _buildImage(isDark),

            // Article text content below image
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source label (e.g., "BBC News", "CNN")
                  if (article.source != null)
                    Text(
                      article.source!,
                      style: TextStyle(
                        color: const Color(0xFFE53935), // Red theme color
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Article title - main headline
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis, // Show ... if too long
                  ),
                  const SizedBox(height: 8),

                  // Time and author metadata
                  Row(
                    children: [
                      if (article.publishedAt != null) ...[
                        // Show relative time (e.g., "2h ago")
                        Text(
                          _formatTime(article.publishedAt!),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        if (article.author != null) ...[
                          // Separator between time and author
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          // Author name
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

  // Build article image with caching and error handling
  Widget _buildImage(bool isDark) {
    // Check if article has an image URL
    if (article.urlToImage == null || article.urlToImage!.isEmpty) {
      // Show placeholder when no image is available
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

    // Load image from network with caching
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: article.urlToImage!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover, // Fill width, crop height
        // Show loading spinner while image loads
        placeholder: (context, url) => Container(
          height: 200,
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53935)),
          ),
        ),
        // Show error icon if image fails to load
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

  // Format timestamp to relative time (e.g., "2h ago", "3d ago")
  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      // Less than 1 hour: show minutes
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      }
      // Less than 1 day: show hours
      else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      }
      // Less than 1 week: show days
      else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      }
      // Older: show date (e.g., "Jan 15")
      else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return ''; // Return empty string if parsing fails
    }
  }
}
