import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';

/// Home screen - displays Editor's Pick carousel and latest news grid
/// This is the main landing screen after login
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Controller for the Editor's Pick carousel
  final PageController _carouselController = PageController();

  // Current page index for carousel dots indicator
  int _currentCarouselPage = 0;

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch top headlines from NewsAPI (null = all categories)
    final newsAsync = ref.watch(topHeadlinesProvider(null));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: newsAsync.when(
          // Loading state - show spinner
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53935)),
          ),

          // Error state - show error message
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load news',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Success state - show content
          data: (articles) {
            // Split articles into featured (first 3) and grid (rest)
            final featuredArticles = articles.take(3).toList();
            final gridArticles = articles.skip(3).toList();

            return CustomScrollView(
              slivers: [
                // Top app bar with logo and weather
                _buildAppBar(isDark),

                // Editor's Pick section with carousel
                SliverToBoxAdapter(
                  child: _buildEditorsPick(featuredArticles, isDark),
                ),

                // News grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final article = gridArticles[index];
                        return NewsCard(
                          article: article,
                          onTap: () {
                            // Navigate to article detail on tap
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailScreen(article: article),
                              ),
                            );
                          },
                        );
                      },
                      childCount: gridArticles.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build the top app bar with Daily Planet logo and weather widget
  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      pinned: true, // Keep visible when scrolling
      elevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          // Daily Planet logo on the left
          Image.asset(
            'assets/images/daily_planet_logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          const Spacer(),

          // Weather widget on the right (hardcoded for now)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Color(0xFFE53935), size: 18),
                const SizedBox(width: 6),
                Text(
                  '26°C',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Search icon button
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              ),
              onPressed: () {
                // TODO: Navigate to search when implemented
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build the Editor's Pick section with horizontal carousel
  Widget _buildEditorsPick(List articles, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Editor's Pick",
            style: TextStyle(
              color: const Color(0xFFE53935),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Carousel with featured articles
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              // Update dots indicator when page changes
              setState(() {
                _currentCarouselPage = index;
              });
            },
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return HeroCard(
                article: article,
                onTap: () {
                  // Navigate to article detail on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: article),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Carousel dots indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            articles.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Active dot is red, inactive is gray
                color: _currentCarouselPage == index
                    ? const Color(0xFFE53935)
                    : isDark
                        ? Colors.white24
                        : Colors.black26,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}