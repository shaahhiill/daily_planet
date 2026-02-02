import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/article.dart';

class NewsService {
  Future<List<Article>> getTopHeadlines() async {
    final jsonString =
        await rootBundle.loadString('assets/json/offline_news.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Article.fromJson(json)).toList();
  }
}
