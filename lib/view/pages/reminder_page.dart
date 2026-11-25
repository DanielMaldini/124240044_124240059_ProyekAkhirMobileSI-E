import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';

/// Halaman pengaturan pengingat harian.
/// Pengguna bisa mengaktifkan/mematikan notifikasi harian
/// dan memilih jam pengingat yang diinginkan.
class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  // ─── State ────────────────────────────────────────────────────────────────

  bool _reminderOn = false; // Apakah pengingat aktif?
  int _hour = 20; // Jam pengingat (default 20:00)
  int _minute = 0; // Menit pengingat
  bool _isLoading = true; // Mencegah interaksi saat sedang baca SharedPrefs

  // Key SharedPreferences — nama persis agar konsisten antar sesi
  static const String _keyOn = 'reminderOn';
  static const String _keyHour = 'reminderHour';
  static const String _keyMinute = 'reminderMinute';

  // ID notifikasi pengingat — tidak boleh bentrok dengan id 0 (instant)
  static const int _reminderId = 100;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Baca pengaturan tersimpan saat halaman dibuka
  }

  // ─── Baca & simpan SharedPreferences ─────────────────────────────────────

  /// Muat pengaturan dari SharedPreferences.
  /// Dipanggil saat initState; set _isLoading false setelah selesai.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return; // Widget sudah dibuang sebelum selesai membaca
    setState(() {
      _reminderOn = prefs.getBool(_keyOn) ?? false;
      _hour = prefs.getInt(_keyHour) ?? 20;
      _minute = prefs.getInt(_keyMinute) ?? 0;
      _isLoading = false;
    });
  }

  /// Simpan ketiga key pengaturan ke SharedPreferences.
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOn, _reminderOn);
    await prefs.setInt(_keyHour, _hour);
    await prefs.setInt(_keyMinute, _minute);
  }

  // ─── Logika jadwal & pembatalan ───────────────────────────────────────────

  /// Hitung DateTime target untuk pengingat hari ini.
  /// Jika jam yang dipilih sudah lewat, jadwalkan untuk besok.
  DateTime _buildScheduleTime() {
    final now = DateTime.now();
    var schedule = DateTime(now.year, now.month, now.day, _hour, _minute);
    if (schedule.isBefore(now)) {
      // Jam sudah lewat hari ini → jadwalkan besok pada jam yang sama
      schedule = schedule.add(const Duration(days: 1));
    }
    return schedule;
  }

  /// Aktifkan pengingat: jadwalkan notifikasi berulang setiap hari.
  Future<void> _enableReminder() async {
    await NotificationService().scheduleNotification(
      id: _reminderId,
      title: 'Pengingat Leega',
      body: 'Jangan lupa catat kondisi pencernaanmu hari ini.',
      scheduledTime: _buildScheduleTime(),
    );
  }

  /// Matikan pengingat: batalkan notifikasi yang sudah dijadwalkan.
  Future<void> _disableReminder() async {
    await NotificationService().cancelNotification(_reminderId);
  }

  // ─── Handler switch ON/OFF ────────────────────────────────────────────────

  /// Dipanggil saat pengguna menggeser switch pengingat.
  Future<void> _onSwitchChanged(bool value) async {
    setState(() => _reminderOn = value);

    try {
      if (value) {
        // Aktifkan: jadwalkan notifikasi
        await _enableReminder();
        await _saveSettings();

        if (!mounted) return;
        // Tampilkan konfirmasi jam yang aktif
        final timeStr =
            '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengingat aktif setiap hari pukul $timeStr')),
        );
      } else {
        // Nonaktifkan: batalkan notifikasi
        await _disableReminder();
        await _saveSettings();

        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pengingat dimatikan')));
      }
    } catch (_) {
      // Gagal mengaktifkan → kembalikan switch ke off dan simpan
      if (!mounted) return;
      setState(() => _reminderOn = false);
      await _saveSettings();
      if (!mounted) return; // Guard setelah await
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengaktifkan pengingat'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Handler ganti jam ────────────────────────────────────────────────────

  /// Tampilkan time picker; jika jam berubah, simpan & jadwalkan ulang.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );

    if (picked == null) return; // Pengguna membatalkan
    if (!mounted) return;

    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });

    // Simpan jam baru ke SharedPreferences
    await _saveSettings();

    // Jika pengingat sedang aktif, jadwalkan ulang dengan jam baru
    // (id yang sama akan menimpa jadwal lama secara otomatis)
    if (_reminderOn) {
      try {
        await _enableReminder();
      } catch (_) {
        if (!mounted) return;
        // Gagal menjadwalkan ulang → matikan pengingat
        setState(() => _reminderOn = false);
        await _saveSettings();
        if (!mounted) return; // Guard setelah await
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengaktifkan pengingat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Tombol uji notifikasi ────────────────────────────────────────────────

  /// Kirim notifikasi langsung untuk memastikan konfigurasi benar.
  Future<void> _sendTestNotification() async {
    await NotificationService().showInstantNotification(
      title: 'Tes Pengingat Leega',
      body: 'Notifikasi berjalan dengan baik.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Notifikasi uji dikirim')));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading indicator selama membaca SharedPreferences
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Format jam untuk tampilan ListTile
    final timeStr =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Harian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card penjelasan ──
            Card(
              color: const Color(0xFFE8EEE5),
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Aktifkan pengingat harian agar kamu tidak lupa mencatat '
                  'kondisi pencernaan setiap hari. Notifikasi akan dikirim '
                  'setiap hari pada jam yang kamu pilih.',
                  style: TextStyle(color: Color(0xFF303A32)),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Switch aktifkan pengingat ──
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aktifkan pengingat harian'),
              value: _reminderOn,
              onChanged: _onSwitchChanged,
            ),

            // ── Pemilih jam pengingat ──
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Jam pengingat'),
              // Jam selalu bisa diubah, terlepas dari switch on/off
              trailing: Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _pickTime,
            ),

            const SizedBox(height: 24),

            // ── Tombol kirim notifikasi uji ──
            ElevatedButton(
              onPressed: _sendTestNotification,
              child: const Text('Kirim Notifikasi Uji'),
            ),
          ],
        ),
      ),
    );
  }
}
