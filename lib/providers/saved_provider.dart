import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

// Firestore path: users/{uid}/savedArticles/{articleUrl}
// Each saved article is stored as its own document, keyed by URL.

/// Provides the saved articles list, scoped to the logged-in user.
final savedArticlesProvider =
    StateNotifierProvider<SavedArticlesNotifier, List<Article>>((ref) {
  return SavedArticlesNotifier();
});

/// Manages saved/bookmarked articles using Firestore as the backend.
/// Articles are tied to the user's Firebase account — accessible on any device.
class SavedArticlesNotifier extends StateNotifier<List<Article>> {
  SavedArticlesNotifier() : super([]) {
    _loadSavedArticles();
  }

  // Reference to the current user's savedArticles collection in Firestore.
  CollectionReference get _collection {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savedArticles');
  }

  /// Loads all saved articles from Firestore on startup.
  Future<void> _loadSavedArticles() async {
    final snapshot = await _collection.get();
    state = snapshot.docs
        .map((doc) => Article.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Saves an article to Firestore. Uses the URL as the document ID
  /// so duplicates are impossible (Firestore will just overwrite).
  Future<void> addArticle(Article article) async {
    if (state.any((a) => a.url == article.url)) return; // Already saved.
    final docId = Uri.encodeComponent(article.url ?? article.title ?? '');
    await _collection.doc(docId).set(article.toJson());
    state = [...state, article];
  }

  /// Removes an article from Firestore and updates the local state.
  Future<void> removeArticle(Article article) async {
    final docId = Uri.encodeComponent(article.url ?? article.title ?? '');
    await _collection.doc(docId).delete();
    state = state.where((a) => a.url != article.url).toList();
  }

  /// Returns true if the article is already bookmarked.
  bool isSaved(Article article) {
    return state.any((a) => a.url == article.url);
  }
}
