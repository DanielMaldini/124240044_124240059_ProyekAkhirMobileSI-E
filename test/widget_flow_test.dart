import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gutlog/controller/auth_controller.dart';
import 'package:gutlog/controller/log_controller.dart';
import 'package:gutlog/models/app_user.dart';
import 'package:gutlog/models/log_entry.dart';
import 'package:gutlog/view/pages/login_page.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HttpOverrides tiruan agar tidak ada request internet asli saat widget test.
class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw const SocketException('Internet dimock (offline) pada widget test');
  }
}

void main() {
  late Directory tempDir;
  late HttpOverrides? previousHttpOverrides;

  setUpAll(() async {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides();

    tempDir = await Directory.systemTemp.createTemp('leega_widget_test_');
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
    HttpOverrides.global = previousHttpOverrides;
    try {
      await Hive.close().timeout(const Duration(seconds: 2));
    } catch (_) {}
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  testWidgets(
    'Alur lengkap: register -> login -> HomePage -> tambah kondisi tanpa lokasi -> detail (tanpa Maps) -> edit -> hapus',
    (tester) async {
      // Mock method channel Geolocator & Local Notifications
      const geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(geolocatorChannel, (MethodCall call) async {
        switch (call.method) {
          case 'isLocationServiceEnabled':
            return false;
          case 'checkPermission':
          case 'requestPermission':
            return 0;
          default:
            return null;
        }
      });

      const notifChannel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notifChannel, (MethodCall call) async {
        return true;
      });

      Get.put(AuthController(), permanent: true);
      Get.put(LogController(), permanent: true);

      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // 1. Register
      await tester.tap(find.text('Belum punya akun? Daftar di sini'));
      await tester.pumpAndSettle();
      expect(find.text('Daftar Akun'), findsOneWidget);

      final regFields = find.byType(TextField);
      await tester.enterText(regFields.at(0), 'Daniel');
      await tester.enterText(regFields.at(1), 'daniel');
      await tester.enterText(regFields.at(2), 'pass123');
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();
      expect(find.text('Login Leega'), findsOneWidget);

      // 2. Login -> masuk ke RootPage (tab 0 = HomePage)
      final loginFields = find.byType(TextField);
      await tester.enterText(loginFields.at(0), 'daniel');
      await tester.enterText(loginFields.at(1), 'pass123');
      await tester.runAsync(() async {
        await tester.tap(find.text('Login'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      // Verifikasi HomePage menampilkan status pencernaan & tombol catat cepat
      expect(find.text('Halo, Daniel'), findsOneWidget);
      expect(find.text('Catat BAB Sekarang'), findsOneWidget);

      // 3. Tambah catatan langsung dari HomePage (pilih kondisi + tanpa lokasi)
      await tester.tap(find.text('Catat BAB Sekarang'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Catatan'), findsOneWidget);

      // Pilih kondisi "Keras / Susah" & gejala "Kembung"
      await tester.tap(find.text('Keras / Susah'));
      await tester.pump();
      await tester.tap(find.text('Kembung'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Catatan pagi tanpa lokasi');

      // Pastikan switch & tombol Simpan terlihat lalu matikan switch lokasi
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Simpan'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      // 4. Pindah ke tab Riwayat dan buka EntryDetailPage
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(find.text('Catatan pagi tanpa lokasi'), findsOneWidget);
      expect(find.text('Keras / Susah'), findsOneWidget);

      await tester.tap(find.text('Catatan pagi tanpa lokasi'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Catatan'), findsOneWidget);
      expect(find.text('Dicatat tanpa lokasi'), findsOneWidget);
      expect(find.text('Kembung'), findsOneWidget);
      expect(find.text('Lihat di Google Maps'), findsNothing);

      // 5. Edit catatan
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Edit Catatan'), findsOneWidget);
      expect(find.text('Catat lokasi saat ini'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Catatan sudah diedit');
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(find.text('Simpan'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.text('Catatan sudah diedit'), findsOneWidget);
      expect(find.text('Lihat di Google Maps'), findsNothing);

      // 6. Hapus catatan (dengan dialog konfirmasi)
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Hapus catatan ini?'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Belum ada catatan'), findsOneWidget);
      expect(find.text('Catatan sudah diedit'), findsNothing);
    },
  );
}
