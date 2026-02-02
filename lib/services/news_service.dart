import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> getTopHeadlines({String? category}) async {
    try {
      final url = category != null
          ? '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apiKey'
          : '$_baseUrl/top-headlines?country=us&apiKey=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        return articles;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      // Fallback to offline data
      return await _getOfflineNews();
    }
  }

  Future<List<Article>> searchNews(String query) async {
    try {
      final url = '$_baseUrl/everything?q=$query&apiKey=$_apiKey&sortBy=publishedAt';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        return articles;
      } else {
        throw Exception('Failed to search news');
      }
    } catch (e) {
      return await _getOfflineNews();
    }
  }

  Future<List<Article>> _getOfflineNews() async {
    final jsonString = await rootBundle.loadString('assets/json/offline_news.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Article.fromJson(json)).toList();
  }
}
