# Leega — Panduan Final Project (Simple & Siap Kerja)

**Tim:** 2 Orang (Orang A & Orang B)  
**Target Modul:** Modul 2–7 (Wajib) + Modul 8 GetX (Bonus)  
**Repo:** `124240044_124240059_ProyekAkhirMobileSI-E`

---

## 1. Konsep Aplikasi (Singkat)

**Leega** adalah *Personal Digestive Health Diary* berbasis waktu dan lokasi:
- Catat kejadian BAB: **tanggal & jam** (`dateTime`), **catatan bebas** (`note`), dan **lokasi** (`lat`, `lng`, `address` — ada opsi *"catat tanpa lokasi"*).
- **Ringkasan periodik** (*Hari ini / 7 hari / 30 hari*) + **filter per tanggal** di halaman Riwayat.
- Tombol **"Lihat di Google Maps"** di halaman Detail (pakai `url_launcher`).
- **Pengingat harian** (*scheduled notification*) + tombol uji notifikasi.
- **Disclaimer:** *"Leega bukan alat diagnosis medis."* (di Profil & Form).

**Yang sengaja TIDAK dibuat (biar simpel & aman saat live coding):**
Tidak ada input bentuk (Bristol), warna, nyeri, grafik/chart, hapus lokasi saat edit, hash `crypto`, reschedule otomatis di `main.dart`, maupun `GetPage`/`Bindings` (navigasi tetap pakai `Navigator` Modul 4).

---

## 2. Palet Warna (Pasang di `ThemeData` pada `main.dart`)

| Peran | Hex | Pemakaian |
|---|---|---|
| Background utama (Cream) | `#F8F7F2` | `scaffoldBackgroundColor: Color(0xFFF8F7F2)` |
| Warna utama & tombol (Sage Green) | `#718B73` | `AppBar`, `ElevatedButton`, `FAB`, active `BottomNavigationBar` (`foregroundColor: Colors.white`, teks tombol `FontWeight.w600`) |
| Latar alternatif (Warm Off-White) | `#E8EEE5` | `Card` ringkasan periodik, `Card` disclaimer, box info lokasi |
| Teks utama (Dark Charcoal) | `#303A32` | Judul, teks isi, ikon utama (`Colors.grey[700]` untuk subtitle) |
| Error | Merah | `Colors.red` pada `SnackBar` gagal login/register |

---

## 3. Pembagian Kerja & Langkah Paralel (1 File = 1 Pemilik)

### Langkah 0 — Sync Awal (15 Menit Pertama, Orang A Dulu)
1. **Orang A** isi `pubspec.yaml` (lihat Bagian 4.1) lalu jalankan `flutter pub get`.
2. **Orang A** buat `models/app_user.dart`, `models/log_entry.dart` (lihat Bagian 4.2), lalu jalankan `dart run build_runner build` hingga muncul `*.g.dart`.
3. **Orang A** buat `utils/format.dart` + kerangka kontrak method di `AuthController`, `LogController`, `NotificationService().init()`, `EntryFormPage({super.key, this.entry})`, `EntryDetailPage({super.key, required this.entry})`.
4. **Orang A push ke `main`**, lalu **Orang B `git pull origin main`**.

Setelah Langkah 0 selesai, **kalian kerja 100% paralel di branch masing-masing!**

---

### Checklist Orang A (Akun, Data, Riwayat & Tema)
- **File milik A:** `pubspec.yaml`, `main.dart`, `models/*`, `utils/format.dart`, `controller/auth_controller.dart`, `controller/log_controller.dart`, `login_page.dart`, `register_page.dart`, `root_page.dart`, `history_page.dart`, `profile_page.dart`.
- **Urutan kerja:**
  1. **Gelombang 1 (`feat/a-auth`):**
     - Setup `ThemeData` (palet warna), `Hive.initFlutter()`, `registerAdapter`, `openBox('users')` & `openBox('entries')`, `NotificationService().init()`, dan `Get.put(..., permanent: true)` di `main.dart`.
     - Buat `AuthController` (`register`, `login`, `restoreSession`, `logout` pakai Hive `users` + `SharedPreferences` key `'sessionUser'`).
     - Buat `LoginPage`, `RegisterPage` (ingat `dispose()` untuk `TextEditingController`), dan `RootPage` (`BottomNavigationBar`: Riwayat & Profil).
  2. **Gelombang 2 (`feat/a-history`):**
     - Buat `LogController` (CRUD `addEntry`, `updateEntry`, `deleteEntry` pakai `entry.save()`/`entry.delete()`, filter `username` pemilik, `filterDate`, `visibleEntries`, serta hitungan `todayCount`, `weekCount`, `monthCount`).
     - Buat `HistoryPage` pakai `Obx`: tampilkan `Card` ringkasan periodik di atas, `ListView.builder` + `ListTile`, filter tanggal di `AppBar` (`showDatePicker` + tombol clear), dan `FAB` ke `EntryFormPage()`.
  3. **Gelombang 3 (`feat/a-profile`):**
     - Buat `ProfilePage`: tampilkan nama/username user, `Card` disclaimer medis, tombol menuju `ReminderPage()`, dan tombol Logout (`pushAndRemoveUntil` ke `LoginPage`).

