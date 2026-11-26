import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/log_controller.dart';
import '../../services/news_service.dart';
import '../../utils/app_theme.dart';
import 'article_detail_page.dart';
import 'entry_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();
  String _selectedTopic = 'Semua';
  late Future<List<HealthArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchDigestiveNews(
      query: NewsService.topics[_selectedTopic],
    );
  }

  // Muat ulang berita saat user tarik ke bawah (pull-to-refresh)
  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = _newsService.fetchDigestiveNews(
        query: NewsService.topics[_selectedTopic],
      );
    });
    await _newsFuture;
  }

  // Ganti topik berita lalu panggil ulang NewsService sesuai query topik
  void _selectTopic(String topicLabel) {
    if (topicLabel == _selectedTopic) return;
    setState(() {
      _selectedTopic = topicLabel;
      _newsFuture = _newsService.fetchDigestiveNews(
        query: NewsService.topics[topicLabel],
      );
    });
  }

  // Warna teks/dot badge berdasarkan level status pencernaan
  Color _statusColor(String level) {
    if (level == 'good') return AppColors.green;
    if (level == 'warn') return AppColors.amber;
    if (level == 'alert') return AppColors.red;
    return AppColors.inkSecondary;
  }

  // Warna latar lembut badge status pencernaan
  Color _statusBgColor(String level) {
    if (level == 'good') return AppColors.greenSoft;
    if (level == 'warn') return AppColors.amberSoft;
    if (level == 'alert') return AppColors.redSoft;
    return AppColors.subtleBg;
  }

  @override
  Widget build(BuildContext context) {
    final hasAuth = Get.isRegistered<AuthController>();
    final hasLog = Get.isRegistered<LogController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Leega')),
      body: RefreshIndicator(
        onRefresh: _refreshNews,
        color: AppColors.ink,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            // ── Kartu Status Pencernaan Pribadi (otomatis update via Obx) ──
            if (hasLog)
              Obx(() {
                final log = Get.find<LogController>();
                final userName = hasAuth
                    ? Get.find<AuthController>().currentUser.value?.name
                    : null;
                final status = log.digestiveStatus;
                final statusColor = _statusColor(status.level);
                final statusBg = _statusBgColor(status.level);

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (userName != null && userName.isNotEmpty)
                            Expanded(
                              child: Text(
                                'Halo, $userName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status.badge,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        status.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.inkSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _QuickStat(
                                label: 'Terakhir BAB',
                                value: log.lastEntryRelativeText,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.border,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickStat(
                                label: '7 Hari Terakhir',
                                value: '${log.weekCount} kali',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EntryFormPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Catat BAB Sekarang'),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // ── Header Artikel & Filter Topik ──
            const Text(
              'Artikel & Edukasi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: NewsService.topics.keys.map((label) {
                  final selected = label == _selectedTopic;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => _selectTopic(label),
                      selectedColor: AppColors.ink,
                      backgroundColor: AppColors.surface,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.ink,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.ink : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // ── Daftar Artikel dari NewsService ──
            FutureBuilder<List<HealthArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }

                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Belum ada artikel tersedia.',
                        style: TextStyle(color: AppColors.inkSecondary),
                      ),
                    ),
                  );
                }

                return Column(
                  children: articles.map((article) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
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
                                  height: 156,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
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
                                        color: AppColors.inkSecondary,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                        height: 1.35,
                                      ),
                                    ),
                                    if (article.description.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        article.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.inkSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
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

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;

  const _QuickStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
