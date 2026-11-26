import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gutlog/controller/auth_controller.dart';
import 'package:gutlog/controller/log_controller.dart';
import 'package:gutlog/models/app_user.dart';
import 'package:gutlog/models/log_entry.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('leega_unit_test_');
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

  group('AuthController unit tests', () {
    test('register: menolak kolom kosong & username duplikat, menerima user baru', () {
      final auth = Get.put(AuthController());

      expect(auth.register('', '123', 'Nama'), 'Semua kolom wajib diisi');
      expect(auth.register('user1', '', 'Nama'), 'Semua kolom wajib diisi');
      expect(auth.register('user1', '123', ''), 'Semua kolom wajib diisi');

      expect(auth.register('user1', '123456', 'User Satu'), isNull);
      expect(auth.register('user1', 'abcdef', 'User Duplikat'), 'Username sudah dipakai');
    });

    test('login: menolak password salah / user tidak ada, menerima kredensial valid', () async {
      final auth = Get.put(AuthController());
      auth.register('andi', 'rahasia', 'Andi');

      expect(await auth.login('', 'rahasia'), 'Username dan password wajib diisi');
      expect(await auth.login('andi', ''), 'Username dan password wajib diisi');
      expect(await auth.login('andi', 'salah'), 'Username atau password salah');
      expect(await auth.login('budi', 'rahasia'), 'Username atau password salah');

      expect(await auth.login('andi', 'rahasia'), isNull);
      expect(auth.currentUser.value?.username, 'andi');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('sessionUser'), 'andi');
    });

    test('restoreSession: mengembalikan false jika kosong, true jika sesi valid', () async {
      final auth = Get.put(AuthController());
      auth.register('andi', 'rahasia', 'Andi');

      // Belum ada sesi tersimpan
      expect(await auth.restoreSession(), isFalse);
      expect(auth.currentUser.value, isNull);

      // Simulasikan sesi tersimpan di SharedPreferences
      SharedPreferences.setMockInitialValues({'sessionUser': 'andi'});
      expect(await auth.restoreSession(), isTrue);
      expect(auth.currentUser.value?.username, 'andi');

      // Sesi menunjuk ke username yang tidak ada di Hive
      SharedPreferences.setMockInitialValues({'sessionUser': 'tidak_ada'});
      expect(await auth.restoreSession(), isFalse);
      expect(auth.currentUser.value, isNull);
    });

    test('logout: menghapus sessionUser, currentUser, dan entries di LogController', () async {
      final auth = Get.put(AuthController());
      auth.register('andi', 'rahasia', 'Andi');
      await auth.login('andi', 'rahasia');

      final log = Get.put(LogController());
      await log.addEntry(
        LogEntry(username: 'andi', dateTime: DateTime.now(), note: 'Catatan 1'),
      );
      expect(log.entries.length, 1);

      await auth.logout();

      expect(auth.currentUser.value, isNull);
      expect(log.entries, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('sessionUser'), isNull);
    });
  });

  group('LogController unit tests', () {
    test('todayCount, weekCount (7 hari), monthCount (30 hari) tepat di batas hari', () async {
      final auth = Get.put(AuthController());
      auth.register('andi', '123', 'Andi');
      await auth.login('andi', '123');
      final log = Get.put(LogController());

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // Hari ini (batas awal hari ini)
      await log.addEntry(LogEntry(username: 'andi', dateTime: todayStart, note: 'awal_hari_ini'));
      // Hari ini (sekarang)
      await log.addEntry(LogEntry(username: 'andi', dateTime: now, note: 'sekarang'));

      // Tepat di batas 7 hari: 6 hari lalu 00:00:00 -> HARUS masuk weekCount & monthCount
      final weekBoundary = todayStart.subtract(const Duration(days: 6));
      await log.addEntry(LogEntry(username: 'andi', dateTime: weekBoundary, note: 'batas_7_hari'));

      // 1 detik sebelum batas 7 hari -> TIDAK masuk weekCount, TAPI masuk monthCount
      final beforeWeekBoundary = weekBoundary.subtract(const Duration(seconds: 1));
      await log.addEntry(LogEntry(username: 'andi', dateTime: beforeWeekBoundary, note: 'luar_7_hari'));

      // Tepat di batas 30 hari: 29 hari lalu 00:00:00 -> HARUS masuk monthCount
      final monthBoundary = todayStart.subtract(const Duration(days: 29));
      await log.addEntry(LogEntry(username: 'andi', dateTime: monthBoundary, note: 'batas_30_hari'));

      // 1 detik sebelum batas 30 hari -> TIDAK masuk monthCount
      final beforeMonthBoundary = monthBoundary.subtract(const Duration(seconds: 1));
      await log.addEntry(LogEntry(username: 'andi', dateTime: beforeMonthBoundary, note: 'luar_30_hari'));

      expect(log.entries.length, 6);
      expect(log.todayCount, 2);
      expect(log.weekCount, 3);
      expect(log.monthCount, 5);
    });

    test('filterDate menyaring berdasarkan tanggal dan urutan terbaru dulu', () async {
      final auth = Get.put(AuthController());
      auth.register('andi', '123', 'Andi');
      await auth.login('andi', '123');
      final log = Get.put(LogController());

      final now = DateTime.now();
      final t1 = DateTime(now.year, now.month, now.day, 8, 0);
      final t2 = DateTime(now.year, now.month, now.day, 14, 30);
      final yesterday = DateTime(now.year, now.month, now.day, 10, 0)
          .subtract(const Duration(days: 1));

      // Masukkan dalam urutan acak
      await log.addEntry(LogEntry(username: 'andi', dateTime: t1, note: 'pagi'));
      await log.addEntry(LogEntry(username: 'andi', dateTime: yesterday, note: 'kemarin'));
      await log.addEntry(LogEntry(username: 'andi', dateTime: t2, note: 'siang'));

      // Harus urut terbaru dulu: siang -> pagi -> kemarin
      expect(log.entries.map((e) => e.note).toList(), ['siang', 'pagi', 'kemarin']);

      // Filter hari ini
      log.filterDate.value = DateTime(now.year, now.month, now.day);
      expect(log.visibleEntries.map((e) => e.note).toList(), ['siang', 'pagi']);

      // Filter kemarin
      log.filterDate.value = yesterday;
      expect(log.visibleEntries.map((e) => e.note).toList(), ['kemarin']);

      // Hapus filter
      log.filterDate.value = null;
      expect(log.visibleEntries.length, 3);
    });

    test('isolasi data: akun A tidak boleh melihat catatan akun B', () async {
      final auth = Get.put(AuthController());
      auth.register('akunA', '123', 'Akun A');
      auth.register('akunB', '123', 'Akun B');

      await auth.login('akunA', '123');
      final log = Get.put(LogController());

      final now = DateTime.now();
      await log.addEntry(LogEntry(username: 'akunA', dateTime: now, note: 'Rahasia A'));
      await log.addEntry(LogEntry(username: 'akunB', dateTime: now, note: 'Rahasia B'));

      // Akun A hanya melihat catatan A
      expect(log.entries.length, 1);
      expect(log.entries.first.note, 'Rahasia A');

      // Logout lalu login sebagai Akun B
      await auth.logout();
      await auth.login('akunB', '123');
      log.loadEntries();

      expect(log.entries.length, 1);
      expect(log.entries.first.note, 'Rahasia B');
    });
  });
}
