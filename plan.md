# GutLog — Final Project Plan

**Mata Kuliah:** Praktikum Teknologi dan Pemrograman Mobile  
**Tim:** 2 Orang (Orang A & Orang B)  
**Target Modul:** Modul 2 s.d. Modul 7 (Wajib) + Modul 8 GetX (Bonus)

> **Tujuan dokumen ini:** Menjadi panduan bersama bagi Orang A dan Orang B agar bisa bekerja **paralel tanpa bentrok di GitHub**, kodenya **sesuai materi praktikum**, **mudah dipahami saat tes *live coding***, dan **selesai tepat waktu**.

---

## 1. Ringkasan Konsep Aplikasi

**GutLog** adalah aplikasi *Personal Digestive Health Diary* berbasis waktu dan lokasi. Pengguna mencatat kapan ia BAB (`dateTime`), catatan bebas (`note`), dan lokasinya (`lat`, `lng`, `address`) dengan opsi **"catat tanpa lokasi"**.

Dari catatan tersebut, pengguna bisa:
- Melihat **ringkasan periodik** (*Hari ini / 7 hari / 30 hari*) dan **riwayat per tanggal**.
- Membuka lokasi catatan langsung di **Google Maps**.
- Mengatur **pengingat harian** (*scheduled notification*).

Aplikasi dibingkai secara netral sebagai pencatat pola kebiasaan/kesehatan pencernaan, **bukan alat diagnosis medis** (dilengkapi *disclaimer*).

---

## 2. Keputusan Desain & Penyederhanaan Final

Agar kode bersih, minim bug, dan mudah dijelaskan saat *live coding*, kita **memangkas** hal-hal yang bikin rumit tanpa menambah nilai rubrik:

| Tetap Dipakai | Dihapus / Tidak Dibuat |
|---|---|
| Tanggal & jam (`dateTime`), catatan (`note`), lokasi (`lat`, `lng`, `address`) | Input bentuk (Skala Bristol / `data/bristol.dart`), warna (`color`), dan nyeri (`hasPain`) |
| Ringkasan periodik angka (*Hari ini / 7 hari / 30 hari*) | Grafik / chart (`fl_chart`) atau kalender heatmap |
| Opsi *"catat tanpa lokasi"* saat buat catatan baru | Hapus lokasi pada catatan lama saat mode Edit |
| Password teks biasa (sesuai Modul 3 & 6) | Hash password dengan package `crypto` |
| Scheduled notification dari `ReminderPage` + tombol notif uji | Reschedule otomatis setiap `main.dart` dibuka |
| `Navigator` (Modul 4) + `GetX` State/DI (Modul 8) | `GetPage`, `Bindings`, `Get.toNamed`, `Get.arguments` |
| `ListTile` langsung di `HistoryPage` | Pemisahan widget `entry_card.dart` |

**Perbaikan teknis yang ditambahkan dari hasil review modul:**
1. Tambahkan `dispose()` untuk semua `TextEditingController` (pola Modul 6).
2. Tambahkan `.timeout(const Duration(seconds: 5))` pada `http.get` di `GeocodingService` agar loading tidak menggantung saat internet lambat.
3. Tambahkan `cancelNotification(int id)` di `NotificationService`.

---

## 3. Palet Warna & Tampilan (`ThemeData`)

Tema warna dipasang terpusat di `ThemeData` pada `main.dart` agar seragam dan tidak perlu menulis ulang kode warna di setiap halaman:

| Peran | Nama Warna | Kode Hex | Pemakaian di Flutter |
|---|---|---|---|
| Background utama | Cream | `#F8F7F2` | `scaffoldBackgroundColor: Color(0xFFF8F7F2)` |
| Warna utama & tombol | Sage Green | `#718B73` | `AppBar`, `ElevatedButton`, `FloatingActionButton`, active tab `BottomNavigationBar` (`foregroundColor: Colors.white` + teks tombol `FontWeight.w600` agar kontras jelas) |
| Latar alternatif | Warm Off-White | `#E8EEE5` | `Card` ringkasan periodik, `Card` disclaimer, container info lokasi |
| Teks utama | Dark Charcoal | `#303A32` | Judul, isi teks, ikon utama (`Colors.grey[700]` untuk teks sekunder/subtitle) |
| Pesan error | Merah | — | `Colors.red` pada `SnackBar` gagal login/register |

---

## 4. Pemetaan ke Materi Praktikum (Modul 2–8)

