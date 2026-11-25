import 'dart:convert';

import 'package:http/http.dart' as http;

class HealthArticle {
  final String title;
  final String description;
  final String content;
  final String url;
  final String imageUrl;
  final String sourceName;
  final String publishedAt;

  HealthArticle({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  factory HealthArticle.fromJson(Map<String, dynamic> json) {
    final rawContent = (json['content'] ?? '').toString();
    final cleanedContent = rawContent
        .replaceAll(RegExp(r'\s*\[\d+\s*chars\]$'), '...')
        .trim();

    return HealthArticle(
      title: (json['title'] ?? 'Artikel Kesehatan').toString(),
      description: (json['description'] ?? '').toString(),
      content: cleanedContent,
      url: (json['url'] ?? '').toString(),
      imageUrl: (json['image'] ?? '').toString(),
      sourceName: (json['source']?['name'] ?? 'Berita Kesehatan').toString(),
      publishedAt: (json['publishedAt'] ?? '').toString(),
    );
  }
}

class NewsService {
  static const String _apiKey = '7daccd43dae5e73b2c9220fc692e8273';
  static const String _baseUrl = 'https://gnews.io/api/v4/search';

  Future<List<HealthArticle>> fetchDigestiveNews() async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'q': '(sembelit OR diare OR pencernaan OR "kesehatan usus")',
        'lang': 'id',
        'country': 'id',
        'max': '10',
        'apikey': _apiKey,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List articles = data['articles'] ?? [];
      return articles.map((json) => HealthArticle.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat berita (${response.statusCode})');
    }
  }
}
