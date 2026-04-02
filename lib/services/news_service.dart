import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

/// Fetches news from our own Node.js backend.
/// The backend handles the NewsAPI calls and keeps the API key server-side.
class NewsService {
  // Point to your backend server. Change this to your deployed URL in production.
  static const String _backendUrl = 'http://10.0.2.2:3000/api/news';
  // Note: 10.0.2.2 is how Android emulators reach localhost on the host machine.
  // For a real device on the same Wi-Fi, use your computer's local IP, e.g. http://192.168.1.x:3000/api/news

  /// Fetch top headlines, optionally filtered by category.
  /// Falls back to offline data if the backend is unreachable.
  Future<List<Article>> getTopHeadlines({String? category}) async {
    try {
      // Build the URL with an optional category filter.
      final url = category != null
          ? '$_backendUrl/headlines?category=$category'
          : '$_backendUrl/headlines';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }
    } catch (e) {
      // If the backend is down or unreachable, fall back to offline data.
      return await _getOfflineNews();
    }
  }

  /// Search for news articles by keyword.
  /// Falls back to offline data if the backend is unreachable.
  Future<List<Article>> searchNews(String query) async {
    try {
      final url = '$_backendUrl/search?q=${Uri.encodeComponent(query)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
      } else {
        throw Exception('Backend search failed: ${response.statusCode}');
      }
    } catch (e) {
      return await _getOfflineNews();
    }
  }

  /// Load offline news from local JSON file (fallback when backend is unavailable).
  Future<List<Article>> _getOfflineNews() async {
    final jsonString =
        await rootBundle.loadString('assets/json/offline_news.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Article.fromJson(json)).toList();
  }
}