| Modul | Konsep & Pola yang Dipakai | Lokasi di GutLog |
|---|---|---|
| **Modul 2 (Widget)** | `Scaffold`, `AppBar`, `Column`, `Row`, `SizedBox`, `Padding`, `Card`, `Text`, `TextField`, `ElevatedButton`, `TextButton`, `IconButton`, `ListView.builder`, `ListTile`, `SingleChildScrollView` (+ `SwitchListTile`, `AlertDialog`) | Semua halaman di `view/pages/` |
| **Modul 3 (State & Data)** | `StatelessWidget`, `StatefulWidget`, `setState`, `TextEditingController` (+ `dispose`), Model class, conditional rendering, `SnackBar` | `LoginPage`, `RegisterPage`, `RootPage`, `EntryFormPage`, `EntryDetailPage`, `ReminderPage` |
| **Modul 4 (Navigation)** | `Navigator.push`, `pop`, `pushReplacement`, `pushAndRemoveUntil`, passing data lewat constructor, `BottomNavigationBar` | Alur Auth → `RootPage` → `HistoryPage`/`ProfilePage` → `EntryDetailPage`/`EntryFormPage`/`ReminderPage` |
| **Modul 5 (HTTP)** | `http.get`, `Uri.parse`, `statusCode == 200`, `jsonDecode`, `async/await`, `try-catch`, `.timeout()`, static method service, loading state | `GeocodingService.reverse()` (Nominatim OpenStreetMap) |
| **Modul 6 (Local Storage)** | `Hive.initFlutter`, `registerAdapter`, `openBox`, `@HiveType`, `@HiveField`, `HiveObject` (`save()`, `delete()`), `SharedPreferences` (`getString`, `setString`, `remove`, `getBool`, `setBool`, `getInt`, `setInt`), cek `mounted` | `models/*`, `AuthController`, `LogController`, `ReminderPage` |
| **Modul 7 (Notification & LBS)** | `NotificationService` (Singleton, `init`, `showInstantNotification`, `scheduleNotification`), `LocationService` (`isLocationServiceEnabled`, `checkPermission`, `requestPermission`, `getCurrentPosition`), `showDatePicker`, `showTimePicker`, konfigurasi `build.gradle.kts` & `AndroidManifest.xml` | `services/notification_service.dart`, `services/location_service.dart`, `EntryFormPage`, `HistoryPage`, `ReminderPage` |
| **Modul 8 (GetX — Bonus)** | `GetMaterialApp`, `GetxController`, `onInit()`, `.obs`, `Rxn`, `Obx()`, `Get.put(..., permanent: true)`, `Get.find()` | `main.dart`, `AuthController`, `LogController`, `HistoryPage`, `LoginPage`, `ProfilePage`, `EntryFormPage`, `EntryDetailPage` |

> **Catatan Live Coding (Jika diminta melepas GetX):** Karena navigasi sudah memakai `Navigator` (Modul 4), melepas GetX sangat mudah: ganti `GetMaterialApp` → `MaterialApp`, jadikan `AuthController` & `LogController` class Singleton biasa tanpa `GetxController`/`.obs`, dan ganti `Obx` di `HistoryPage` menjadi `ValueListenableBuilder(valueListenable: Hive.box<LogEntry>('entries').listenable(), ...)` sesuai Modul 6.

---

## 5. Struktur Folder Final

```text
lib/
├── main.dart
├── models/
│   ├── app_user.dart              # + app_user.g.dart (commit ke Git!)
│   └── log_entry.dart             # + log_entry.g.dart (commit ke Git!)
├── utils/
│   └── format.dart                # formatDateTime(DateTime dt)
├── services/
│   ├── location_service.dart      # GPS (Geolocator)
│   ├── geocoding_service.dart     # HTTP Nominatim + timeout
│   └── notification_service.dart  # Local notification + cancelNotification
├── controller/
│   ├── auth_controller.dart       # GetxController (register, login, sesi, logout)
│   └── log_controller.dart        # GetxController (CRUD, filter tanggal, hitung periodik)
└── view/
    └── pages/
        ├── login_page.dart
        ├── register_page.dart
        ├── root_page.dart         # BottomNavigationBar (Riwayat & Profil)
        ├── history_page.dart      # Ringkasan periodik + filter tanggal + daftar riwayat
        ├── profile_page.dart      # Info user, disclaimer, tombol ke ReminderPage, logout
        ├── entry_form_page.dart   # Tambah & edit (tanggal/jam, catatan, switch lokasi)
        ├── entry_detail_page.dart # Detail catatan, tombol Google Maps, edit & hapus
        └── reminder_page.dart     # Atur jam pengingat, on/off, tombol notif uji
```

---

## 6. Spesifikasi Data & Konfigurasi

