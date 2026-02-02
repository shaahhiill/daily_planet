import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

final savedArticlesProvider =
    StateNotifierProvider<SavedArticlesNotifier, List<Article>>((ref) {
  return SavedArticlesNotifier();
});

class SavedArticlesNotifier extends StateNotifier<List<Article>> {
  SavedArticlesNotifier() : super([]);

  void add(Article article) {
    if (!state.any((a) => a.title == article.title)) {
      state = [...state, article];
    }
  }

  void remove(Article article) {
    state = state.where((a) => a.title != article.title).toList();
  }

  bool isSaved(Article article) {
    return state.any((a) => a.title == article.title);
  }
}
