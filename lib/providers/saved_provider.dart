import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

final savedArticlesProvider =
    StateNotifierProvider<SavedArticlesNotifier, List<Article>>((ref) {
  return SavedArticlesNotifier();
});

class SavedArticlesNotifier extends StateNotifier<List<Article>> {
  SavedArticlesNotifier() : super([]) {
    _loadSavedArticles();
  }

  final String _key = 'saved_articles';

  Future<void> _loadSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((json) => Article.fromJson(json)).toList();
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((article) => article.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  Future<void> addArticle(Article article) async {
    if (!state.any((a) => a.title == article.title)) {
      state = [...state, article];
      await _saveToDisk();
    }
  }

  Future<void> removeArticle(Article article) async {
    state = state.where((a) => a.title != article.title).toList();
    await _saveToDisk();
  }

  bool isSaved(Article article) {
    return state.any((a) => a.title == article.title);
  }
}
