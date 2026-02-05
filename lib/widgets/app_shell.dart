import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/search_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SavedScreen(),
    SearchScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: orientation == Orientation.landscape
          ? _buildLandscapeLayout(context, isDark)
          : _buildPortraitLayout(context, isDark),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: _screens,
          ),
        ),
        _buildBottomNav(context, isDark),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        _buildSideNav(context, isDark),
        Expanded(
          child: _screens[_currentIndex],
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(Icons.home_outlined, Icons.home, 0, isDark),
          _buildNavIcon(Icons.explore_outlined, Icons.explore, 1, isDark),
          _buildNavIcon(Icons.bookmark_outline, Icons.bookmark, 2, isDark),
          _buildNavIcon(Icons.search, Icons.search, 3, isDark),
        ],
      ),
    );
  }

  Widget _buildNavIcon(
      IconData unselected, IconData selected, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Icon(
          isSelected ? selected : unselected,
          color: isSelected
              ? const Color(0xFFE53935)
              : isDark
                  ? Colors.white54
                  : Colors.black54,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSideNav(BuildContext context, bool isDark) {
    final labels = ['Home', 'Explore', 'Saved', 'Search'];
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          ...List.generate(4, (index) {
            final isSelected = _currentIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05))
                      : Colors.transparent,
                  border: Border(
                    left: BorderSide(
                      color: isSelected
                          ? const Color(0xFFE53935)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFE53935)
                        : isDark
                            ? Colors.white70
                            : Colors.black.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // Theme toggle button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                // Toggle theme when tapped
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              child: Consumer(
                builder: (context, ref, _) {
                  // Watch current theme mode
                  final themeMode = ref.watch(themeModeProvider);
                  final isLightMode = themeMode == ThemeMode.light;

                  return Row(
                    children: [
                      Icon(
                        // Show sun icon in dark mode, moon in light mode
                        isLightMode ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.white54 : Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        // Label changes based on current mode
                        isLightMode ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () async {
                final authService = ref.read(authServiceProvider);
                await authService.logout();
              },
              child: Row(
                children: [
                  Icon(Icons.logout,
                      color: isDark ? Colors.white54 : Colors.black54,
                      size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog with theme toggle option
  /// Allows user to switch between light and dark mode in portrait
  void _showThemeDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Consumer(
          builder: (context, ref, _) {
            // Watch current theme mode
            final themeMode = ref.watch(themeModeProvider);
            final isLightMode = themeMode == ThemeMode.light;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Theme toggle row
                InkWell(
                  onTap: () {
                    // Toggle theme
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          // Show sun/moon icon based on current mode
                          isLightMode ? Icons.dark_mode : Icons.light_mode,
                          color: const Color(0xFFE53935),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Theme',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Show current theme mode
                        Text(
                          isLightMode ? 'Light' : 'Dark',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
  }
}
