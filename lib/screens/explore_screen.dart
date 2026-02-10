import 'package:flutter/material.dart';
import 'category_screen.dart';

/// Explore screen - displays a grid of news categories
/// User can tap any category to see category-specific news
/// Categories: Politics, Technology, Sports, Entertainment, Business, Health, Science
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of all available news categories
    // Each category has: name, icon, and API category string
    final categories = [
      {
        'name': 'Politics',
        'icon': Icons.account_balance,
        'category': 'politics'
      },
      {'name': 'Technology', 'icon': Icons.computer, 'category': 'technology'},
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'category': 'sports'},
      {
        'name': 'Entertainment',
        'icon': Icons.movie,
        'category': 'entertainment'
      },
      {'name': 'Business', 'icon': Icons.business, 'category': 'business'},
      {'name': 'Health', 'icon': Icons.local_hospital, 'category': 'health'},
      {'name': 'Science', 'icon': Icons.science, 'category': 'science'},
    ];

    return Scaffold(
      // Background color changes based on theme
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top padding for spacing
            const SizedBox(height: 20),

            // "Explore" section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explore',
                style: TextStyle(
                  // Red color for section header
                  color: const Color(0xFFE53935),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Subtitle explaining what this screen does
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Browse news by category',
                style: TextStyle(
                  // Dimmed text color based on theme
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category grid - scrollable if categories exceed screen height
            Expanded(
              child: GridView.builder(
                // Padding around the entire grid
                padding: const EdgeInsets.all(16),
                // 2 columns on all screen sizes
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 16, // Horizontal space between cards
                  mainAxisSpacing: 16, // Vertical space between cards
                  childAspectRatio: 1.4, // Width to height ratio of each card
                ),
                // Total number of category cards
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  // Get current category data
                  final category = categories[index];

                  return _buildCategoryCard(
                    context,
                    // Extract name, icon, and category ID from map
                    name: category['name'] as String,
                    icon: category['icon'] as IconData,
                    categoryId: category['category'] as String,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single category card
  /// Parameters:
  /// - name: Display name (e.g., "Politics")
  /// - icon: Icon to show on card
  /// - categoryId: API category string (e.g., "politics")
  /// - isDark: Whether dark mode is active
  Widget _buildCategoryCard(
    BuildContext context, {
    required String name,
    required IconData icon,
    required String categoryId,
    required bool isDark,
  }) {
    return GestureDetector(
      // Navigate to category-specific news screen when tapped
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(
              category: categoryId, // Pass category ID to fetch correct news
              categoryName: name, // Pass display name for screen title
            ),
          ),
        );
      },
      child: Container(
        // Card styling
        decoration: BoxDecoration(
          // Background color based on theme
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          // Rounded corners
          borderRadius: BorderRadius.circular(16),
          // Subtle shadow for depth (only visible in light mode)
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon in a circular background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                // Red circular background for icon
                color: const Color(0xFFE53935).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                // Red icon color
                color: const Color(0xFFE53935),
              ),
            ),

            const SizedBox(height: 12),

            // Category name text
            Text(
              name,
              style: TextStyle(
                // Text color based on theme
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
