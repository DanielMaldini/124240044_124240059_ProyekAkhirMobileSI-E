import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/news_service.dart';
import '../../utils/app_theme.dart';

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
    final dateText = _formatDate(article.publishedAt);
    final bodyText =
        article.content.isNotEmpty ? article.content : article.description;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Artikel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
                    color: AppColors.subtleBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.sourceName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (dateText.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (article.description.isNotEmpty &&
                article.description != bodyText) ...[
              Text(
                article.description,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              bodyText.isNotEmpty
                  ? bodyText
                  : 'Ringkasan artikel tidak tersedia. Silakan baca versi lengkapnya melalui tautan di bawah ini.',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.inkSecondary,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openOriginalWebsite(context),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Baca Selengkapnya di Website Asli'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
