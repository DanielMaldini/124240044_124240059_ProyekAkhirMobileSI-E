import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/log_entry.dart';
import '../utils/app_theme.dart';
import 'auth_controller.dart';

class DigestiveStatusSummary {
  final String badge;
  final String title;
  final String subtitle;
  final String level; // 'good' | 'warn' | 'alert' | 'neutral'

  const DigestiveStatusSummary({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.level,
  });
}

class LogController extends GetxController {
  final Box<LogEntry> _box = Hive.box<LogEntry>('entries');
  final RxList<LogEntry> entries = <LogEntry>[].obs;
  final Rxn<DateTime> filterDate = Rxn<DateTime>();

  String? get _username => Get.find<AuthController>().currentUser.value?.username;

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  /// Muat catatan milik user yang sedang login (otorisasi), urut terbaru dulu.
  void loadEntries() {
    final user = _username;
    if (user == null) {
      entries.clear();
      return;
    }
    final data = _box.values.where((e) => e.username == user).toList();
    data.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    entries.assignAll(data);
  }

  Future<void> addEntry(LogEntry entry) async {
    await _box.add(entry);
    loadEntries();
  }

  Future<void> updateEntry(LogEntry entry) async {
    await entry.save();
    loadEntries();
  }

  Future<void> deleteEntry(LogEntry entry) async {
    await entry.delete();
    loadEntries();
  }

  /// Catatan paling baru (entries sudah terurut terbaru dulu).
  LogEntry? get latestEntry => entries.isEmpty ? null : entries.first;

  /// Daftar catatan yang tampil sesuai filter tanggal.
  List<LogEntry> get visibleEntries {
    final d = filterDate.value;
    if (d == null) return entries;
    return entries
        .where(
          (e) =>
              e.dateTime.year == d.year &&
              e.dateTime.month == d.month &&
              e.dateTime.day == d.day,
        )
        .toList();
  }

  int get todayCount {
    final now = DateTime.now();
    return entries
        .where(
          (e) =>
              e.dateTime.year == now.year &&
              e.dateTime.month == now.month &&
              e.dateTime.day == now.day,
        )
        .length;
  }

  int get weekCount {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return entries.where((e) => !e.dateTime.isBefore(start)).length;
  }

  int get monthCount {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 29));
    return entries.where((e) => !e.dateTime.isBefore(start)).length;
  }

  /// Jumlah catatan per hari selama 7 hari terakhir (index 0 = 6 hari lalu, index 6 = hari ini).
  List<int> get last7DaysCounts {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) {
      final target = today.subtract(Duration(days: 6 - i));
      return entries
          .where(
            (e) =>
                e.dateTime.year == target.year &&
                e.dateTime.month == target.month &&
                e.dateTime.day == target.day,
          )
          .length;
    });
  }

  /// Teks singkat kapan terakhir kali mencatat BAB.
  String get lastEntryRelativeText {
    final latest = latestEntry;
    if (latest == null) return 'Belum ada catatan';
    final diff = DateTime.now().difference(latest.dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  /// Menentukan ringkasan status pencernaan untuk kartu HomePage:
  /// 1. Belum ada catatan -> status netral ('Mulai Mencatat')
  /// 2. >= 3x hari ini atau terakhir Cair/Diare -> 'Perlu Hidrasi' (alert)
  /// 3. >= 3 hari belum mencatat atau terakhir Keras/Susah -> 'Perlu Perhatian' (warn)
  /// 4. Selain itu -> 'Pola Teratur' (good)
  DigestiveStatusSummary get digestiveStatus {
    final latest = latestEntry;
    if (latest == null) {
      return const DigestiveStatusSummary(
        badge: 'Mulai Mencatat',
        title: 'Belum ada data pencernaan',
        subtitle: 'Catat rutinitas BAB pertamamu untuk mulai memantau pola harian.',
        level: 'neutral',
      );
    }

    final now = DateTime.now();
    final daysSinceLast = now.difference(latest.dateTime).inDays;

    if (todayCount >= 3 || latest.condition == BowelConditions.watery) {
      return DigestiveStatusSummary(
        badge: 'Perlu Hidrasi',
        title: todayCount >= 3
            ? 'Frekuensi hari ini tinggi ($todayCount kali)'
            : 'Kondisi terakhir cair / diare',
        subtitle: 'Pastikan asupan air putih atau cairan elektrolit tercukupi.',
        level: 'alert',
      );
    }

    if (daysSinceLast >= 3 || latest.condition == BowelConditions.hard) {
      return DigestiveStatusSummary(
        badge: 'Perlu Perhatian',
        title: daysSinceLast >= 3
            ? 'Sudah $daysSinceLast hari belum mencatat'
            : 'Kondisi terakhir keras / susah',
        subtitle: 'Perbanyak konsumsi serat, buah, sayur, dan air putih.',
        level: 'warn',
      );
    }

    return DigestiveStatusSummary(
      badge: 'Pola Teratur',
      title: 'Pencernaan terlihat baik',
      subtitle: 'Tercatat $weekCount kali dalam 7 hari terakhir. Pertahankan pola sehatmu.',
      level: 'good',
    );
  }
}
