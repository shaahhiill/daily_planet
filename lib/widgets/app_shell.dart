import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback on tab taps
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/search_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

/// Main app shell with bottom/side navigation
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0; // Track active screen
  final PageController _pageController =
      PageController(); // For swipe navigation

  // All app screens
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark; // Check theme

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: orientation == Orientation.landscape
          ? _buildLandscapeLayout(context, isDark) // Side nav for landscape
          : _buildPortraitLayout(context, isDark), // Bottom nav for portrait
    );
  }

  Widget _buildPortraitLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) =>
                setState(() => _currentIndex = index), // Update on swipe
            children: _screens,
          ),
        ),
        _buildBottomNav(context, isDark),
      ],
    );
  }

  // Landscape layout with side navigation
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

  // Bottom navigation bar for portrait mode
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
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Evenly space icons
        children: [
          // Home icon (index 0)
          _buildNavIcon(Icons.home_outlined, Icons.home, 0, isDark),
          // Explore icon (index 1)
          _buildNavIcon(Icons.explore_outlined, Icons.explore, 1, isDark),
          // Saved/Bookmarks icon (index 2)
          _buildNavIcon(Icons.bookmark_outline, Icons.bookmark, 2, isDark),
          // Search icon (index 3)
          _buildNavIcon(Icons.search, Icons.search, 3, isDark),
        ],
      ),
    );
  }

  // Individual navigation icon button with haptic feedback on tap
  Widget _buildNavIcon(
      IconData unselected, IconData selected, int index, bool isDark) {
    final isSelected = _currentIndex == index; // Check if this icon is active
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick(); // Tactile feedback on every tab tap
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index, // Animate to selected page
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Icon(
          isSelected ? selected : unselected, // Filled icon when selected
          color: isSelected
              ? const Color(0xFFE53935) // Red when selected
              : isDark
                  ? Colors.white54 // Gray in dark mode
                  : Colors.black54, // Gray in light mode
          size: 24,
        ),
      ),
    );
  }

  // Side navigation for landscape mode
  Widget _buildSideNav(BuildContext context, bool isDark) {
    final labels = ['Home', 'Explore', 'Saved', 'Search']; // Nav item labels
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
          const SizedBox(height: 60), // Top spacing
          // Generate 4 navigation items
          ...List.generate(4, (index) {
            final isSelected = _currentIndex == index; // Check if active
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick(); // Haptic for landscape nav too
                setState(() => _currentIndex = index); // Switch screen
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  // Highlight background when selected
                  color: isSelected
                      ? (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05))
                      : Colors.transparent,
                  border: Border(
                    left: BorderSide(
                      // Red left border when selected
                      color: isSelected
                          ? const Color(0xFFE53935)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  labels[index], // Display label text
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
          const Spacer(), // Push theme toggle and logout to bottom
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
          // Logout button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () async {
                final authService = ref.read(authServiceProvider);
                await authService.logout(); // Sign out user
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
}