### 6.1 Penyimpanan Lokal
- **Hive Box `users`:** Key = `username`, Value = `AppUser` (`username`, `password`, `name`).
- **Hive Box `entries`:** Auto-increment key (`box.add`), Value = `LogEntry`:
  - `@HiveField(0) String username` (otorisasi: tiap user hanya melihat catatannya sendiri)
  - `@HiveField(1) DateTime dateTime`
  - `@HiveField(2) String note`
  - `@HiveField(3) double? lat`
  - `@HiveField(4) double? lng`
  - `@HiveField(5) String? address`
  - *Field dibuat non-`final` dan extends `HiveObject` agar update & delete memakai `entry.save()` dan `entry.delete()` (aman saat list sedang difilter/diurutkan).*
- **SharedPreferences:** `sessionUser` (String), `reminderOn` (bool), `reminderHour` (int), `reminderMinute` (int).

### 6.2 `pubspec.yaml` & Android
- Dependencies: `get`, `http: ^1.6.0`, `shared_preferences: ^2.5.3`, `hive: ^2.2.3`, `hive_flutter: ^1.1.0`, `flutter_local_notifications: ^19.0.0`, `timezone: ^0.10.0`, `geolocator: ^13.0.0`, `url_launcher`.
- Dev dependencies: `hive_generator: ^2.0.1`, `build_runner: ^2.4.8`.
- `android/app/build.gradle.kts`: aktifkan `isCoreLibraryDesugaringEnabled = true` dan `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.
- `AndroidManifest.xml`:
  - Permissions: `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`.
  - `<queries>` untuk `ACTION_VIEW` dengan `scheme="https"` (wajib untuk `url_launcher` Google Maps di Android 11+).
  - 3 `<receiver>` notifikasi di dalam `<application>` (persis Modul 7).

---

## 7. Pembagian Kerja Paralel & Kontributor GitHub

Agar **grafik kontributor push di GitHub seimbang** dan **tidak ada konflik merge**, setiap file hanya punya **1 pemilik**.

### 7.1 Kepemilikan File

| Orang A (Akun, Data, Riwayat & Tema) | Orang B (Android, Service, Form, Detail & Notif) |
|---|---|
| `pubspec.yaml` | `android/app/build.gradle.kts` |
| `main.dart` | `android/app/src/main/AndroidManifest.xml` |
| `models/app_user.dart` (+ `.g.dart`) | `services/location_service.dart` |
| `models/log_entry.dart` (+ `.g.dart`) | `services/geocoding_service.dart` |
| `utils/format.dart` | `services/notification_service.dart` |
| `controller/auth_controller.dart` | `view/pages/entry_form_page.dart` |
| `controller/log_controller.dart` | `view/pages/entry_detail_page.dart` |
| `view/pages/login_page.dart` | `view/pages/reminder_page.dart` |
| `view/pages/register_page.dart` | |
| `view/pages/root_page.dart` | |
| `view/pages/history_page.dart` | |
| `view/pages/profile_page.dart` | |

### 7.2 Langkah 0 — Sync Kontrak (15 Menit Pertama, Sekali di Awal)
1. **Orang A** membuat repo GitHub, `flutter create`, mengisi `pubspec.yaml`, membuat `models/` + menjalankan `dart run build_runner build`, membuat `utils/format.dart`, dan membuat **file kerangka kosong (placeholder)** untuk semua file yang dipanggil lintas orang:
   - `AuthController`: `Rxn<AppUser> currentUser`, `register()`, `login()`, `restoreSession()`, `logout()`.
   - `LogController`: `RxList<LogEntry> entries`, `Rxn<DateTime> filterDate`, `visibleEntries`, `todayCount`, `weekCount`, `monthCount`, `loadEntries()`, `addEntry(LogEntry)`, `updateEntry(LogEntry)`, `deleteEntry(LogEntry)`.
   - `EntryFormPage({super.key, this.entry})` (`LogEntry? entry`).
   - `EntryDetailPage({super.key, required this.entry})` (`LogEntry entry`).
   - `ReminderPage({super.key})`.
   - `NotificationService` dengan method kosong `init()`.
2. **Orang A push ke `main`**, lalu **Orang B `git pull`**.

### 7.3 Alur Kerja Paralel (Jalan Bersamaan Tanpa Saling Tunggu)

| Gelombang | Orang A (Branch `feat/a-...`) | Orang B (Branch `feat/b-...`) |
|---|---|---|
| **Gelombang 1** | • Setup `ThemeData` palet warna & Hive init di `main.dart`<br>• `AuthController`, `LoginPage`, `RegisterPage`, `RootPage` | • Konfigurasi `build.gradle.kts` & `AndroidManifest.xml`<br>• `LocationService.getPosition()`<br>• `GeocodingService.reverse()` + timeout 5 detik |
| **Gelombang 2** | • `LogController` (CRUD Hive, filter tanggal, hitung `todayCount`, `weekCount`, `monthCount`)<br>• `HistoryPage` (Card ringkasan periodik + `ListView.builder` + filter tanggal) | • `EntryFormPage` (tambah/edit, `showDatePicker`, `showTimePicker`, switch lokasi, `dispose()`)<br>• `EntryDetailPage` (detail waktu/catatan/alamat, tombol Google Maps, edit & dialog hapus) |
| **Gelombang 3** | • `ProfilePage` (info akun, *disclaimer*, tombol ke `ReminderPage`, logout) | • `NotificationService` (init, instant, scheduled, cancel)<br>• `ReminderPage` (switch on/off, `showTimePicker`, tombol notif uji) |
| **Gelombang 4** | • Uji alur bersama di HP fisik, perbaiki bug di file masing-masing, tulis `README.md` bersama | • Uji alur bersama di HP fisik, perbaiki bug di file masing-masing, siapkan akun & data demo |

**Tips Testing Lokal Sebelum Merge:**
- **Orang A:** Bisa tambahkan sementara 1–2 data dummy saat mengetes `HistoryPage` sebelum `EntryFormPage` milik B selesai.
- **Orang B:** Bisa arahkan sementara `home:` di `main.dart` lokal ke `EntryFormPage()` atau `ReminderPage()` saat ngetes (**jangan di-commit** ke Git), lalu kembalikan sebelum push.

### 7.4 Aturan GitHub Agar Kontributor Terbaca Adil
1. **Wajib samakan email Git lokal dengan email akun GitHub masing-masing:**
   Cek dengan `git config user.email` — jika beda, set dengan `git config user.email "email-github-kalian@..."`. (Kalau beda, commit tidak akan terhitung di tab *Contributors* GitHub).
2. **Selalu buat branch per gelombang/fitur** (`git checkout -b feat/a-auth`), commit kecil tiap bagian selesai, lalu merge / Pull Request ke `main`.
3. **Selalu `git pull origin main`** sebelum membuat branch baru.
4. **Commit file `*.g.dart`** agar partner tidak perlu menjalankan ulang `build_runner`.

---

## 8. Hal yang Wajib Dicek Sebelum Mulai & Saat Uji Coba

### 8.1 Pengecekan Awal (`⚠`)
1. Cek versi terbaru `get` dan `url_launcher` di `pub.dev`.
2. Cek signature `notificationPlugin.cancel(...)` di `flutter_local_notifications: ^19.0.0`.
3. Isi `User-Agent` Nominatim dengan identitas + email tim yang valid (bukan teks placeholder).
4. Konfirmasi ke asisten: pemakaian `Navigator` (Modul 4) + GetX State/DI (Modul 8) serta izin demo memakai **HP fisik** di lab.

### 8.2 Checklist Pengujian (Minimal di HP Fisik)
- [ ] Register, login, tutup app total lalu buka lagi → masih login.
- [ ] Logout → tidak bisa kembali dengan tombol *Back*.
- [ ] Dua akun berbeda di 1 HP → masing-masing hanya melihat catatannya sendiri.
- [ ] Tambah catatan dengan lokasi → alamat Nominatim tampil; jika GPS mati/internet mati → tetap tersimpan dengan fallback.
- [ ] Tambah catatan dengan opsi *"catat tanpa lokasi"* → tombol Google Maps tidak muncul di Detail.
- [ ] Filter per tanggal & ringkasan periodik (*Hari ini / 7 hari / 30 hari*) sesuai dan tidak error saat kosong.
- [ ] Edit dan hapus catatan (termasuk saat filter tanggal aktif) memperbarui data yang benar.
- [ ] Tombol *"Lihat di Google Maps"* membuka koordinat yang tepat.
- [ ] Notifikasi uji langsung & notifikasi terjadwal muncul di HP.

---

## 9. Persiapan Live Coding & Presentasi

- **Code Walkthrough Berdua:** Setelah Gelombang 3, luangkan 15–20 menit saling menjelaskan alur end-to-end: *UI (`view/`) → State (`controller/`) → Akses luar (`services/`) → Penyimpanan (`Hive`/`SharedPreferences`)*.
- **Titik Ubah Cepat saat Live Coding:**
  - Ubah urutan/filter/hitungan periodik → buka `controller/log_controller.dart`.
  - Ubah syarat login/register → buka `controller/auth_controller.dart`.
  - Ubah API/GPS/notifikasi → buka `services/`.
  - Ubah warna tema → buka `ThemeData` di `main.dart`.
