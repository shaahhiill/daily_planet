import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';

/// Large featured card for Editor's Pick section
/// Displays article with full-width image and overlayed text
class HeroCard extends StatelessWidget {
  final Article article; // Article data to display
  final VoidCallback onTap; // Callback when card is tapped

  const HeroCard({
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
        height: 300, // Fixed height for featured card
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Layer 1: Background image (bottom layer)
              _buildBackgroundImage(isDark),

              // Layer 2: Dark gradient overlay (middle layer)
              // Makes text readable over any image
              _buildGradientOverlay(),

              // Layer 3: Article text content (top layer)
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  // Build background image with caching and error handling
  Widget _buildBackgroundImage(bool isDark) {
    // Check if article has an image URL
    if (article.urlToImage == null || article.urlToImage!.isEmpty) {
      // Show solid color placeholder when no image
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

    // Load image from network with caching
    return CachedNetworkImage(
      imageUrl: article.urlToImage!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover, // Fill entire card area
      // Show loading spinner while image loads
      placeholder: (context, url) => Container(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        ),
      ),
      // Show error icon if image fails to load
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

  // Build gradient overlay for text readability
  // Creates a fade from transparent at top to dark at bottom
  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Start transparent at top
            end: Alignment.bottomCenter, // End dark at bottom
            colors: [
              Colors.transparent, // Top: see through to image
              Colors.black.withOpacity(0.7), // Bottom: dark for text contrast
            ],
          ),
        ),
      ),
    );
  }

  // Build text content overlayed on image
  Widget _buildContent() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20, // Position at bottom of card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source label with red background badge
          if (article.source != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935), // Red theme color
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

          // Article title - large and prominent
          Text(
            article.title ?? 'No title',
            style: const TextStyle(
              color: Colors.white, // Always white for contrast
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3, // Line height for readability
            ),
            maxLines: 3, // Allow up to 3 lines
            overflow: TextOverflow.ellipsis, // Show ... if too long
          ),
          const SizedBox(height: 8),

          // Article description - smaller supporting text
          if (article.description != null)
            Text(
              article.description!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85), // Slightly transparent
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2, // Limit to 2 lines
              overflow: TextOverflow.ellipsis,
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
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                if (article.author != null) ...[
                  // Separator between time and author
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  // Author name
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