---

### Checklist Orang B (Android, Service, Form, Detail & Notif)
- **File milik B:** `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `services/location_service.dart`, `services/geocoding_service.dart`, `services/notification_service.dart`, `entry_form_page.dart`, `entry_detail_page.dart`, `reminder_page.dart`.
- **Urutan kerja:**
  1. **Gelombang 1 (`feat/b-android-lbs`):**
     - Pasang konfigurasi desugaring di `build.gradle.kts` dan permission + `<queries>` + 3 `<receiver>` di `AndroidManifest.xml` (copy dari Bagian 4.4).
     - Buat `LocationService.getPosition()` (GPS + izin lokasi `Geolocator`).
     - Buat `GeocodingService.reverse(lat, lng)` (HTTP Nominatim + `.timeout(Duration(seconds: 5))`).
  2. **Gelombang 2 (`feat/b-form-detail`):**
     - Buat `EntryFormPage({LogEntry? entry})`: 1 halaman untuk tambah & edit (`_isEditMode = widget.entry != null`). Isi: pilih tanggal & jam (`showDatePicker` + `showTimePicker`), `TextField` catatan (+ `dispose()`), `SwitchListTile` *"Catat lokasi saat ini"* (saat tambah baru), loading `_isSaving`, lalu panggil `LogController.addEntry` / `updateEntry`.
     - Buat `EntryDetailPage({required LogEntry entry})`: tampilkan waktu, catatan, alamat/koordinat, tombol **"Lihat di Google Maps"** (hanya muncul jika `lat != null && lng != null`), tombol Edit di `AppBar`, dan tombol Hapus dengan `AlertDialog` konfirmasi → `LogController.deleteEntry`.
  3. **Gelombang 3 (`feat/b-notif`):**
     - Lengkapi `NotificationService`: `init()`, `showInstantNotification()`, `scheduleNotification()`, `cancelNotification(id)`.
     - Buat `ReminderPage`: `SwitchListTile` nyala/mati, `ListTile` pilih jam (`showTimePicker`), simpan ke `SharedPreferences` (`reminderOn`, `reminderHour`, `reminderMinute`), plus tombol *"Kirim Notifikasi Uji"*.

> **Tips Testing Lokal Sebelum Merge:** Orang B bisa ubah sementara `home:` di `main.dart` ke `EntryFormPage()` / `ReminderPage()` untuk mengetes tampilannya (**jangan di-commit**), lalu kembalikan sebelum push.

---

## 4. Snippet Wajib Siap Pakai (Copy-Paste Reference)

### 4.1 `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6                         # cek versi terbaru di pub.dev
  http: ^1.6.0
  shared_preferences: ^2.5.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_local_notifications: ^19.0.0
  timezone: ^0.10.0
  geolocator: ^13.0.0
  url_launcher: ^6.3.1                # cek versi terbaru di pub.dev

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

### 4.2 Models (Milik Orang A — Kontrak Bersama)
```dart
// lib/models/app_user.dart
import 'package:hive/hive.dart';
part 'app_user.g.dart';

@HiveType(typeId: 0)
class AppUser extends HiveObject {
  @HiveField(0) String username;
  @HiveField(1) String password;
  @HiveField(2) String name;

  AppUser({required this.username, required this.password, required this.name});
}
```

```dart
// lib/models/log_entry.dart
import 'package:hive/hive.dart';
part 'log_entry.g.dart';

@HiveType(typeId: 1)
class LogEntry extends HiveObject {
  @HiveField(0) String username;   // pemilik catatan (otorisasi)
  @HiveField(1) DateTime dateTime;
  @HiveField(2) String note;
  @HiveField(3) double? lat;       // null jika tanpa lokasi
  @HiveField(4) double? lng;
  @HiveField(5) String? address;   // hasil Nominatim, bisa null

  LogEntry({
    required this.username,
    required this.dateTime,
    required this.note,
    this.lat,
    this.lng,
    this.address,
  });
}
```
Generate adapter: `dart run build_runner build` (lalu commit file `*.g.dart`).

### 4.3 Kontrak `AuthController` & `LogController` (Dipakai Orang A & B)
- **`AuthController`:**
  - `final Rxn<AppUser> currentUser = Rxn<AppUser>();` → Orang B baca `Get.find<AuthController>().currentUser.value!.username` saat membuat `LogEntry`.
  - `String? register(String username, String password, String name)`
  - `Future<String?> login(String username, String password)`
  - `Future<bool> restoreSession()`
  - `Future<void> logout()`
