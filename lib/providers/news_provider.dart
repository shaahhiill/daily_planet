import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../services/news_service.dart';

final newsServiceProvider = Provider((ref) => NewsService());

final topHeadlinesProvider = FutureProvider<List<Article>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  return service.getTopHeadlines();
});
