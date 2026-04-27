import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/saved_provider.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

/// Saved screen - displays bookmarked articles
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch the saved articles provider
    final savedArticlesAsync = ref.watch(savedArticlesProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: savedArticlesAsync.when(
          data: (articles) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(articles.length, isDark),
              Expanded(
                child: articles.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildArticlesList(context, articles, isDark),
              ),
            ],
          ),
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(0, isDark),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFE53935)),
                ),
              ),
            ],
          ),
          error: (error, stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(0, isDark),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Error loading articles: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFE53935)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the header section with title and article count
  Widget _buildHeader(int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count items',
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your curated reading list',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the enhanced empty state UI with 3D illustration
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'Your list is empty',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Save interesting news stories to read them later, even when offline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the interactive list with Swipe-to-Delete
  Widget _buildArticlesList(BuildContext context, List<Article> articles, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Consumer(
            builder: (context, ref, child) {
              return Dismissible(
                key: Key(article.url ?? article.title ?? index.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  ref.read(savedArticlesProvider.notifier).removeArticle(article);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Article removed from saved'),
                      backgroundColor: const Color(0xFFE53935),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () {
                          ref.read(savedArticlesProvider.notifier).addArticle(article);
                        },
                      ),
                    ),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                child: _buildHorizontalCard(context, article, articles, index, isDark),
              );
            },
          ),
        );
      },
    );
  }

  /// Premium Article Card with glassmorphic feel
  Widget _buildHorizontalCard(BuildContext context, Article article,
      List<Article> articles, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.source != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.source!.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    article.title ?? 'No title',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${article.author ?? 'Daily Planet'} • ${_formatTime(article.publishedAt ?? '')}',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // High-quality Image
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              Hero(
                tag: 'saved_${article.url}',
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                        child: const Icon(Icons.broken_image_outlined, size: 24, color: Colors.white24),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 32,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateString) {
    if (dateString.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return 'Recent';
    }
  }
}

