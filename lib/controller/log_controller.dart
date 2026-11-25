import 'package:get/get.dart';
import '../models/log_entry.dart';

class LogController extends GetxController {
  final RxList<LogEntry> entries = <LogEntry>[].obs;
  final Rxn<DateTime> filterDate = Rxn<DateTime>();

  List<LogEntry> get visibleEntries => entries;
  int get todayCount => 0;
  int get weekCount => 0;
  int get monthCount => 0;

  void loadEntries() {
    // TODO: Implementasi di Tahap 2
  }

  Future<void> addEntry(LogEntry entry) async {
    // TODO: Implementasi di Tahap 2
  }

  Future<void> updateEntry(LogEntry entry) async {
    // TODO: Implementasi di Tahap 2
  }

  Future<void> deleteEntry(LogEntry entry) async {
    // TODO: Implementasi di Tahap 2
  }
}
