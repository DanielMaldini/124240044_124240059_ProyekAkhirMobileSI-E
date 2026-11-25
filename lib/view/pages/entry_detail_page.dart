import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/log_controller.dart';
import '../../models/log_entry.dart';
import '../../utils/format.dart';
import 'entry_form_page.dart';

/// Halaman untuk melihat detail satu catatan.
/// Bersifat StatefulWidget agar bisa memanggil setState setelah
/// kembali dari halaman edit, sehingga tampilan selalu terbaru.
class EntryDetailPage extends StatefulWidget {
  final LogEntry entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  // ─── Aksi: buka halaman edit ─────────────────────────────────────────────

  Future<void> _openEdit() async {
    // Navigasi ke halaman form dengan entry yang ada (mode edit)
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntryFormPage(entry: widget.entry)),
    );
    // Setelah kembali, refresh tampilan agar data terbaru terlihat
    if (mounted) setState(() {});
  }

  // ─── Aksi: hapus catatan ─────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    // Tampilkan dialog konfirmasi sebelum benar-benar menghapus
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Hapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return; // Pengguna membatalkan

    // Hapus dari Hive lewat LogController
    await Get.find<LogController>().deleteEntry(widget.entry);

    // Pastikan widget masih ada sebelum navigasi
    if (!mounted) return;
    Navigator.pop(context); // Kembali ke daftar catatan
  }

  // ─── Aksi: buka Google Maps ───────────────────────────────────────────────

  Future<void> _openMaps() async {
    final lat = widget.entry.lat!;
    final lng = widget.entry.lng!;

    // Susun URL Google Maps berdasarkan koordinat
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      // Tangani jika launchUrl melempar exception (mis. paket tidak terpasang)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasLocation = entry.lat != null && entry.lng != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          // Tombol edit
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _openEdit,
          ),
          // Tombol hapus
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Hapus',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Waktu catatan ──
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Waktu'),
              // Gunakan formatDateTime dari utils/format.dart
              subtitle: Text(formatDateTime(entry.dateTime)),
            ),

            const Divider(),

            // ── Isi catatan ──
            const SizedBox(height: 8),
            const Text(
              'Catatan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              entry.note.isEmpty ? 'Tidak ada catatan' : entry.note,
              style: TextStyle(
                // Teks abu jika kosong
                color: entry.note.isEmpty ? Colors.grey : null,
              ),
            ),

            const SizedBox(height: 16),

            // ── Informasi lokasi ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF303A32),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    // Prioritas: address → koordinat → tanpa lokasi
                    entry.address != null
                        ? entry.address!
                        : hasLocation
                        ? '${entry.lat}, ${entry.lng}'
                        : 'Dicatat tanpa lokasi',
                    style: const TextStyle(color: Color(0xFF303A32)),
                  ),
                ],
              ),
            ),

            // ── Tombol Google Maps (hanya jika ada koordinat) ──
            if (hasLocation) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Lihat di Google Maps'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
