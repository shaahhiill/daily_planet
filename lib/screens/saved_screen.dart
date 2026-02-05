import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/saved_provider.dart';
import '../models/article.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';

/// Saved screen - displays articles that user has bookmarked
/// Articles are stored locally using SharedPreferences
/// User can remove articles by unsaving them from article detail screen
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
                  // ARTICLES LIST: Show all saved articles
                  : _buildArticlesList(context, savedArticles),
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

  /// Build the scrollable list of saved articles
  /// Each article is a NewsCard that navigates to detail on tap
  /// Parameters:
  /// - context: BuildContext for navigation
  /// - articles: List of saved Article objects
  Widget _buildArticlesList(BuildContext context, List<Article> articles) {
    return ListView.builder(
      // Padding around the entire list
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Number of articles to show
      itemCount: articles.length,
      itemBuilder: (context, index) {
        // Get current article from list
        final article = articles[index];

        // Return a news card for each article
        return NewsCard(
          article: article,
          onTap: () {
            // Navigate to article detail screen when tapped
            // User can unsave the article from there
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(
                  article: article,
                  articleList: articles,
                  currentIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
