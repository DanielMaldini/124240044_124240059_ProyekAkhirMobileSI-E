import 'package:flutter/material.dart';

import '../../services/news_service.dart';
import 'article_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();
  late Future<List<HealthArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchDigestiveNews();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = _newsService.fetchDigestiveNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4F775A);
    const softGreen = Color(0xFFEAF2EC);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GutLog Home'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNews,
        color: primaryGreen,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Kartu Header Tema Pencernaan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: softGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryGreen.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.health_and_safety, color: primaryGreen, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jaga Kesehatan Pencernaanmu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF243B2B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Catat rutinitas harian dan baca artikel terbaru seputar kesehatan usus & pencernaan.',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Artikel & Tips Pencernaan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF243B2B),
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Berita dari GNews API
            FutureBuilder<List<HealthArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryGreen),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Gagal memuat artikel. Periksa koneksi internetmu.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshNews,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Belum ada artikel ditemukan.'),
                    ),
                  );
                }

                return Column(
                  children: articles.map((article) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      elevation: 1.5,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ArticleDetailPage(article: article),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.imageUrl.isNotEmpty)
                              Image.network(
                                article.imageUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox(),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.sourceName.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: primaryGreen,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (article.description.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      article.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
