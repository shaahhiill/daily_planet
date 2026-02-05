import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';

/// Search screen - allows users to search for news articles by keyword
/// Uses NewsAPI search endpoint to find articles matching the query
/// Shows results in a scrollable list
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // Current search query (null means no search performed yet)
  String? _currentQuery;

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    _searchController.dispose();
    super.dispose();
  }

  /// Perform search when user submits query
  /// Updates _currentQuery which triggers provider to fetch results
  void _performSearch() {
    // Get the trimmed search text
    final query = _searchController.text.trim();

    // Only search if query is not empty
    if (query.isNotEmpty) {
      setState(() {
        _currentQuery = query; // This triggers the provider to fetch news
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Background color based on theme
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top section with title and search bar
            _buildHeader(isDark),

            // Search results area - changes based on search state
            Expanded(
              child: _currentQuery == null
                  // INITIAL STATE: No search performed yet
                  ? _buildInitialState(isDark)
                  // SEARCH RESULTS: Show loading/error/results
                  : _buildSearchResults(isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the header with title and search input field
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Search" title in red
          Text(
            'Search',
            style: TextStyle(
              color: const Color(0xFFE53935),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Search input field
          TextField(
            controller: _searchController,
            // Trigger search when user presses enter/search button
            onSubmitted: (_) => _performSearch(),
            style: TextStyle(
              // Text color based on theme
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              // Hint text shown when field is empty
              hintText: 'Search for news...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              // Search icon on the left
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              // Search button on the right
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  color: const Color(0xFFE53935),
                ),
                onPressed: _performSearch, // Trigger search on tap
              ),
              // Field styling
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none, // No border in default state
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                // Red border when focused
                borderSide: const BorderSide(
                  color: Color(0xFFE53935),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the initial state before any search is performed
  /// Shows helpful icon and text to guide user
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildInitialState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large search icon
          Icon(
            Icons.search,
            size: 80,
            // Dimmed icon color based on theme
            color: isDark ? Colors.white24 : Colors.black26,
          ),

          const SizedBox(height: 16),

          // Main message
          Text(
            'Search for news',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Helper text explaining how to search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Enter keywords to find articles from NewsAPI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the search results section
  /// Watches the search provider and shows loading/error/results
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildSearchResults(bool isDark) {
    // Watch the search news provider with current query
    // This automatically handles loading, error, and data states
    final searchAsync = ref.watch(searchNewsProvider(_currentQuery!));

    return searchAsync.when(
      // LOADING STATE: Show circular progress indicator
      loading: () => const Center(
        child: CircularProgressIndicator(
          // Red spinner matching app theme
          color: Color(0xFFE53935),
        ),
      ),

      // ERROR STATE: Show error icon and message
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large error icon
            Icon(
              Icons.error_outline,
              size: 64,
              // Dimmed icon color based on theme
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            // Error message
            Text(
              'Failed to search news',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),

      // SUCCESS STATE: Show search results
      data: (articles) {
        // If no results found, show empty state
        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Empty search icon
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 16),
                // "No results" message
                Text(
                  'No results found',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Helper text
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Show list of search results
        return ListView.builder(
          // Padding around the entire list
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // Number of articles to show
          itemCount: articles.length,
          itemBuilder: (context, index) {
            // Get current article from results
            final article = articles[index];

            // Return a news card for each article
            return NewsCard(
              article: article,
              onTap: () {
                // Navigate to article detail when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(
                      article: article,
                      articleList: articles,
                      currentIndex: index,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
