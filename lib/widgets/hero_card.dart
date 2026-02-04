import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';

/// Large featured card widget for Editor's Pick section on home screen
/// Displays article with prominent image and overlayed text
class HeroCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const HeroCard({
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
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              _buildBackgroundImage(isDark),

              // Dark gradient overlay for text readability
              _buildGradientOverlay(),

              // Article content at the bottom
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the background image with caching and error handling
  Widget _buildBackgroundImage(bool isDark) {
    if (article.urlToImage == null || article.urlToImage!.isEmpty) {
      // Fallback solid color when no image
      return Container(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: article.urlToImage!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        child: Center(
          child: Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      ),
    );
  }

  /// Build gradient overlay from transparent to black at bottom
  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the text content overlayed on the image
  Widget _buildContent() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source label in red
          if (article.source != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                article.source!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Article title - large and bold
          Text(
            article.title ?? 'No title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Article description - smaller text
          if (article.description != null)
            Text(
              article.description!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                height: 1.4,
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
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                if (article.author != null) ...[
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      article.author!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
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
    );
  }

  /// Format timestamp to relative time (e.g., "2h ago")
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
