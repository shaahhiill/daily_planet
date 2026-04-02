import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article.dart';

/// Fetches news directly from NewsAPI.
/// When Cloud Functions are deployed in the future, this will switch to
/// reading from the Firestore cache instead.
class NewsService {
  final String _apikey = dotenv.env['NEWS_API_KEY'] ?? '';
  final String _baseUrl = 'https://newsapi.org/v2';

  /// Fetch top headlines, optionally filtered by category.
  /// Falls back to offline data if the API call fails.
  Future<List<Article>> getTopHeadlines({String? category}) async {
    try {
      final url = category != null
          ? '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apikey'
          : '$_baseUrl/top-headlines?country=us&apiKey=$_apikey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      return await _getOfflineNews();
    }
  }

  /// Search for news articles by keyword.
  /// Falls back to offline data if the API call fails.
  Future<List<Article>> searchNews(String query) async {
    try {
      final url =
          '$_baseUrl/everything?q=$query&apiKey=$_apikey&sortBy=publishedAt';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
      } else {
        throw Exception('Failed to search news');
      }
    } catch (e) {
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
