import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../providers/device_provider.dart';
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
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: newsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFE53935)),
              ),
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
              data: (articles) {
                final featuredArticles = articles.take(3).toList();
                final gridArticles = articles.skip(3).toList();

                return CustomScrollView(
                  slivers: [
                    _buildAppBar(isDark),
                    SliverToBoxAdapter(
                      child: _buildEditorsPick(featuredArticles, isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final article = gridArticles[index];
                            return NewsCard(
                              article: article,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ArticleDetailScreen(article: article),
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

          // Offline detection banner at the top
          _buildOfflineBanner(ref, isDark),
        ],
      ),
    );
  }

  /// Build the top app bar with Daily Planet logo and weather widget
  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
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

  /// Build offline detection banner
  /// Shows red banner at top when internet connection is lost
  /// Automatically hides when connection is restored
  /// Parameters:
  /// - ref: WidgetRef to access providers
  /// - isDark: Whether dark mode is active
  Widget _buildOfflineBanner(WidgetRef ref, bool isDark) {
    // Watch the online status provider
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return isOnlineAsync.when(
      data: (isOnline) {
        // Only show banner when offline
        if (isOnline) {
          return const SizedBox.shrink(); // Hide banner when online
        }

        // Show red offline banner
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // Red background for alert
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Offline icon
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  // Offline message
                  const Expanded(
                    child: Text(
                      'No internet connection. Showing offline content.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(), // Hide while checking
      error: (_, __) => const SizedBox.shrink(), // Hide on error
    );
  }
}
