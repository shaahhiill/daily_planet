import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/saved_provider.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

/// Saved screen - displays bookmarked articles
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch the saved articles provider
    // This automatically rebuilds when articles are added/removed
    final savedArticles = ref.watch(savedArticlesProvider);

    return Scaffold(
      // Background color based on theme
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with title and article count
            _buildHeader(savedArticles.length, isDark),

            // Main content area - shows saved articles or empty state
            Expanded(
              child: savedArticles.isEmpty
                  // EMPTY STATE: No saved articles yet
                  ? _buildEmptyState(isDark)
                  // ARTICLES LIST: Show all saved articles in horizontal format
                  : _buildArticlesList(context, savedArticles, isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the header section with title and article count
  /// Parameters:
  /// - count: Number of saved articles
  /// - isDark: Whether dark mode is active
  Widget _buildHeader(int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Saved" title in red
          Text(
            'Saved',
            style: TextStyle(
              color: const Color(0xFFE53935),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle showing number of saved articles
          Text(
            count == 0
                ? 'No saved articles yet' // Empty state message
                : '$count ${count == 1 ? 'article' : 'articles'} saved', // Article count
            style: TextStyle(
              // Dimmed text color based on theme
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the empty state UI when no articles are saved
  /// Shows icon and helpful message to guide user
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large bookmark icon
          Icon(
            Icons.bookmark_outline,
            size: 80,
            // Dimmed icon color based on theme
            color: isDark ? Colors.white24 : Colors.black26,
          ),

          const SizedBox(height: 16),

          // Main message
          Text(
            'No saved articles yet',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Helper text explaining how to save articles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Tap the bookmark icon on any article to save it here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the scrollable list of saved articles in horizontal card format
  /// Each article shows: image (right), text (left), author, time
  /// Parameters:
  /// - context: BuildContext for navigation
  /// - articles: List of saved Article objects
  /// - isDark: Whether dark mode is active
  Widget _buildArticlesList(BuildContext context, List articles, bool isDark) {
    return ListView.builder(
      // Padding around the entire list
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Number of articles to show
      itemCount: articles.length,
      itemBuilder: (context, index) {
        // Get current article from list
        final article = articles[index];

        // Return horizontal card for each article (same style as home screen)
        return _buildHorizontalCard(context, article, articles, index, isDark);
      },
    );
  }

  /// Build horizontal article card (text left, image right, author/time below)
  /// Same style as home screen for consistency
  /// Parameters:
  /// - context: BuildContext for navigation
  /// - article: Article to display
  /// - articles: Full list for navigation
  /// - index: Position in list
  /// - isDark: Whether dark mode is active
  Widget _buildHorizontalCard(BuildContext context, dynamic article,
      List<dynamic> articles, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Navigate to article detail screen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(
              article: article,
              articleList: articles.cast<Article>(),
              currentIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article title and source on LEFT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source label in red
                  if (article.source != null)
                    Text(
                      article.source!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Article title
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Author and time
                  if (article.author != null || article.publishedAt != null)
                    Text(
                      '${article.author ?? 'Unknown'} • ${_formatTime(article.publishedAt ?? '')}',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Article thumbnail on RIGHT
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 24,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  size: 32,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Format timestamp to relative time (e.g., "2h ago", "1d ago")
  /// Parameters:
  /// - dateString: ISO date string from API
  String _formatTime(String dateString) {
    if (dateString.isEmpty) return '';

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
