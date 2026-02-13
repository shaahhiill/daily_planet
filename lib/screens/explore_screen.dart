import 'package:flutter/material.dart';
import 'category_screen.dart';

/// Explore screen - grid of news categories
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explore',
                style: TextStyle(
                  color: const Color(0xFFE53935),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
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

  Widget _buildCategoryCard(
    BuildContext context, {
    required String name,
    required IconData icon,
    required String categoryId,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(
              category: categoryId,
              categoryName: name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: const Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 12),
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
