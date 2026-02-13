import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/saved_provider.dart';
import '../providers/news_provider.dart';

/// Article detail screen with swipe navigation
class ArticleDetailScreen extends ConsumerStatefulWidget {
  // The current article to display
  final Article article;

  // List of all articles (for swipe navigation)
  final List<Article>? articleList;

  // Index of current article in the list
  final int? currentIndex;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    this.articleList,
    this.currentIndex,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  // Track the current article being displayed
  late Article currentArticle;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed article
    currentArticle = widget.article;
    currentIndex = widget.currentIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if this article is currently saved
    final savedNotifier = ref.watch(savedArticlesProvider.notifier);
    final isSaved = savedNotifier.isSaved(currentArticle);

    return GestureDetector(
      // Detect horizontal swipe gestures
      onHorizontalDragEnd: (details) {
        // Check if we have an article list for navigation
        if (widget.articleList == null || widget.articleList!.isEmpty) {
          return;
        }

        // Swipe right (positive velocity) = go to previous article
        if (details.primaryVelocity! > 0) {
          _navigateToPrevious();
        }
        // Swipe left (negative velocity) = go to next article
        else if (details.primaryVelocity! < 0) {
          _navigateToNext();
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
        body: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                _buildAppBar(context, ref, isDark, isSaved, savedNotifier),
                SliverToBoxAdapter(
                  child: _buildContent(isDark),
                ),
              ],
            ),

            // Navigation indicators (show current position in article list)
            if (widget.articleList != null && widget.articleList!.length > 1)
              _buildNavigationIndicators(isDark),
          ],
        ),
      ),
    );
  }

  /// Navigate to previous article in the list
  /// Triggered by swiping right
  void _navigateToPrevious() {
    if (widget.articleList == null || currentIndex <= 0) {
      // Already at first article, show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already at the first article'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    // Update to previous article
    setState(() {
      currentIndex--;
      currentArticle = widget.articleList![currentIndex];
    });
  }

  /// Navigate to next article in the list
  /// Triggered by swiping left
  void _navigateToNext() {
    if (widget.articleList == null ||
        currentIndex >= widget.articleList!.length - 1) {
      // Already at last article, show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already at the last article'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    // Update to next article
    setState(() {
      currentIndex++;
      currentArticle = widget.articleList![currentIndex];
    });
  }

  /// Build navigation indicators showing current position
  /// Shows dots at bottom indicating which article user is viewing
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildNavigationIndicators(bool isDark) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left arrow hint
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: currentIndex > 0
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
            // Position text (e.g., "3 / 10")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${currentIndex + 1} / ${widget.articleList!.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Right arrow hint
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: currentIndex < widget.articleList!.length - 1
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the app bar with back and save buttons
  /// Parameters:
  /// - context: BuildContext for navigation
  /// - ref: WidgetRef to access providers
  /// - isDark: Whether dark mode is active
  /// - isSaved: Whether this article is currently saved
  /// - savedNotifier: Provider notifier to save/unsave articles
  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    bool isSaved,
    SavedArticlesNotifier savedNotifier,
  ) {
    return SliverAppBar(
      // Make app bar float over content when scrolling
      floating: true,
      // Pin it at the top
      pinned: true,
      // Expand to show image behind it
      expandedHeight: 300,
      // Background color based on theme
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      // Leading back button
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          // Circular background for better visibility over image
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      // Actions (save button)
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // Circular background for better visibility over image
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              // Show filled or outlined bookmark based on save status
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_outline,
                color: isSaved ? const Color(0xFFE53935) : Colors.white,
              ),
              onPressed: () {
                // Toggle save state when tapped
                if (isSaved) {
                  // Remove from saved articles
                  savedNotifier.removeArticle(currentArticle);
                  // Show feedback to user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Article removed from saved'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFFE53935),
                    ),
                  );
                } else {
                  // Add to saved articles
                  savedNotifier.addArticle(currentArticle);
                  // Show feedback to user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Article saved'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFFE53935),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
      // Expanded area showing article image
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderImage(isDark),
      ),
    );
  }

  /// Build the header image for the article
  /// Shows cached network image with fallback for missing images
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildHeaderImage(bool isDark) {
    // Check if article has an image
    if (currentArticle.urlToImage == null ||
        currentArticle.urlToImage!.isEmpty) {
      // Fallback placeholder when no image available
      return Container(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      );
    }

    // Load image from network with caching
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: currentArticle.urlToImage!,
          fit: BoxFit.cover,
          // Show spinner while loading
          placeholder: (context, url) => Container(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            ),
          ),
          // Show error icon if image fails to load
          errorWidget: (context, url, error) => Container(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
            child: Center(
              child: Icon(
                Icons.error_outline,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ),
        ),
        // Gradient overlay for better text visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build the main content area with article details
  /// Shows source, title, author, time, and description
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source label (e.g., "BBC News", "CNN")
          if (currentArticle.source != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentArticle.source!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Article title - large and bold
          Text(
            currentArticle.title ?? 'No title',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // Author and time info
          Row(
            children: [
              // Author name
              if (currentArticle.author != null) ...[
                Expanded(
                  child: Text(
                    currentArticle.author!,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' • ',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
              // Published time
              if (currentArticle.publishedAt != null)
                Text(
                  _formatDate(currentArticle.publishedAt!),
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Divider line
          Container(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),

          const SizedBox(height: 24),

          // Article description/content
          if (currentArticle.description != null)
            Text(
              currentArticle.description!,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.85)
                    : Colors.black.withOpacity(0.85),
                fontSize: 16,
                height: 1.6,
              ),
            ),

          const SizedBox(height: 24),

          // Social media share buttons section
          _buildShareSection(isDark),

          const SizedBox(height: 24),

          // Note about full article
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.white54 : Colors.black54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is a preview. Full article available on the original source.',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // "You may also like" section with related articles
          _buildRelatedArticles(isDark),
        ],
      ),
    );
  }

  /// Build social media share buttons
  /// Shows Instagram, WhatsApp, Facebook, Twitter icons
  /// Taps open respective apps with pre-filled share text
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildShareSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Share Article" heading
        Text(
          'Share Article',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Row of social media icons
        Row(
          children: [
            // WhatsApp share button
            _buildShareButton(
              imagePath: 'assets/images/social/whatsapp.png',
              color: Colors.black,
              onTap: () => _shareToWhatsApp(),
              isDark: isDark,
            ),

            const SizedBox(width: 12),

            // Instagram share button
            _buildShareButton(
              imagePath: 'assets/images/social/instagram.png',
              color: Colors.black,
              onTap: () => _shareToInstagram(),
              isDark: isDark,
            ),

            const SizedBox(width: 12),

            // Twitter share button
            _buildShareButton(
              imagePath: 'assets/images/social/twitter.png',
              color: Colors.black,
              onTap: () => _shareToTwitter(),
              isDark: isDark,
            ),

            const SizedBox(width: 12),

            // LinkedIn share button
            _buildShareButton(
              imagePath: 'assets/images/social/linkedin.png',
              color: Colors.black,
              onTap: () => _shareToLinkedIn(),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual social media share button
  /// Parameters:
  /// - imagePath: Path to the social media logo image
  /// - color: Brand color for the button
  /// - onTap: Callback when button is tapped
  /// - isDark: Whether dark mode is active
  Widget _buildShareButton({
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Share article to WhatsApp
  /// Opens WhatsApp with pre-filled message containing article title and URL
  void _shareToWhatsApp() async {
    final text = '${currentArticle.title}\n\n${currentArticle.url ?? ''}';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Share article to LinkedIn
  /// Opens LinkedIn with pre-filled post containing article URL
  void _shareToLinkedIn() async {
    if (currentArticle.url == null) return;

    final url = Uri.parse(
        'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(currentArticle.url!)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Share article to Twitter/X
  /// Opens Twitter with pre-filled tweet containing article title and URL
  void _shareToTwitter() async {
    final text = currentArticle.title ?? '';
    final url = Uri.parse(
        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(currentArticle.url ?? '')}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Share article to Instagram
  /// Note: Instagram doesn't support direct URL sharing via deep links
  /// This opens Instagram app, user must manually paste content
  void _shareToInstagram() async {
    // Instagram doesn't have a direct share URL scheme for articles
    // Open Instagram app directly
    final url = Uri.parse('instagram://');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // If Instagram app not installed, open web version
      final webUrl = Uri.parse('https://www.instagram.com/');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// Build "You may also like" section with related articles
  /// Shows 5 articles from the same category
  /// Parameters:
  /// - isDark: Whether dark mode is active
  Widget _buildRelatedArticles(bool isDark) {
    // Get category from current article, default to general if none
    final category = currentArticle.category;

    // Fetch articles from same category
    final relatedNewsAsync = ref.watch(topHeadlinesProvider(category));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section divider
        Container(
          height: 1,
          color: isDark ? Colors.white12 : Colors.black12,
        ),

        const SizedBox(height: 24),

        // "You May Also Like" heading
        Text(
          'You May Also Like',
          style: TextStyle(
            color: const Color(0xFFE53935), // Red heading like other sections
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Related articles list
        relatedNewsAsync.when(
          // LOADING STATE: Show spinner
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            ),
          ),

          // ERROR STATE: Show error message
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Failed to load related articles',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // SUCCESS STATE: Show related articles
          data: (articles) {
            // Filter out the current article and take first 5
            final relatedArticles = articles
                .where((a) =>
                    a.title !=
                    currentArticle.title) // Don't show current article
                .take(5) // Limit to 5 articles
                .toList();

            // If no related articles found
            if (relatedArticles.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No related articles found',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            // Build list of related article cards
            return Column(
              children: relatedArticles.map((article) {
                return _buildRelatedArticleCard(article, isDark);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Build a single related article card
  /// Smaller, compact version for "You may also like" section
  /// Parameters:
  /// - article: The article to display
  /// - isDark: Whether dark mode is active
  Widget _buildRelatedArticleCard(Article article, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Navigate to the related article's detail screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(
              article: article,
              articleList: widget.articleList,
              currentIndex: widget.articleList?.indexOf(article) ?? 0,
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
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article title and source (NOW ON LEFT)
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

                  const SizedBox(height: 4),

                  // Article title
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Author and time
                  if (article.author != null || article.publishedAt != null)
                    Text(
                      '${article.author ?? 'Unknown'} • ${_formatTime(article.publishedAt ?? '')}',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Article thumbnail (NOW ON RIGHT)
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
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
              // Placeholder when no image (also on right now)
              Container(
                width: 80,
                height: 80,
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

  /// Format timestamp to relative time
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

  /// Format the published date to readable format
  /// Example: "February 4, 2026"
  /// Parameters:
  /// - dateString: ISO date string from API
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM d, y').format(date);
    } catch (e) {
      return '';
    }
  }
}
