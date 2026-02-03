import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../services/news_service.dart';

final newsServiceProvider = Provider((ref) => NewsService());

final topHeadlinesProvider =
    FutureProvider.family<List<Article>, String?>((ref, category) async {
  final newsService = ref.watch(newsServiceProvider);
  return await newsService.getTopHeadlines(category: category);
});

final searchNewsProvider =
    FutureProvider.family<List<Article>, String>((ref, query) async {
  final newsService = ref.watch(newsServiceProvider);
  return await newsService.searchNews(query);
});