- **`LogController`:**
  - `final RxList<LogEntry> entries = <LogEntry>[].obs;`
  - `final Rxn<DateTime> filterDate = Rxn<DateTime>();`
  - `List<LogEntry> get visibleEntries` (saring `filterDate` jika tidak null)
  - `int get todayCount`, `int get weekCount` (7 hari terakhir), `int get monthCount` (30 hari terakhir)
  - `void loadEntries()` (filter `e.username == currentUser.username`, urutkan terbaru dulu)
  - `Future<void> addEntry(LogEntry entry)`
  - `Future<void> updateEntry(LogEntry entry)` → `await entry.save(); loadEntries();`
  - `Future<void> deleteEntry(LogEntry entry)` → `await entry.delete(); loadEntries();`

### 4.4 Konfigurasi Android (Milik Orang B)

**`android/app/build.gradle.kts`:**
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

**`android/app/src/main/AndroidManifest.xml`:**
```xml
<!-- Di dalam <manifest>, di luar <application> -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>

<!-- Di dalam <application>, di bawah <activity> -->
<receiver
    android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver
    android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>
<receiver
    android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsReceiver"/>
```

### 4.5 Signature Service & Google Maps (Milik Orang B)
- **`LocationService.getPosition()` (`Future<Position?>`):** Cek `Geolocator.isLocationServiceEnabled()`, cek & minta izin `Geolocator.checkPermission()` / `requestPermission()`, return `null` jika ditolak/mati, atau `Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high))`.
- **`GeocodingService.reverse(double lat, double lng)` (`Future<String?>`):**
  ```dart
  final uri = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=jsonv2',
  );
  final response = await http.get(uri, headers: {
    'User-Agent': 'LeegaApp/1.0 (isi-email-tim@upnyk.ac.id)',
  }).timeout(const Duration(seconds: 5));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['display_name'] as String?;
  }
  return null;
  ```
  *(Bungkus dengan `try-catch` yang me-return `null` jika offline/timeout).*
- **Tombol Google Maps (`EntryDetailPage`):**
  ```dart
  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  await launchUrl(url, mode: LaunchMode.externalApplication);
  ```
- **`NotificationService`:** Singleton pattern (persis Modul 7), punya `init()`, `showInstantNotification({required String title, required String body})`, `scheduleNotification({required int id, required String title, required String body, required DateTime scheduledTime})`, dan `cancelNotification(int id)`. *(Cek parameter `notificationPlugin.cancel(id)` sesuai versi `19.0.0`).*

---

## 5. Aturan GitHub (Supaya Nilai Kontributor Aman)

1. **Samakan email Git lokal dengan akun GitHub masing-masing:**
   Cek lewat `git config user.email` — wajib sama persis dengan email di akun GitHub agar commit tercatat di tab *Contributors*.
2. **Kerja di branch per gelombang:** contoh `feat/a-auth`, `feat/b-android-lbs`. Commit kecil tiap 1 file/fitur selesai, lalu merge / Pull Request ke `main`.
3. **Selalu `git pull origin main`** sebelum buat branch baru.

---

## 6. Checklist Uji Coba & Live Coding

### Uji Coba Wajib (Utamakan di HP Fisik)
- [ ] Register, login, tutup app total lalu buka lagi → tetap login.
- [ ] Logout → tombol Back tidak bisa kembali ke halaman utama.
- [ ] Dua akun berbeda → tidak saling melihat catatan.
- [ ] Tambah catatan dengan lokasi → alamat muncul; jika GPS/internet mati → tetap tersimpan (fallback koordinat/tanpa lokasi).
- [ ] Tambah catatan dengan opsi *"catat tanpa lokasi"* → tombol Google Maps tidak tampil di Detail.
- [ ] Filter tanggal & ringkasan periodik (*Hari ini / 7 hari / 30 hari*) akurat.
- [ ] Edit & hapus catatan (termasuk saat filter aktif) bekerja tepat.
- [ ] Tombol Google Maps membuka lokasi yang benar.
- [ ] Notifikasi uji langsung & notifikasi terjadwal muncul.

### Persiapan Live Coding
- **Kalau diminta ubah logika:** Filter/urutan/periodik ada di `LogController`; validasi akun di `AuthController`; GPS/API/notif di `services/`.
- **Kalau diminta melepas GetX:** Ganti `GetMaterialApp` → `MaterialApp`, jadikan controller class Singleton biasa, dan ganti `Obx` di `HistoryPage` menjadi `ValueListenableBuilder(valueListenable: Hive.box<LogEntry>('entries').listenable(), ...)` (pola Modul 6).
- **Sebelum presentasi:** Lakukan *code walkthrough* 15 menit berdua agar keduanya bisa menjelaskan seluruh alur aplikasi.
