import 'package:flutter/material.dart';
import '../models/article.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(article.title ?? ''),
        subtitle: Text(article.source ?? ''),
      ),
    );
  }
}
