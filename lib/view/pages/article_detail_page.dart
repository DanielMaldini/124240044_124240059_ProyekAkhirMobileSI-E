import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/news_service.dart';

class ArticleDetailPage extends StatelessWidget {
  final HealthArticle article;

  const ArticleDetailPage({super.key, required this.article});

  Future<void> _openOriginalWebsite(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan artikel')),
      );
    }
  }

  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate)?.toLocal();
    if (parsed == null) return '';
    final d = parsed.day.toString().padLeft(2, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final y = parsed.year;
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4F775A);
    const darkGreen = Color(0xFF243B2B);
    const softGreen = Color(0xFFEAF2EC);

    final dateText = _formatDate(article.publishedAt);
    final bodyText = article.content.isNotEmpty
        ? article.content
        : article.description;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  article.imageUrl,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: softGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.sourceName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (dateText.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    dateText,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkGreen,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            if (article.description.isNotEmpty &&
                article.description != bodyText) ...[
              Text(
                article.description,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              bodyText.isNotEmpty ? bodyText : 'Ringkasan artikel tidak tersedia. Silakan baca versi lengkapnya melalui tautan di bawah ini.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openOriginalWebsite(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  'Baca Selengkapnya di Website Asli',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
