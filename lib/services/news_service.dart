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

  const HealthArticle({
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

  // Daftar pilihan topik artikel untuk filter di HomePage (Label -> Query API)
  static const Map<String, String> topics = {
    'Semua': '(sembelit OR diare OR pencernaan OR "kesehatan usus")',
    'Sembelit': '(sembelit OR konstipasi OR "susah BAB")',
    'Diare': '(diare OR "sakit perut" OR hidrasi)',
    'Serat & Nutrisi': '(serat OR probiotik OR "makanan pencernaan")',
  };

  // Fallback lokal jika offline, timeout, atau kuota API habis
  static const List<HealthArticle> _fallbackArticles = [
    HealthArticle(
      title: 'Pentingnya Serat dan Air Putih untuk Melancarkan Pencernaan',
      description:
          'Asupan serat harian dan cukup cairan membantu menjaga rutinitas BAB tetap teratur.',
      content:
          'Serat dari buah, sayuran, dan biji-bijian utuh membantu melunakkan feses. Imbangi dengan minum air putih yang cukup setiap hari agar saluran cerna bekerja optimal.',
      url: 'https://ayosehat.kemkes.go.id/',
      imageUrl: '',
      sourceName: 'Panduan Leega',
      publishedAt: '',
    ),
    HealthArticle(
      title: 'Menjaga Hidrasi Saat Frekuensi BAB Meningkat',
      description:
          'Saat BAB lebih sering atau cair, tubuh kehilangan cairan lebih cepat dari biasanya.',
      content:
          'Perbanyak minum air putih, sup hangat, atau oralit untuk mengganti cairan dan elektrolit. Segera konsultasi ke dokter jika keluhan tidak membaik.',
      url: 'https://ayosehat.kemkes.go.id/',
      imageUrl: '',
      sourceName: 'Panduan Leega',
      publishedAt: '',
    ),
    HealthArticle(
      title: 'Kapan Sebaiknya Berkonsultasi ke Dokter?',
      description:
          'Kenali tanda perubahan pola pencernaan yang perlu diperiksakan ke tenaga medis.',
      content:
          'Perubahan pola BAB berkepanjangan, nyeri perut berat, atau adanya darah pada tinja adalah sinyal untuk segera memeriksakan diri ke dokter.',
      url: 'https://ayosehat.kemkes.go.id/',
      imageUrl: '',
      sourceName: 'Panduan Leega',
      publishedAt: '',
    ),
  ];

  /// Mengambil daftar artikel kesehatan pencernaan dari GNews API.
  /// Jika gagal (offline / timeout 6 detik / limit API), otomatis pakai 3 artikel lokal.
  Future<List<HealthArticle>> fetchDigestiveNews({String? query}) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'q': query ?? topics['Semua']!,
          'lang': 'id',
          'country': 'id',
          'max': '10',
          'apikey': _apiKey,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List articles = data['articles'] ?? [];
        if (articles.isNotEmpty) {
          return articles
              .map((json) => HealthArticle.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return _fallbackArticles;
    } catch (_) {
      // Offline atau timeout -> tetap tampilkan panduan lokal agar halaman tidak kosong
      return _fallbackArticles;
    }
  }
}
