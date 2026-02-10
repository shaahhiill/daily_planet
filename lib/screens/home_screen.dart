import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/news_provider.dart';
import '../models/article.dart';
import '../providers/device_provider.dart';
import '../providers/theme_provider.dart';
import 'article_detail_screen.dart';

/// Home screen - displays Editor's Pick carousel and latest news grid
/// This is the main landing screen after login
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
                return CustomScrollView(
                  slivers: [
                    _buildAppBar(isDark),

                    // "Editor's Pick" section title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          "Editor's Pick",
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // News grid - first article full size, rest horizontal
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final article = articles[index];

                            // ONLY FIRST ARTICLE (index 0): Full size featured card
                            if (index == 0) {
                              return _buildFeaturedGridCard(
                                  article, articles, index, isDark);
                            }

                            // ALL OTHER ARTICLES: Horizontal compact cards
                            return _buildHorizontalNewsCard(
                                article, articles, index, isDark);
                          },
                          childCount: articles.length,
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

          const SizedBox(width: 8),

          // Theme toggle button
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Consumer(
              builder: (context, ref, _) {
                // Watch current theme mode
                final themeMode = ref.watch(themeModeProvider);
                final isLightMode = themeMode == ThemeMode.light;

                return IconButton(
                  icon: Icon(
                    // Show sun icon in dark mode, moon in light mode
                    isLightMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                  onPressed: () {
                    // Toggle theme when tapped
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                );
              },
            ),
          ),
        ],
      ),
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

  /// Build horizontal news card (image left/right, text opposite)
  /// Compact layout matching "You may also like" style
  /// Parameters:
  /// - article: Article to display
  /// - articleList: Full list for navigation
  /// - index: Position in list
  /// - isDark: Whether dark mode is active
  Widget _buildHorizontalNewsCard(
    Article article,
    List<Article> articleList,
    int index,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(
              article: article,
              articleList: articleList,
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

                  // Author and time (NEW)
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

  /// Build featured grid card for first article in grid
  /// Shows large image on top, content below (different from carousel overlay style)
  /// Parameters:
  /// - article: Article to display
  /// - articleList: Full list for navigation
  /// - index: Position in list
  /// - isDark: Whether dark mode is active
  Widget _buildFeaturedGridCard(
    Article article,
    List<Article> articleList,
    int index,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(
              article: article,
              articleList: articleList,
              currentIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large image on top
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFE0E0E0),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ),

            // Content below image
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source label
                  if (article.source != null)
                    Text(
                      article.source!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Author and time
                  if (article.author != null || article.publishedAt != null)
                    Text(
                      '${article.author ?? ''} • 1d ago',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                ],
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
