import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import 'auth_provider.dart';

// Firestore path: users/{uid}/savedArticles/{articleUrl}
// Each saved article is stored as its own document, keyed by URL.

/// Provides the saved articles list, scoped to the logged-in user.
/// It watches the authStateProvider and provides an AsyncValue state.
final savedArticlesProvider =
    StateNotifierProvider<SavedArticlesNotifier, AsyncValue<List<Article>>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) => SavedArticlesNotifier(user?.uid),
    loading: () => SavedArticlesNotifier(null, isLoading: true),
    error: (err, stack) => SavedArticlesNotifier(null),
  );
});

/// Manages saved articles with explicit loading and error states.
class SavedArticlesNotifier extends StateNotifier<AsyncValue<List<Article>>> {
  final String? uid;

  SavedArticlesNotifier(this.uid, {bool isLoading = false})
      : super(isLoading ? const AsyncLoading() : const AsyncData([])) {
    if (uid != null) {
      _loadSavedArticles();
    }
  }

  // Reference to the current user's savedArticles collection in Firestore.
  // Throws if accessed while not logged in.
  CollectionReference get _collection {
    if (uid == null) {
      throw Exception('Attempted to access Firestore without a valid user ID');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid!)
        .collection('savedArticles');
  }

  /// Loads all saved articles from Firestore on startup.
  Future<void> _loadSavedArticles() async {
    if (uid == null) return;
    
    // Set loading state if not already loading
    if (state is! AsyncLoading) {
      state = const AsyncLoading();
    }

    try {
      print('Fetching saved articles from Firestore for user: $uid');
      final snapshot = await _collection.get();
      final loadedArticles = snapshot.docs
          .map((doc) => Article.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      print('Successfully loaded ${loadedArticles.length} articles from Firestore');
      state = AsyncData(loadedArticles);
    } catch (e, stack) {
      print('Error loading saved articles from Firestore: $e');
      state = AsyncError(e, stack);
    }
  }

  /// Saves an article to Firestore.
  Future<void> addArticle(Article article) async {
    if (uid == null) return;
    
    final currentList = state.value ?? [];
    if (currentList.any((a) => a.url == article.url)) return;
    
    final docId = Uri.encodeComponent(article.url ?? article.title ?? 'unknown');
    
    try {
      await _collection.doc(docId).set(article.toJson());
      state = AsyncData([...currentList, article]);
      print('Article saved successfully: ${article.title}');
    } catch (e) {
      print('Error saving article: $e');
    }
  }

  /// Removes an article from Firestore.
  Future<void> removeArticle(Article article) async {
    if (uid == null) return;
    
    final currentList = state.value ?? [];
    final docId = Uri.encodeComponent(article.url ?? article.title ?? 'unknown');
    
    try {
      await _collection.doc(docId).delete();
      state = AsyncData(currentList.where((a) => a.url != article.url).toList());
      print('Article removed successfully');
    } catch (e) {
      print('Error removing article: $e');
    }
  }

  /// Returns true if the article is already bookmarked.
  bool isSaved(Article article) {
    return state.value?.any((a) => a.url == article.url) ?? false;
  }
}
