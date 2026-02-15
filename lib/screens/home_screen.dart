import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/news_provider.dart';
import '../models/article.dart';
import '../providers/device_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'article_detail_screen.dart';

/// Home screen - displays top headlines with pull-to-refresh
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark; // Check theme
    final newsAsync =
        ref.watch(topHeadlinesProvider(null)); // Fetch top headlines

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Main content with news articles
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
                return RefreshIndicator(
                  color: const Color(0xFFE53935),
                  onRefresh: () async {
                    // Pull-to-refresh: invalidate and refetch news
                    ref.invalidate(topHeadlinesProvider(null));
                    await ref.read(topHeadlinesProvider(null).future);
                  },
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(isDark),
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
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final article = articles[index];
                              // First article gets featured card, rest get horizontal cards
                              if (index == 0) {
                                return _buildFeaturedGridCard(
                                    article, articles, index, isDark);
                              }
                              return _buildHorizontalNewsCard(
                                  article, articles, index, isDark);
                            },
                            childCount: articles.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Offline banner overlay (shows when no internet)
          _buildOfflineBanner(ref, isDark),
        ],
      ),
    );
  }

  /// Build the top app bar with logo, weather, theme toggle, and profile button
  /// The app bar is pinned and stays visible when scrolling
  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      pinned: true, // Keep app bar visible when scrolling
      elevation: 0, // No shadow
      toolbarHeight: 70,
      title: Row(
        children: [
          // Daily Planet logo on the left
          Image.asset(
            'assets/images/daily_planet_logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          const Spacer(), // Push right-side buttons to the end
          // Weather widget (static display for demo)
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
                // Static temperature display
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
          // Theme toggle button (light/dark mode)
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Consumer(
              builder: (context, ref, _) {
                // Watch theme mode to update icon
                final themeMode = ref.watch(themeModeProvider);
                final isLightMode = themeMode == ThemeMode.light;
                return IconButton(
                  // Show opposite mode icon (dark icon in light mode, vice versa)
                  icon: Icon(
                    isLightMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                  onPressed: () {
                    // Toggle between light and dark mode
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // Profile button - opens bottom sheet with user info and logout
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.person_outline,
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              ),
              onPressed: () => _showProfileSheet(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  // Build offline banner that appears when no internet connection
  Widget _buildOfflineBanner(WidgetRef ref, bool isDark) {
    final isOnlineAsync =
        ref.watch(isOnlineProvider); // Watch connectivity status

    return isOnlineAsync.when(
      data: (isOnline) {
        if (isOnline) {
          return const SizedBox.shrink(); // Hide banner when online
        }
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
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
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
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
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // Build horizontal news card (compact layout with image on right)
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

  // Build featured card for first article (large image on top)
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

  // Format timestamp to relative time (e.g., "2h ago", "1d ago")
  String _formatTime(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      // Show minutes if less than 1 hour ago
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      // Show hours if less than 24 hours ago
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      // Show days if less than 1 week ago
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      // Show formatted date for older articles
      return DateFormat('MMM d').format(date);
    } catch (e) {
      // Return empty string if date parsing fails
      return '';
    }
  }

  // Show profile bottom sheet with user info and logout
  void _showProfileSheet(BuildContext context, bool isDark) {
    final user = ref.read(authStateProvider).value; // Get current user

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color(0xFFE53935),
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                // Close the profile sheet first
                Navigator.pop(context);
                // Show confirmation dialog before logging out
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor:
                        isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    actions: [
                      // Cancel button - returns false
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                      // Logout button - returns true
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                );
                // If user confirmed, perform logout via auth service
                if (shouldLogout == true) {
                  final authService = ref.read(authServiceProvider);
                  await authService.logout();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
