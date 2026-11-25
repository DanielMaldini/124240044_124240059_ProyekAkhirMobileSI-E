import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../controller/auth_controller.dart';
import '../../controller/log_controller.dart';
import '../../models/log_entry.dart';
import '../../services/geocoding_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../utils/format.dart';

/// Halaman untuk TAMBAH catatan baru atau EDIT catatan yang sudah ada.
/// Dibedakan lewat parameter [entry]:
///   - null  → mode tambah
///   - tidak null → mode edit
class EntryFormPage extends StatefulWidget {
  final LogEntry? entry;

  const EntryFormPage({super.key, this.entry});

  @override
  State<EntryFormPage> createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  // Apakah halaman ini dibuka untuk mengedit entri yang sudah ada?
  late final bool _isEditMode;

  // Tanggal & jam yang dipilih pengguna
  late DateTime _selectedDateTime;

  // Kontroler untuk TextField catatan (wajib di-dispose)
  late final TextEditingController _noteController;

  // Apakah pengguna ingin lokasi dicatat? Hanya relevan di mode tambah.
  bool _recordLocation = true;

  // Mencegah pengguna menekan tombol Simpan dua kali
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.entry != null;

    // Inisialisasi nilai awal berdasarkan mode
    _selectedDateTime = _isEditMode ? widget.entry!.dateTime : DateTime.now();
    _noteController = TextEditingController(
      text: _isEditMode ? widget.entry!.note : '',
    );
  }

  @override
  void dispose() {
    // Wajib dibuang agar tidak ada memory leak
    _noteController.dispose();
    super.dispose();
  }

  // ─── Pemilih tanggal & jam ───────────────────────────────────────────────

  Future<void> _pickDateTime() async {
    // Langkah 1: pilih tanggal (tidak boleh melewati hari ini)
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Batasi agar tidak bisa pilih masa depan
    );
    if (pickedDate == null) return; // Pengguna membatalkan

    // Langkah 2: pilih jam
    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;
    if (!mounted) return;

    // Gabungkan tanggal dan jam menjadi satu DateTime
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // ─── Logika simpan ───────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _isSaving = true);

    // Ambil username dari sesi yang sedang login
    final username = Get.find<AuthController>().currentUser.value?.username;
    if (username == null) {
      // Sesi sudah habis atau belum login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    final logController = Get.find<LogController>();

    try {
      if (_isEditMode) {
        // ── MODE EDIT ──
        widget.entry!.dateTime = _selectedDateTime;
        widget.entry!.note = _noteController.text.trim();
        await logController.updateEntry(widget.entry!);
      } else {
        // ── MODE TAMBAH ──
        double? lat;
        double? lng;
        String? address;

        if (_recordLocation) {
          // Minta posisi GPS
          final Position? position = await LocationService.getPosition();

          if (position == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Lokasi tidak tersedia, catatan disimpan tanpa lokasi',
                  ),
                ),
              );
            }
          } else {
            lat = position.latitude;
            lng = position.longitude;
            // Reverse geocoding (boleh null jika offline)
            address = await GeocodingService.reverse(lat, lng);
          }
        }

        // Buat entri baru dan simpan
        final newEntry = LogEntry(
          username: username,
          dateTime: _selectedDateTime,
          note: _noteController.text.trim(),
          lat: lat,
          lng: lng,
          address: address,
        );
        await logController.addEntry(newEntry);
      }

      // Cek pola frekuensi BAB setelah menyimpan catatan
      final allDates = logController.entries.map((e) => e.dateTime).toList();
      await NotificationService().checkDigestivePattern(allDates);

      // Pastikan widget masih terpasang sebelum mengakses context
      if (!mounted) return;
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      // Tampilkan pesan error singkat jika ada yang gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Selalu kembalikan tombol ke kondisi aktif
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Pemilih tanggal & waktu ──
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal & Waktu'),
              subtitle: Text(formatDateTime(_selectedDateTime)),
              onTap: _pickDateTime,
              trailing: const Icon(Icons.chevron_right),
            ),

            const SizedBox(height: 12),

            // ── TextField catatan ──
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 8),

            // ── Switch lokasi (hanya muncul saat mode tambah) ──
            if (!_isEditMode)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Catat lokasi saat ini'),
                value: _recordLocation,
                onChanged: (val) => setState(() => _recordLocation = val),
              ),

            const SizedBox(height: 16),

            // ── Card disclaimer ──
            Card(
              color: const Color(0xFFE8EEE5),
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Leega bukan alat diagnosis medis.',
                  style: TextStyle(color: Color(0xFF303A32)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Simpan ──
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
