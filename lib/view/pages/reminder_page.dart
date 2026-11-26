import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';

/// Halaman pengaturan pengingat harian.
class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  bool _reminderOn = false;
  int _hour = 20;
  int _minute = 0;
  bool _isLoading = true;

  static const String _keyOn = 'reminderOn';
  static const String _keyHour = 'reminderHour';
  static const String _keyMinute = 'reminderMinute';
  static const int _reminderId = 100;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _reminderOn = prefs.getBool(_keyOn) ?? false;
      _hour = prefs.getInt(_keyHour) ?? 20;
      _minute = prefs.getInt(_keyMinute) ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOn, _reminderOn);
    await prefs.setInt(_keyHour, _hour);
    await prefs.setInt(_keyMinute, _minute);
  }

  DateTime _buildScheduleTime() {
    final now = DateTime.now();
    var schedule = DateTime(now.year, now.month, now.day, _hour, _minute);
    if (schedule.isBefore(now)) {
      schedule = schedule.add(const Duration(days: 1));
    }
    return schedule;
  }

  Future<void> _enableReminder() async {
    await NotificationService().scheduleNotification(
      id: _reminderId,
      title: 'Pengingat Leega',
      body: 'Jangan lupa catat kondisi pencernaanmu hari ini.',
      scheduledTime: _buildScheduleTime(),
    );
  }

  Future<void> _disableReminder() async {
    await NotificationService().cancelNotification(_reminderId);
  }

  Future<void> _onSwitchChanged(bool value) async {
    setState(() => _reminderOn = value);

    try {
      if (value) {
        await _enableReminder();
        await _saveSettings();

        if (!mounted) return;
        final timeStr =
            '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengingat aktif setiap hari pukul $timeStr')),
        );
      } else {
        await _disableReminder();
        await _saveSettings();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengingat dimatikan')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _reminderOn = false);
      await _saveSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengaktifkan pengingat'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );

    if (picked == null) return;
    if (!mounted) return;

    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });

    await _saveSettings();

    if (_reminderOn) {
      try {
        await _enableReminder();
      } catch (_) {
        if (!mounted) return;
        setState(() => _reminderOn = false);
        await _saveSettings();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengaktifkan pengingat'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService().showInstantNotification(
      title: 'Tes Pengingat Leega',
      body: 'Notifikasi berjalan dengan baik.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi uji dikirim')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
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

    final timeStr =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Harian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.subtleBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Aktifkan pengingat harian agar kamu tidak lupa mencatat '
                'kondisi pencernaan setiap hari. Notifikasi akan dikirim '
                'setiap hari pada jam yang kamu pilih.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.inkSecondary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Aktifkan pengingat harian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    value: _reminderOn,
                    onChanged: _onSwitchChanged,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.schedule,
                      size: 20,
                      color: AppColors.ink,
                    ),
                    title: const Text(
                      'Jam pengingat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.subtleBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    onTap: _pickTime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: const Text('Kirim Notifikasi Uji'),
            ),
          ],
        ),
      ),
    );
  }
}
