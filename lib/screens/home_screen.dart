import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/news_provider.dart';
import '../providers/weather_provider.dart';
import '../models/article.dart';
import '../providers/device_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'article_detail_screen.dart';
import 'weather_detail_screen.dart';

/// Home screen - displays top headlines with pull-to-refresh
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Determine current theme mode (light/dark) based on brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Watch the top headlines provider to reactively fetch and display news
    // Passing null fetches general top headlines without category filter
    final newsAsync = ref.watch(topHeadlinesProvider(null));

    return Scaffold(
      // Set background color based on theme: near-black for dark mode, light gray for light mode
      // Note: 0xFFF5F5F5 is an off-white that provides subtle contrast with white containers
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Main content area wrapped in SafeArea to avoid system UI overlaps (notch, status bar, etc.)
          SafeArea(
            // Handle three async states: loading, error, and data
            child: newsAsync.when(
              // Loading state: show centered red spinner while fetching news
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFE53935)),
              ),
              // Error state: display error icon and message if news fetch fails
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
              // Data state: articles loaded successfully, display them in scrollable list
              data: (articles) {
                // Wrap content in RefreshIndicator to enable pull-to-refresh gesture
                return RefreshIndicator(
                  // Use app's red accent color for the refresh spinner
                  color: const Color(0xFFE53935),
                  onRefresh: () async {
                    // When user pulls down to refresh:
                    // 1. Invalidate the cached news data
                    ref.invalidate(topHeadlinesProvider(null));
                    // 2. Wait for fresh data to be fetched from API
                    await ref.read(topHeadlinesProvider(null).future);
                  },
                  // Use CustomScrollView with slivers for advanced scrolling effects
                  child: CustomScrollView(
                    slivers: [
                      // Pinned app bar with logo, weather, theme toggle, and profile
                      _buildAppBar(isDark),
                      // Section header for news articles
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
                      // Scrollable list of news articles with horizontal padding
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final article = articles[index];
                              // Display first article as large featured card with image on top
                              // Remaining articles shown as compact horizontal cards with image on right
                              if (index == 0) {
                                return _buildFeaturedGridCard(
                                    article, articles, index, isDark);
                              }
                              return _buildHorizontalNewsCard(
                                  article, articles, index, isDark);
                            },
                            // Build one card per article
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
          // Overlay banner that appears at top when device loses internet connection
          // Positioned above all content to alert user of offline status
          _buildOfflineBanner(ref, isDark),
        ],
      ),
    );
  }

  /// Build the top app bar with logo, weather, theme toggle, and profile button
  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      // Match scaffold background color for seamless appearance
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      pinned: true, // Keep app bar visible when user scrolls down
      elevation: 0, // Remove shadow/elevation for flat design
      toolbarHeight: 70, // Custom height to accommodate logo and buttons---
      surfaceTintColor: Colors.transparent, // Remove default material overlay color
      scrolledUnderElevation: 0, // No elevation when scrolled under
      title: Row(
        children: [
          // App logo displayed on the left side of header
          Image.asset(
            'assets/images/daily_planet_logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          const Spacer(), // Flexible space that pushes all following widgets to the right
          // Live weather widget — fetches location & calls OpenWeatherMap
          Consumer(
            builder: (context, ref, _) {
              final weatherAsync = ref.watch(weatherProvider);
              return GestureDetector(
                // Navigate to detail screen only when weather data is loaded
                onTap: weatherAsync.value != null
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WeatherDetailScreen(
                              weather: weatherAsync.value!,
                            ),
                          ),
                        )
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: weatherAsync.when(
                    // Loading: tiny spinner
                    loading: () => const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    // Error: graceful fallback
                    error: (_, __) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          color: isDark ? Colors.white54 : Colors.black38,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '--°C',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black38,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Data: real temperature + contextual icon + tap hint
                    data: (weather) {
                      final icon = _weatherIcon(weather.weatherCode);
                      final temp = weather.temperature.round();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: const Color(0xFFE53935), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '$temp°C',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? Colors.white38 : Colors.black26,
                            size: 14,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Theme toggle button - cycles: auto (device) → light → dark → auto
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(themeModeProvider);

                // Icon + tooltip reflect the CURRENT mode so the user knows
                // what they're in, and tapping moves to the next state.
                final IconData icon;
                final String tooltip;
                switch (themeMode) {
                  case ThemeMode.system:
                    icon    = Icons.brightness_auto;
                    tooltip = 'Auto (device) — tap for Light';
                  case ThemeMode.light:
                    icon    = Icons.wb_sunny_outlined;
                    tooltip = 'Light mode — tap for Dark';
                  case ThemeMode.dark:
                    icon    = Icons.dark_mode_outlined;
                    tooltip = 'Dark mode — tap for Auto';
                }

                return IconButton(
                  tooltip: tooltip,
                  icon: Icon(
                    icon,
                    color: isDark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // Profile button - opens modal bottom sheet with user details and logout option
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              shape: BoxShape.circle, // Circular background for icon button
            ),
            child: IconButton(
              icon: Icon(
                Icons.person_outline, // Outline person icon
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              ),
              // Show profile sheet when tapped
              onPressed: () => _showProfileSheet(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// Build offline banner that appears at top of screen when no internet connection
  /// Uses device provider to monitor network connectivity status
  Widget _buildOfflineBanner(WidgetRef ref, bool isDark) {
    // Watch connectivity provider to reactively show/hide banner
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return isOnlineAsync.when(
      // When connectivity data is available
      data: (isOnline) {
        if (isOnline) {
          return const SizedBox.shrink(); // Don't show banner when online
        }
        // Show banner when offline
        return Positioned(
          // Position at top of screen, full width
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935), // Red background for alert
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // WiFi off icon to indicate no connection
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  // Message text explaining offline status
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
      // Don't show banner while checking connectivity
      loading: () => const SizedBox.shrink(),
      // Don't show banner if connectivity check fails
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Build horizontal news card (compact layout with image on right)
  /// Used for all articles except the first one (which uses featured card)
  /// Displays: source, title, author/time on left, thumbnail image on right
  Widget _buildHorizontalNewsCard(
    Article article,
    List<Article> articleList,
    int index,
    bool isDark,
  ) {
    return GestureDetector(
      // Navigate to article detail screen when card is tapped
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(
              article: article, // Current article to display
              articleList: articleList, // Full list for swipe navigation
              currentIndex: index, // Position in list
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Space between cards
        padding: const EdgeInsets.all(12), // Internal padding
        decoration: BoxDecoration(
          // Card background: dark gray in dark mode, white in light mode
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to top
          children: [
            // Left side: text content (source, title, author/time)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display source name in red if available
                  if (article.source != null)
                    Text(
                      article.source!,
                      style: const TextStyle(
                        color: Color(0xFFE53935), // App's red accent color
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Article title (main headline)
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3, // Line height for readability
                    ),
                    maxLines: 3, // Limit to 3 lines
                    overflow:
                        TextOverflow.ellipsis, // Add ... if text is too long
                  ),
                  const SizedBox(height: 6),
                  // Display author and publish time if available
                  if (article.author != null || article.publishedAt != null)
                    Text(
                      '${article.author ?? 'Unknown'} • ${_formatTime(article.publishedAt ?? '')}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : Colors.black54, // Muted color
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12), // Space between text and image
            // Right side: article thumbnail image (if available)
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded corners
                // Use cached network image for better performance
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit
                      .cover, // Fill the square while maintaining aspect ratio
                  // Show gray placeholder while image loads
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                  ),
                  // Show error placeholder if image fails to load
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                    child: Icon(
                      Icons.image_not_supported, // Broken image icon
                      size: 24,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                ),
              )
            // Show placeholder if article has no image
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
                  Icons.article, // Generic article icon
                  size: 32,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build featured card for first article (large image on top)
  /// This is a prominent card layout with full-width image above text content
  /// Used only for the first article to highlight it as the top story
  Widget _buildFeaturedGridCard(
    Article article,
    List<Article> articleList,
    int index,
    bool isDark,
  ) {
    return GestureDetector(
      // Navigate to article detail when tapped
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
        margin: const EdgeInsets.only(bottom: 16), // Space below card
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display article image at top if available
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                // Round only top corners to match card shape
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  height: 200, // Fixed height for featured image
                  width: double.infinity, // Full card width
                  fit: BoxFit.cover, // Fill area while maintaining aspect ratio
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
            // Show placeholder if no image available
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
                    Icons.image_not_supported, // Broken image icon
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ),
            // Text content section below image
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display source name in red if available
                  if (article.source != null)
                    Text(
                      article.source!,
                      style: const TextStyle(
                        color: Color(0xFFE53935), // App's red accent
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Article title (larger font for featured card)
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18, // Larger than horizontal cards
                      fontWeight: FontWeight.bold,
                      height: 1.3, // Line height for readability
                    ),
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis, // Add ... if too long
                  ),
                  const SizedBox(height: 8),
                  // Display author and static time (hardcoded for demo)
                  if (article.author != null || article.publishedAt != null)
                    Text(
                      '${article.author ?? ''} • 1d ago',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : Colors.black54, // Muted color
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

  /// Maps an OpenWeatherMap condition code to a Material icon.
  /// Reference: https://openweathermap.org/weather-conditions
  IconData _weatherIcon(int code) {
    if (code >= 200 && code < 300) return Icons.thunderstorm; // Thunderstorm
    if (code >= 300 && code < 400) return Icons.grain;        // Drizzle
    if (code >= 500 && code < 600) return Icons.water_drop;  // Rain
    if (code >= 600 && code < 700) return Icons.ac_unit;      // Snow
    if (code >= 700 && code < 800) return Icons.foggy;        // Atmosphere (fog, mist, etc.)
    if (code == 800) return Icons.wb_sunny;                    // Clear sky
    if (code > 800) return Icons.cloud;                        // Cloudy
    return Icons.wb_sunny;                                     // Default fallback
  }

  /// Format timestamp to relative time (e.g., "2h ago", "1d ago")

  /// Converts ISO 8601 date strings to human-readable relative time
  String _formatTime(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      // Parse ISO 8601 date string to DateTime object
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      // Recent articles: show minutes (e.g., "45m ago")
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      // Today's articles: show hours (e.g., "3h ago")
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      // This week's articles: show days (e.g., "2d ago")
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      // Older articles: show formatted date (e.g., "Jan 15")
      return DateFormat('MMM d').format(date);
    } catch (e) {
      // Return empty string if date string is invalid or parsing fails
      return '';
    }
  }

  /// Show profile bottom sheet with user info and logout option
  /// Displays user email and provides logout functionality
  void _showProfileSheet(BuildContext context, bool isDark) {
    // Get currently authenticated user from auth provider
    final user = ref.read(authStateProvider).value;

    // Show modal bottom sheet from bottom of screen
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // Transparent to show custom decoration
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20)), // Rounded top corners
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Only take needed space
          children: [
            // Drag handle indicator at top of sheet
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2), // Rounded pill shape
              ),
            ),
            // Profile icon in circular container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935)
                    .withValues(alpha: 0.1), // Light red background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFFE53935), // Red icon
              ),
            ),
            const SizedBox(height: 16),
            // Display user's email address
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Divider line
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),
            // Logout button
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color(0xFFE53935), // Red logout icon
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                // Close the bottom sheet before showing dialog
                Navigator.pop(context);
                // Show confirmation dialog to prevent accidental logout
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
                      // Cancel button - dismisses dialog without logging out
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                      // Confirm logout button - proceeds with logout
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style:
                              TextStyle(color: Color(0xFFE53935)), // Red text
                        ),
                      ),
                    ],
                  ),
                );
                // Only logout if user confirmed in dialog
                if (shouldLogout == true) {
                  // Get auth service and call logout method
                  final authService = ref.read(authServiceProvider);
                  await authService
                      .logout(); // This will navigate back to login screen
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
