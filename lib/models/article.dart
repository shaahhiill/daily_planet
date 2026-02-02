class Article {
  final String? source;
  final String? title;
  final String? description;
  final String? author;
  final String? publishedAt;
  final String? urlToImage;
  final String? url;
  final String? category;

  Article({
    this.source,
    this.title,
    this.description,
    this.author,
    this.publishedAt,
    this.urlToImage,
    this.url,
    this.category,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: json['source']?['name'] ?? json['source'],
      title: json['title'],
      description: json['description'],
      author: json['author'],
      publishedAt: json['publishedAt'],
      urlToImage: json['urlToImage'],
      url: json['url'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'title': title,
      'description': description,
      'author': author,
      'publishedAt': publishedAt,
      'urlToImage': urlToImage,
      'url': url,
      'category': category,
    };
  }
}
