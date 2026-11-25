import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/log_entry.dart';
import 'auth_controller.dart';

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
}
