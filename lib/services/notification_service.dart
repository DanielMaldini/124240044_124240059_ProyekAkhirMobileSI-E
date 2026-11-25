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

  // ─── Inisialisasi ─────────────────────────────────────────────────────────

  /// Harus dipanggil sekali saat app pertama kali dijalankan (di main.dart).
  Future<void> init() async {
    // Inisialisasi data zona waktu dari package timezone
    tz.initializeTimeZones();

    // Set zona waktu lokal ke Asia/Jakarta (WIB, UTC+7)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Konfigurasi icon launcher untuk notifikasi Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    // Inisialisasi plugin
    await notificationPlugin.initialize(initSettings);

    // Minta izin notifikasi ke pengguna (Android 13+)
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Buat channel notifikasi Android dengan importance tinggi
    // agar notifikasi muncul sebagai heads-up (pop-up singkat)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );

    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
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

  // ─── Notifikasi terjadwal ─────────────────────────────────────────────────

  /// Jadwalkan notifikasi berulang setiap hari pada waktu [scheduledTime].
  /// Menggunakan matchDateTimeComponents.time agar diulang setiap hari
  /// pada jam & menit yang sama.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Konversi DateTime ke TZDateTime supaya timezone diperhitungkan
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
      // Coba pakai exact alarm (butuh izin SCHEDULE_EXACT_ALARM)
      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        // Berulang setiap hari pada jam yang sama
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Jika exact alarm tidak diizinkan, fallback ke inexact
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
          // Jika inexact juga gagal, lempar error agar UI bisa menampilkannya
          rethrow;
        }
      } else {
        // Error lain yang tidak dikenali → lempar ulang ke pemanggil
        rethrow;
      }
    }
  }

  // ─── Batalkan notifikasi ──────────────────────────────────────────────────

  /// Batalkan notifikasi berdasarkan [id].
  /// Memanggil cancel() dari flutter_local_notifications.
  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id);
  }
}
