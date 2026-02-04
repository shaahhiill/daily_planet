import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';
import '../providers/device_provider.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

          // Device capabilities widgets (battery, location, connectivity)
          // Battery status widget
          _buildBatteryWidget(ref, isDark),

          const SizedBox(width: 8),

          // Location widget
          _buildLocationWidget(ref, isDark),

          const SizedBox(width: 8),

          // Connectivity status widget
          _buildConnectivityWidget(ref, isDark),
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

  /// Build battery status widget
  /// Shows battery icon, percentage, and charging state
  /// Parameters:
  /// - ref: WidgetRef to access providers
  /// - isDark: Whether dark mode is active
  Widget _buildBatteryWidget(WidgetRef ref, bool isDark) {
    // Watch battery level and state providers
    final batteryLevelAsync = ref.watch(batteryLevelProvider);
    final batteryStateAsync = ref.watch(batteryStateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Battery icon (changes based on charging state)
          batteryStateAsync.when(
            data: (state) => Icon(
              // Show charging icon if charging, otherwise battery icon
              state == BatteryState.charging
                  ? Icons.battery_charging_full
                  : Icons.battery_std,
              color: const Color(0xFFE53935),
              size: 18,
            ),
            loading: () => const Icon(Icons.battery_unknown, size: 18),
            error: (_, __) => const Icon(Icons.battery_alert, size: 18),
          ),
          const SizedBox(width: 6),
          // Battery percentage text
          batteryLevelAsync.when(
            data: (level) => Text(
              '$level%',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => Text(
              '...',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ),
            error: (_, __) => Text(
              'N/A',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build location widget
  /// Shows location icon and lat/long coordinates
  /// Parameters:
  /// - ref: WidgetRef to access providers
  /// - isDark: Whether dark mode is active
  Widget _buildLocationWidget(WidgetRef ref, bool isDark) {
    // Watch location provider
    final locationAsync = ref.watch(locationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: locationAsync.when(
        data: (position) {
          if (position == null) {
            // Location permission denied or service disabled
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off,
                    color: Color(0xFFE53935), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Off',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                ),
              ],
            );
          }

          // Show latitude and longitude (truncated for display)
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Color(0xFFE53935), size: 18),
              const SizedBox(width: 6),
              Text(
                '${position.latitude.toStringAsFixed(1)},${position.longitude.toStringAsFixed(1)}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
        loading: () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFE53935),
              ),
            ),
          ],
        ),
        error: (_, __) => const Icon(Icons.location_off, size: 18),
      ),
    );
  }

  /// Build connectivity status widget
  /// Shows wifi/mobile icon based on connection type
  /// Parameters:
  /// - ref: WidgetRef to access providers
  /// - isDark: Whether dark mode is active
  Widget _buildConnectivityWidget(WidgetRef ref, bool isDark) {
    // Watch connectivity provider
    final connectivityAsync = ref.watch(connectivityProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: connectivityAsync.when(
        data: (results) {
          // Determine icon and text based on connection type
          IconData icon;
          String label;

          if (results.contains(ConnectivityResult.wifi)) {
            // Connected via WiFi
            icon = Icons.wifi;
            label = 'WiFi';
          } else if (results.contains(ConnectivityResult.mobile)) {
            // Connected via mobile data
            icon = Icons.signal_cellular_alt;
            label = '4G';
          } else if (results.contains(ConnectivityResult.ethernet)) {
            // Connected via ethernet
            icon = Icons.lan;
            label = 'LAN';
          } else {
            // No connection
            icon = Icons.wifi_off;
            label = 'Off';
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFE53935), size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
        loading: () => const Icon(Icons.wifi, size: 18),
        error: (_, __) => const Icon(Icons.wifi_off, size: 18),
      ),
    );
  }
}
