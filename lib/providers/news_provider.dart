import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../services/news_service.dart';

/// Provides access to NewsService for API calls
final newsServiceProvider = Provider((ref) => NewsService());

/// Fetches top headlines from NewsAPI
/// Parameter: category (nullable) - filters by category if provided
/// Used in: home screen, category screen, explore screen
final topHeadlinesProvider =
    FutureProvider.family<List<Article>, String?>((ref, category) async {
  final newsService = ref.watch(newsServiceProvider);
  return await newsService.getTopHeadlines(category: category);
});

/// Searches news articles based on user query
/// Parameter: query - search term entered by user
/// Used in: search screen
final searchNewsProvider =
    FutureProvider.family<List<Article>, String>((ref, query) async {
  final newsService = ref.watch(newsServiceProvider);
  return await newsService.searchNews(query);
});
