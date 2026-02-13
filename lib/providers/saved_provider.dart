import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

/// Manages saved/bookmarked articles with local persistence
/// Loads from device storage on startup, saves on add/remove
/// Used in: saved screen, article detail screen (bookmark icon)
final savedArticlesProvider =
    StateNotifierProvider<SavedArticlesNotifier, List<Article>>((ref) {
  return SavedArticlesNotifier();
});

/// Handles all operations for managing saved articles
class SavedArticlesNotifier extends StateNotifier<List<Article>> {
  SavedArticlesNotifier() : super([]) {
    _loadSavedArticles();
  }

  final String _key = 'saved_articles';

  /// Loads saved articles from device storage
  Future<void> _loadSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((json) => Article.fromJson(json)).toList();
    }
  }

  /// Saves current list to device storage
  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((article) => article.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  /// Adds article to saved list (prevents duplicates by title)
  Future<void> addArticle(Article article) async {
    if (!state.any((a) => a.title == article.title)) {
      state = [...state, article];
      await _saveToDisk();
    }
  }

  /// Removes article from saved list
  Future<void> removeArticle(Article article) async {
    state = state.where((a) => a.title != article.title).toList();
    await _saveToDisk();
  }

  /// Checks if article is already saved (for bookmark icon state)
  bool isSaved(Article article) {
    return state.any((a) => a.title == article.title);
  }
}
