import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'category_screen.dart';

/// Explore screen - grid of news categories
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check current theme mode for styling
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of available news categories
    // Each category has:
    // - name: Display name shown to user
    // - icon: Material icon representing the category
    // - category: API parameter for filtering news
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
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Screen title in brand red color
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explore',
                style: TextStyle(
                  color: const Color(0xFFE53935), // Daily Planet red
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Subtitle explaining the screen purpose
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Browse news by category',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Grid of category cards
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                // Grid configuration: 2 columns with spacing
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two cards per row
                  crossAxisSpacing: 16, // Horizontal gap between cards
                  mainAxisSpacing: 16, // Vertical gap between cards
                  childAspectRatio: 1.4, // Width:height ratio for cards
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  // Build individual category card with extracted data
                  return _buildCategoryCard(
                    context,
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

  // Build a category card with icon and name
  Widget _buildCategoryCard(
    BuildContext context, {
    required String name,
    required IconData icon,
    required String categoryId,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(
              category: categoryId, // API filter parameter
              categoryName: name, // Display name for screen title
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          // Card background based on theme
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Add subtle shadow in light mode only
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular icon container with light red background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935)
                    .withValues(alpha: 0.1), // Light red tint
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: const Color(0xFFE53935), // Brand red icon
              ),
            ),
            const SizedBox(height: 12),
            // Category name below icon
            Text(
              name,
              style: TextStyle(
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
