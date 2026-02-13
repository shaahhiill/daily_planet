import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

/// Service for fetching news articles from NewsAPI
class NewsService {
  final String _apikey = dotenv.env['NEWS_API_KEY'] ?? ''; // NewsAPI key
  final String _baseUrl = 'https://newsapi.org/v2'; // NewsAPI base URL

  /// Fetch top headlines, optionally filtered by category
  /// Falls back to offline data if API call fails
  Future<List<Article>> getTopHeadlines({String? category}) async {
    try {
      // Build URL with optional category filter
      final url = category != null
          ? '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apikey'
          : '$_baseUrl/top-headlines?country=us&apiKey=$_apikey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Convert JSON array to Article objects
        final articles = (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        return articles;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      // If API fails (no internet, rate limit, etc.), use offline data
      return await _getOfflineNews();
    }
  }

  /// Search for news articles by keyword
  /// Falls back to offline data if API call fails
  Future<List<Article>> searchNews(String query) async {
    try {
      final url =
          '$_baseUrl/everything?q=$query&apiKey=$_apikey&sortBy=publishedAt';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Convert JSON array to Article objects
        final articles = (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        return articles;
      } else {
        throw Exception('Failed to search news');
      }
    } catch (e) {
      // If search fails, return offline news as fallback
      return await _getOfflineNews();
    }
  }

  /// Load offline news from local JSON file (used when API is unavailable)
  Future<List<Article>> _getOfflineNews() async {
    final jsonString =
        await rootBundle.loadString('assets/json/offline_news.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Article.fromJson(json)).toList();
  }
}
