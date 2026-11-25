import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gutlog/controller/auth_controller.dart';
import 'package:gutlog/controller/log_controller.dart';
import 'package:gutlog/models/app_user.dart';
import 'package:gutlog/models/log_entry.dart';
import 'package:gutlog/view/pages/history_page.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('leega_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(AppUserAdapter());
    Hive.registerAdapter(LogEntryAdapter());
    await Hive.openBox<AppUser>('users');
    await Hive.openBox<LogEntry>('entries');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Hive.box<AppUser>('users').clear();
    await Hive.box<LogEntry>('entries').clear();
    Get.reset();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('AuthController register, login, and authorization isolation', () async {
    final auth = Get.put(AuthController());
    final log = Get.put(LogController());

    expect(auth.register('', '123', 'A'), 'Semua kolom wajib diisi');
    expect(auth.register('andi', '123', 'Andi'), isNull);
    expect(auth.register('andi', '456', 'Andi 2'), 'Username sudah dipakai');

    expect(await auth.login('andi', 'salah'), 'Username atau password salah');
    expect(await auth.login('andi', '123'), isNull);
    expect(auth.currentUser.value?.username, 'andi');

    // Tambah catatan untuk user 'andi' dan 'budi'
    final now = DateTime.now();
    await log.addEntry(LogEntry(username: 'andi', dateTime: now, note: 'Pagi'));
    await log.addEntry(LogEntry(username: 'budi', dateTime: now, note: 'Siang'));

    expect(log.entries.length, 1);
    expect(log.entries.first.note, 'Pagi');
  });

  test('LogController CRUD, date filter, and periodic counts', () async {
    final auth = Get.put(AuthController());
    auth.register('andi', '123', 'Andi');
    await auth.login('andi', '123');
    final log = Get.put(LogController());

    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final twentyDaysAgo = now.subtract(const Duration(days: 20));
    final fortyDaysAgo = now.subtract(const Duration(days: 40));

    final e1 = LogEntry(username: 'andi', dateTime: now, note: 'Hari ini');
    await log.addEntry(e1);
    await log.addEntry(LogEntry(username: 'andi', dateTime: threeDaysAgo, note: '3 hari lalu'));
    await log.addEntry(LogEntry(username: 'andi', dateTime: twentyDaysAgo, note: '20 hari lalu'));
    await log.addEntry(LogEntry(username: 'andi', dateTime: fortyDaysAgo, note: '40 hari lalu'));

    expect(log.entries.length, 4);
    expect(log.todayCount, 1);
    expect(log.weekCount, 2);
    expect(log.monthCount, 3);

    // Filter tanggal
    log.filterDate.value = threeDaysAgo;
    expect(log.visibleEntries.length, 1);
    expect(log.visibleEntries.first.note, '3 hari lalu');

    // Update saat filter tidak aktif / aktif
    e1.note = 'Hari ini (diedit)';
    await log.updateEntry(e1);
    log.filterDate.value = null;
    expect(log.entries.first.note, 'Hari ini (diedit)');

    // Delete
    await log.deleteEntry(e1);
    expect(log.entries.length, 3);
    expect(log.todayCount, 0);
  });

  testWidgets('HistoryPage renders periodic summary and entries', (tester) async {
    await tester.runAsync(() async {
      final auth = Get.put(AuthController());
      auth.register('andi', '123', 'Andi');
      await auth.login('andi', '123');
    });
    final log = Get.put(LogController());

    await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
    expect(find.text('Belum ada catatan'), findsOneWidget);
    expect(find.text('Hari Ini'), findsOneWidget);
    expect(find.text('7 Hari'), findsOneWidget);
    expect(find.text('30 Hari'), findsOneWidget);

    await tester.runAsync(() async {
      await log.addEntry(
        LogEntry(
          username: 'andi',
          dateTime: DateTime.now(),
          note: 'Catatan tes',
        ),
      );
    });
    await tester.pump();

    expect(find.text('Belum ada catatan'), findsNothing);
    expect(find.text('Catatan tes'), findsOneWidget);
  });
}
