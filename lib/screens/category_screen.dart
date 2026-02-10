import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/hero_card.dart';
import 'article_detail_screen.dart';

/// Category screen - displays news articles filtered by category
/// User arrives here after tapping a category from Explore screen
/// Shows a featured article at top + scrollable list of other articles
class CategoryScreen extends ConsumerWidget {
  // Category ID for API call (e.g., "sports", "technology")
  final String category;

  // Display name for the screen title (e.g., "Sports", "Technology")
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch articles from NewsAPI filtered by this category
    // The provider automatically handles loading, error, and data states
    final newsAsync = ref.watch(topHeadlinesProvider(category));

    return Scaffold(
      // Background color based on theme
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar with back button and category name
            _buildAppBar(context, isDark),

            // Main content area - shows loading/error/data
            Expanded(
              child: newsAsync.when(
                // LOADING STATE: Show circular progress indicator
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    // Red spinner matching app theme
                    color: Color(0xFFE53935),
                  ),
                ),

                // ERROR STATE: Show error icon and message
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large error icon
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        // Dimmed icon color based on theme
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      // Error message text
                      Text(
                        'Failed to load $categoryName news',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // SUCCESS STATE: Show articles
                data: (articles) {
                  // If no articles found, show empty state
                  if (articles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Empty box icon
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          // "No articles" message
                          Text(
                            'No articles found',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Split articles: first one is featured, rest are in list
                  final featuredArticle = articles.first;
                  final listArticles = articles.skip(1).toList();

                  return CustomScrollView(
                    slivers: [
                      // Featured article at the top (large hero card)
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Featured" label
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                'Featured',
                                style: TextStyle(
                                  // Red section header
                                  color: const Color(0xFFE53935),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Large hero card for featured article
                            HeroCard(
                              article: featuredArticle,
                              onTap: () {
                                // Navigate to article detail when tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArticleDetailScreen(
                                      article: featuredArticle,
                                      articleList: articles,
                                      currentIndex: 0,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // List of remaining articles (scrollable)
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Get current article from list
                              final article = listArticles[index];

                              // Return a news card for each article
                              return NewsCard(
                                article: article,
                                onTap: () {
                                  // Navigate to article detail when tapped
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ArticleDetailScreen(
                                        article: article,
                                        articleList: articles,
                                        currentIndex: index +
                                            1, // +1 because first is featured
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            // Number of cards to build
                            childCount: listArticles.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the top app bar with back button and category name
  /// Parameters:
  /// - context: BuildContext for navigation
  /// - isDark: Whether dark mode is active
  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      // App bar height
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      // Background color based on theme
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
        // Bottom border for separation
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button - returns to previous screen
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              // Icon color based on theme
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 8),

          // Category name as screen title
          Text(
            categoryName,
            style: TextStyle(
              // Text color based on theme
              color: isDark ? Colors.white : Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
