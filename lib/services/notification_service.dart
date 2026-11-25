import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service untuk mengelola notifikasi lokal.
/// Menggunakan pola Singleton supaya hanya ada satu instance
/// di seluruh aplikasi (pola Modul 7).
class NotificationService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Plugin utama flutter_local_notifications
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // ID channel Android — konstanta agar konsisten di semua method
  static const String _channelId = 'reminder_channel';
  static const String _channelName = 'Reminder Notifications';

  static const String _healthChannelId = 'health_alert_channel';
  static const String _healthChannelName = 'Peringatan Pola Pencernaan';

  // Callback yang dipanggil saat user menekan notifikasi peringatan kesehatan
  VoidCallback? onOpenHomeTab;

  // ─── Inisialisasi ─────────────────────────────────────────────────────────

  /// Harus dipanggil sekali saat app pertama kali dijalankan (di main.dart).
  Future<void> init() async {
    // Inisialisasi data zona waktu dari package timezone
    tz.initializeTimeZones();

    // Set zona waktu lokal ke Asia/Jakarta (WIB, UTC+7)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Konfigurasi icon launcher untuk notifikasi Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    // Inisialisasi plugin beserta handler klik notifikasi
    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'open_home') {
          onOpenHomeTab?.call();
        }
      },
    );

    final androidImpl = notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Minta izin notifikasi ke pengguna (Android 13+)
    await androidImpl?.requestNotificationsPermission();

    // Buat channel pengingat harian
    const reminderChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    await androidImpl?.createNotificationChannel(reminderChannel);

    // Buat channel peringatan kesehatan pencernaan
    const healthChannel = AndroidNotificationChannel(
      _healthChannelId,
      _healthChannelName,
      importance: Importance.high,
    );
    await androidImpl?.createNotificationChannel(healthChannel);
  }

  // ─── Notifikasi langsung ──────────────────────────────────────────────────

  /// Tampilkan notifikasi seketika (tidak terjadwal).
  /// Dipakai untuk tombol "Kirim Notifikasi Uji" di ReminderPage.
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // id 0 dipakai untuk notifikasi langsung (tidak bentrok dengan id 100)
    await notificationPlugin.show(0, title, body, details);
  }

  /// Tampilkan notifikasi peringatan pola pencernaan (dengan payload ke tab Home).
  Future<void> showHealthAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _healthChannelId,
      _healthChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await notificationPlugin.show(
      id,
      title,
      body,
      details,
      payload: 'open_home',
    );
  }

  // ─── Deteksi Pola BAB (Sembelit & Frekuensi Tinggi) ───────────────────────

  /// Mengecek pola BAB pengguna berdasarkan daftar waktu catatan [entryDates]:
  /// 1. Belum mencatat >= 3 hari -> peringatan kemungkinan sembelit (id 101)
  /// 2. Mencatat >= 3 kali pada hari ini -> peringatan frekuensi tinggi (id 102)
  Future<void> checkDigestivePattern(List<DateTime> entryDates) async {
    if (entryDates.isEmpty) return;

    final now = DateTime.now();

    // Urutkan dari yang paling baru
    final sorted = List<DateTime>.from(entryDates)
      ..sort((a, b) => b.compareTo(a));

    // 1. Cek selisih hari dari catatan terakhir
    final daysSinceLast = now.difference(sorted.first).inDays;
    if (daysSinceLast >= 3) {
      await showHealthAlert(
        id: 101,
        title: 'Sudah $daysSinceLast Hari Belum Mencatat BAB',
        body: 'Perbanyak minum air putih & serat. Tap untuk baca tips pencernaan di Home.',
      );
    }

    // 2. Cek jumlah catatan pada hari ini
    final todayCount = sorted
        .where(
          (d) => d.year == now.year && d.month == now.month && d.day == now.day,
        )
        .length;

    if (todayCount >= 3) {
      await showHealthAlert(
        id: 102,
        title: 'Frekuensi BAB Hari Ini Cukup Tinggi ($todayCount Kali)',
        body: 'Jaga hidrasi tubuhmu. Tap untuk membaca artikel & tips kesehatan di Home.',
      );
    }
  }

  // ─── Notifikasi terjadwal ─────────────────────────────────────────────────

  /// Jadwalkan notifikasi berulang setiap hari pada waktu [scheduledTime].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzScheduled = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('exact_alarms_not_permitted') ||
          errStr.contains('exact') ||
          errStr.contains('permission')) {
        try {
          await notificationPlugin.zonedSchedule(
            id,
            title,
            body,
            tzScheduled,
            details,
            matchDateTimeComponents: DateTimeComponents.time,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } catch (e2) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  // ─── Batalkan notifikasi ──────────────────────────────────────────────────

  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id);
  }
}
