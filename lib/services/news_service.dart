import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/article.dart';

/// Fetches news directly from NewsAPI.
/// When Cloud Functions are deployed in the future, this will switch to
/// reading from the Firestore cache instead.
class NewsService {
  final String _baseUrl = 'https://daily-planet-bice.vercel.app/api';

  /// Fetch top headlines, optionally filtered by category.
  /// Falls back to offline data if the API call fails.
  Future<List<Article>> getTopHeadlines({String? category}) async {
    try {
      final url = category != null
          ? '$_baseUrl/news?category=$category'
          : '$_baseUrl/news';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('NewsService Error (Headlines): $e');
      return await _getOfflineNews();
    }
  }

  /// Search for news articles by keyword.
  /// Falls back to offline data if the API call fails.
  Future<List<Article>> searchNews(String query) async {
    try {
      final url = '$_baseUrl/news?q=$query';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('NewsService Error (Search): $e');
      return await _getOfflineNews();
    }
  }

  /// Fallback: loads bundled offline news when the API is unavailable.
  Future<List<Article>> _getOfflineNews() async {
    final jsonString =
        await rootBundle.loadString('assets/json/offline_news.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Article.fromJson(json)).toList();
  }
}
