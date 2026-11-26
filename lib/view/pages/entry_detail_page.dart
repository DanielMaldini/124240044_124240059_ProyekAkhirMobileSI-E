import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/log_controller.dart';
import '../../models/log_entry.dart';
import '../../utils/app_theme.dart';
import '../../utils/format.dart';
import 'entry_form_page.dart';

/// Halaman detail satu catatan.
class EntryDetailPage extends StatefulWidget {
  final LogEntry entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  Future<void> _openEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntryFormPage(entry: widget.entry)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Catatan',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        content: const Text(
          'Hapus catatan ini?',
          style: TextStyle(color: AppColors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await Get.find<LogController>().deleteEntry(widget.entry);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _openMaps() async {
    final lat = widget.entry.lat!;
    final lng = widget.entry.lng!;

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka Google Maps'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka Google Maps'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasLocation = entry.lat != null && entry.lng != null;
    final condOption = BowelConditions.fromLabel(entry.condition);
    final symptoms = entry.symptoms ?? const <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
            tooltip: 'Hapus',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Kartu Waktu & Kondisi ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: AppColors.inkSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatDateTime(entry.dateTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (condOption != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: condOption.bgColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              condOption.icon,
                              size: 15,
                              color: condOption.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${condOption.label} • ${condOption.subtitle}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: condOption.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (symptoms.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: symptoms
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.subtleBg,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Kartu Catatan ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.note.isEmpty ? 'Tidak ada catatan' : entry.note,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: entry.note.isEmpty
                            ? AppColors.inkMuted
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Kartu Lokasi ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.inkSecondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Lokasi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.address != null
                          ? entry.address!
                          : hasLocation
                              ? '${entry.lat}, ${entry.lng}'
                              : 'Dicatat tanpa lokasi',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: hasLocation
                            ? AppColors.ink
                            : AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tombol Google Maps (hanya jika ada koordinat) ──
            if (hasLocation) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Lihat di Google Maps'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
