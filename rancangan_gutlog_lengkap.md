# GutLog: Rancangan Lengkap Final Project

**Mata kuliah:** Praktikum Teknologi dan Pemrograman Mobile
**Tim:** 2 orang (Orang A dan Orang B)
**Status:** rancangan awal. Nama aplikasi masih bisa diganti.

> **Cara membaca dokumen ini.** Kode di sini adalah *kerangka dasar* yang disusun dari pola di modul praktikum. Kode belum dijalankan, jadi siapkan waktu untuk menyesuaikan dan memperbaikinya. Bagian bertanda ⚠ berarti **perlu dicek ke dokumentasi resmi** sebelum dipakai.

---

## 1. Ringkasan Aplikasi

GutLog adalah buku harian pencernaan. Pengguna mencatat setiap kejadian BAB (waktu, tipe, kondisi, catatan) **beserta lokasinya**. Alamat tampil di riwayat, dan satu tombol membuka lokasi itu di Google Maps. Jadi pengguna bisa melihat "tanggal sekian aku di mana".

Aplikasi dibingkai sebagai *digestive health diary* yang netral, **bukan alat diagnosis medis**.

**Keputusan yang sudah diambil:**
- Penyimpanan data: **Hive**. Sesi dan pengaturan: **SharedPreferences**. Tanpa Supabase atau cloud.
- **Tanpa peta di dalam aplikasi.** Lokasi dibuka lewat link Google Maps.
- Alamat dari koordinat: HTTP ke **Nominatim** (OpenStreetMap).
- GetX dipakai untuk bonus (state dan dependency injection).

---

## 2. Ketentuan Final Project dan Checklist

| Ketentuan | Bagaimana GutLog memenuhinya | Selesai |
|---|---|---|
| Tema jelas | Diary kesehatan pencernaan berbasis lokasi | ☐ |
| Autentikasi | Register, login, logout, sesi tersimpan | ☐ |
| Otorisasi | Tiap pengguna hanya melihat dan mengubah catatannya sendiri | ☐ |
| CRUD | Tambah, lihat, edit, hapus `LogEntry` di Hive | ☐ |
| Modul 2 Widget | Layout form, list, kartu, tombol | ☐ |
| Modul 3 State dan data | `StatefulWidget`, `setState`, `TextEditingController`, model, conditional rendering | ☐ |
| Modul 4 Navigation | `push`, `pop`, `pushReplacement`, `pushAndRemoveUntil`, passing data, `BottomNavigationBar` | ☐ |
| Modul 5 HTTP | Nominatim: `http.get`, `jsonDecode`, `async/await` | ☐ |
| Modul 6 Local storage | Hive (user dan catatan), SharedPreferences (sesi dan pengaturan) | ☐ |
| Modul 7 Notification dan LBS | Scheduled notification, GPS, alamat, tombol Google Maps | ☐ |
| Modul 8 GetX (bonus) | `GetxController`, `.obs`, `Obx`, `Get.put`, `Get.find` | ☐ |
| Presentasi offline di lab | Skrip demo dan pembagian bicara (bagian 10) | ☐ |
| Pengumpulan | Repository GitHub dikirim lewat SPADA | ☐ |

---

## 3. Batasan (Scope)

Batasan ini penting supaya proyek selesai tepat waktu. **Kalau ada ide baru, cek dulu: apakah semua yang di daftar "Wajib" sudah jalan?** Kalau belum, ide itu ditunda.

### 3.1 Wajib dibuat

1. Register dan login lokal (username dan password), sesi tersimpan.
2. Logout.
3. Tambah catatan: tanggal dan jam, tipe Bristol (1 sampai 7), warna, ada nyeri atau tidak, catatan teks.
4. Lokasi otomatis dari GPS dengan opsi **"catat tanpa lokasi"**.
5. Alamat dari koordinat lewat Nominatim, dengan fallback bila gagal.
6. Riwayat catatan dengan **filter per tanggal**.
7. Detail catatan dengan tombol **"Lihat di Google Maps"**.
8. Edit dan hapus catatan.
9. Pengingat harian (scheduled notification) dengan pengaturan jam.
10. Teks disclaimer "bukan alat diagnosis medis".
11. GetX untuk state (`GetxController`, `.obs`, `Obx`) dan DI (`Get.put`, `Get.find`).

### 3.2 Opsional (hanya jika semua yang wajib selesai dan sudah diuji)

- Ringkasan tempat yang paling sering dicatat.
- Filter tambahan (hanya yang ada nyeri).
- Hash password dengan package `crypto` (di luar modul).

### 3.3 Tidak dikerjakan

| Tidak dibuat | Alasan |
|---|---|
| Peta di dalam aplikasi | Materi baru dan paling berisiko error |
| Supabase atau server sendiri | Di luar modul, dan bukan local storage |
| Role admin dan user | Tidak diperlukan untuk memenuhi ketentuan |
| Grafik dan statistik rumit | Menambah waktu tanpa menambah nilai wajib |
| Ekspor PDF atau CSV | Di luar lingkup |
| Edit ulang lokasi di catatan lama | Cukup bisa menghapus lokasi |
| Notifikasi berulang otomatis | Dijadwalkan ulang tiap aplikasi dibuka (lihat F9) |
| iOS | Konfigurasi modul hanya untuk Android |
| Dark mode, multi bahasa | Tidak ada di ketentuan |

**Batas ukuran:** maksimal **7 layar** (Login, Register, Root, Riwayat, Form, Detail, Pengaturan Pengingat) dan **satu entitas data** (`LogEntry`) ditambah `AppUser`.

---

## 4. Navigasi: Keputusan yang Perlu Dikonfirmasi

Modul 4 mengajarkan `Navigator.push/pop/pushReplacement/pushAndRemoveUntil`. Modul 8 mengganti semuanya dengan `Get.to/back/off/offAll`.

**Rancangan ini memakai `Navigator` (Modul 4) untuk perpindahan halaman**, dan GetX hanya untuk state dan DI. Alasannya, rubrik "mengimplementasikan seluruh modul" lebih aman terpenuhi: Modul 4 terlihat jelas, dan bonus GetX tetap didapat dari controller, `Obx`, `Get.put`, dan `Get.find`.

Kalau asisten menyatakan routing GetX (`Get.toNamed` dan `Binding`) juga dinilai, bagian navigasi bisa diganti ke versi Modul 8. Tanyakan saja ke asisten.

---

## 5. Struktur Folder

```text
lib/
├── main.dart
├── models/
│   ├── app_user.dart            # + app_user.g.dart (hasil generate)
│   └── log_entry.dart           # + log_entry.g.dart (hasil generate)
├── data/
│   └── bristol.dart             # label tipe 1 sampai 7
├── utils/
│   └── format.dart              # format tanggal dan jam
├── services/
│   ├── location_service.dart    # GPS (Modul 7)
│   ├── geocoding_service.dart   # HTTP Nominatim (Modul 5)
│   └── notification_service.dart# notifikasi (Modul 7)
├── controller/
│   ├── auth_controller.dart     # GetxController
│   └── log_controller.dart      # GetxController
└── view/
    ├── pages/
    │   ├── login_page.dart
    │   ├── register_page.dart
    │   ├── root_page.dart       # BottomNavigationBar
    │   ├── history_page.dart    # riwayat + filter
    │   ├── profile_page.dart    # profil, logout, disclaimer
    │   ├── entry_form_page.dart # tambah dan edit
    │   ├── entry_detail_page.dart
    │   └── reminder_page.dart
    └── widgets/
        └── entry_card.dart
```

---

## 6. Data

### 6.1 Penyimpanan

| Data | Tempat | Kunci |
|---|---|---|
| Akun pengguna | Hive box `users` | `username` |
| Catatan BAB | Hive box `entries` | otomatis (`box.add`) |
| Sesi login | SharedPreferences | `sessionUser` (string) |
| Pengingat aktif | SharedPreferences | `reminderOn` (bool) |
| Jam pengingat | SharedPreferences | `reminderHour`, `reminderMinute` (int) |

### 6.2 Model

```dart
// models/app_user.dart
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
// models/log_entry.dart
import 'package:hive/hive.dart';
part 'log_entry.g.dart';

@HiveType(typeId: 1)
class LogEntry extends HiveObject {
  @HiveField(0) String username;     // pemilik catatan (otorisasi)
  @HiveField(1) DateTime dateTime;
  @HiveField(2) int bristolType;     // 1 sampai 7
  @HiveField(3) String color;
  @HiveField(4) bool hasPain;
  @HiveField(5) String note;
  @HiveField(6) double? lat;         // null jika tanpa lokasi
  @HiveField(7) double? lng;
  @HiveField(8) String? address;     // hasil Nominatim, bisa null

  LogEntry({
    required this.username,
    required this.dateTime,
    required this.bristolType,
    required this.color,
    required this.hasPain,
    required this.note,
    this.lat,
    this.lng,
    this.address,
  });
}
```

Field dibuat tidak `final` supaya catatan bisa diubah langsung lalu `save()` (lihat F8).

Generate adapter (Modul 6):

```
dart run build_runner build
```

### 6.3 Data tetap Bristol (pola `dummyLocations` di Modul 7)

```dart
// data/bristol.dart  ⚠ cek ulang label dengan referensi skala Bristol
const Map<int, String> bristolLabels = {
  1: 'Gumpalan keras terpisah',
  2: 'Berbentuk sosis tapi bergumpal',
  3: 'Sosis dengan retakan di permukaan',
  4: 'Sosis halus dan lembut',
  5: 'Gumpalan lembut dengan tepi jelas',
  6: 'Potongan lembek dan berair',
  7: 'Cair, tanpa bentuk padat',
};
```

### 6.4 Helper format tanggal (disederhanakan dari `_formatDateTime` di Modul 7)

```dart
// utils/format.dart
String formatDateTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${dt.day}/${dt.month}/${dt.year}, $hour:$minute';
}
```

---

## 7. Konfigurasi Awal

### 7.1 `pubspec.yaml`

Versi mengikuti modul praktikum. ⚠ Cek ulang di pub.dev untuk `get` dan `url_launcher`.

```yaml
dependencies:
  flutter:
    sdk: flutter
  get:                              # Modul 8
  http: ^1.6.0                      # Modul 5
  shared_preferences: ^2.5.3        # Modul 6
  hive: ^2.2.3                      # Modul 6
  hive_flutter: ^1.1.0              # Modul 6
  flutter_local_notifications: ^19.0.0   # Modul 7
  timezone: ^0.10.0                 # Modul 7
  geolocator: ^13.0.0               # Modul 7
  url_launcher:                     # BARU, di luar modul

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

### 7.2 Android (dari Modul 7, ditambah dua hal)

- `build.gradle.kts`: aktifkan *core library desugaring* (`isCoreLibraryDesugaringEnabled = true` dan `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`).
- `AndroidManifest.xml`, di luar `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<!-- BARU: agar link https (Google Maps) bisa dibuka di Android 11 ke atas -->
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

- Di dalam `<application>`: tiga `<receiver>` notifikasi seperti di Modul 7.

### 7.3 `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/app_user.dart';
import 'models/log_entry.dart';
import 'services/notification_service.dart';
import 'controller/auth_controller.dart';
import 'controller/log_controller.dart';
import 'view/pages/login_page.dart';
import 'view/pages/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(LogEntryAdapter());
  await Hive.openBox<AppUser>('users');
  await Hive.openBox<LogEntry>('entries');
  await NotificationService().init();

  final auth = Get.put(AuthController(), permanent: true);
  final loggedIn = await auth.restoreSession();
  Get.put(LogController(), permanent: true);

  runApp(MainApp(loggedIn: loggedIn));
}

class MainApp extends StatelessWidget {
  final bool loggedIn;
  const MainApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GutLog',
      debugShowCheckedModeBanner: false,
      home: loggedIn ? const RootPage() : const LoginPage(),
    );
  }
}
```

---

## 8. Fitur dan Dasar Implementasinya

Tiap fitur berisi: apa yang dibuat, modul rujukan, kerangka kode, dan batasnya.

### F1. Register

**Modul:** 3 (form dan controller), 6 (Hive).

```dart
// controller/auth_controller.dart (bagian awal)
class AuthController extends GetxController {
  final Box<AppUser> _usersBox = Hive.box<AppUser>('users');
  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  /// Mengembalikan pesan error, atau null jika berhasil
  String? register(String username, String password, String name) {
    if (username.isEmpty || password.isEmpty || name.isEmpty) {
      return 'Semua kolom wajib diisi';
    }
    if (_usersBox.containsKey(username)) {
      return 'Username sudah dipakai';
    }
    _usersBox.put(username, AppUser(
      username: username, password: password, name: name,
    ));
    return null;
  }
}
```

Di halaman register: tiga `TextField` dengan `TextEditingController` (Modul 3), password `obscureText: true`, lalu `SnackBar` bila error.

**Batas:** password disimpan apa adanya (cukup untuk tugas). Hash adalah opsional.

### F2. Login dan sesi

**Modul:** 6 (SharedPreferences), 4 (`pushReplacement`).

```dart
// auth_controller.dart (lanjutan)
Future<bool> restoreSession() async {
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('sessionUser');
  if (username == null) return false;
  currentUser.value = _usersBox.get(username);
  return currentUser.value != null;
}

Future<String?> login(String username, String password) async {
  final user = _usersBox.get(username);
  if (user == null || user.password != password) {
    return 'Username atau password salah';
  }
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('sessionUser', username);
  currentUser.value = user;
  return null;
}
```

```dart
// login_page.dart
void _onLogin() async {
  final error = await auth.login(
    _usernameC.text.trim(), _passwordC.text.trim(),
  );
  if (!mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
    return;
  }
  Get.find<LogController>().loadEntries();   // muat catatan milik user ini
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const RootPage()),
  );
}
```

Perbedaan dari Modul 6: yang disimpan adalah `String` username (`setString`), bukan `bool`, supaya diketahui siapa yang login.

### F3. Logout

**Modul:** 6 (hapus sesi), 4 (`pushAndRemoveUntil`).

```dart
// auth_controller.dart
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('sessionUser');
  currentUser.value = null;
  Get.find<LogController>().entries.clear();
}
```

```dart
// profile_page.dart
onPressed: () async {
  await auth.logout();
  if (!context.mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
},
```

### F4. Kerangka halaman utama (Bottom Navigation)

**Modul:** 4.

```dart
// root_page.dart
class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [HistoryPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

Karena filter disimpan di controller (bukan di halaman), pindah tab tidak menghapus filter.

### F5. Controller catatan (inti CRUD, tanpa UI)

**Modul:** 6 (Hive), 8 (controller, `.obs`).

```dart
// controller/log_controller.dart
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

  // Otorisasi: hanya catatan milik user yang login
  void loadEntries() {
    final data = _box.values.where((e) => e.username == _username).toList();
    data.sort((a, b) => b.dateTime.compareTo(a.dateTime));   // terbaru dulu
    entries.assignAll(data);
  }

  // Create
  Future<void> addEntry(LogEntry entry) async {
    await _box.add(entry);
    loadEntries();
  }

  // Update: ubah field objeknya dulu di form, lalu panggil ini
  Future<void> updateEntry(LogEntry entry) async {
    await entry.save();
    loadEntries();
  }

  // Delete
  Future<void> deleteEntry(LogEntry entry) async {
    await entry.delete();
    loadEntries();
  }

  // Filter per tanggal (daftar yang ditampilkan)
  List<LogEntry> get visibleEntries {
    final d = filterDate.value;
    if (d == null) return entries;
    return entries.where((e) =>
      e.dateTime.year == d.year &&
      e.dateTime.month == d.month &&
      e.dateTime.day == d.day,
    ).toList();
  }
}
```

**Kenapa `entry.save()` dan `entry.delete()`, bukan `putAt(index)`?** Di Modul 6 edit dan hapus memakai `index`. Setelah riwayat difilter, nomor urut di layar tidak sama dengan nomor di box, jadi catatan yang salah bisa terhapus. Karena `LogEntry` extends `HiveObject`, objeknya tahu dirinya sendiri.

### F6. Riwayat dan filter per tanggal

**Modul:** 2 (`ListView.builder`, `ListTile`), 7 (`showDatePicker`), 8 (`Obx`).

```dart
// history_page.dart (isi body)
Obx(() {
  final list = log.visibleEntries;
  if (list.isEmpty) {
    return const Center(child: Text('Belum ada catatan'));
  }
  return ListView.builder(
    itemCount: list.length,
    itemBuilder: (context, index) {
      final e = list[index];
      return ListTile(
        leading: CircleAvatar(child: Text('${e.bristolType}')),
        title: Text(formatDateTime(e.dateTime)),
        subtitle: Text(e.address ?? (e.lat == null ? 'Tanpa lokasi' : 'Lokasi tersimpan')),
        trailing: Icon(e.hasPain ? Icons.warning_amber : Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EntryDetailPage(entry: e)),
        ),
      );
    },
  );
})
```

Tombol filter di `AppBar`:

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.calendar_today),
    onPressed: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) log.filterDate.value = picked;
    },
  ),
  IconButton(
    icon: const Icon(Icons.clear),
    tooltip: 'Hapus filter',
    onPressed: () => log.filterDate.value = null,
  ),
],
```

FAB untuk tambah: `Navigator.push(... EntryFormPage())`.

**Batas:** satu filter saja (tanggal). Daftar kosong menampilkan teks, bukan error.

### F7. GPS dan opsi "catat tanpa lokasi"

**Modul:** 7 (alur izin dan `getCurrentPosition`).

```dart
// services/location_service.dart
class LocationService {
  /// Mengembalikan posisi, atau null jika GPS mati / izin ditolak
  static Future<Position?> getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
```

Di form, opsi "tanpa lokasi" cukup satu `Switch`:

```dart
bool _useLocation = true;

SwitchListTile(
  title: const Text('Catat lokasi saat ini'),
  value: _useLocation,
  onChanged: (v) => setState(() => _useLocation = v),
),
```

Kalau `_useLocation` false, atau GPS gagal, `lat`, `lng`, dan `address` dibiarkan `null`.

### F8. Alamat dari koordinat (HTTP Nominatim)

**Modul:** 5 (`http.get`, `jsonDecode`, `async/await`, `try-catch`).

```dart
// services/geocoding_service.dart
class GeocodingService {
  static Future<String?> reverse(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=jsonv2',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'GutLogApp/1.0 (ganti-dengan-email-kalian)',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] as String?;
      }
      return null;
    } catch (e) {
      return null;     // offline atau gagal: pakai fallback
    }
  }
}
```

**Aturan Nominatim yang harus dipatuhi:** wajib `User-Agent` yang jelas (tanpa itu bisa ditolak), batas sekitar satu permintaan per detik, dan jangan memanggil berulang. Panggil **sekali per catatan baru**, dan hasilnya disimpan di `address`. Hasilnya berupa satu string alamat panjang (`display_name`). ⚠ Cek kebijakan terbaru di dokumentasi Nominatim sebelum mulai.

**Fallback:** kalau `address` null tapi `lat` dan `lng` ada, tampilkan koordinat.

### F9. Form tambah dan edit catatan

**Modul:** 3 (state, controller), 7 (picker tanggal dan jam, `DropdownButtonFormField`), 2 (`SingleChildScrollView`).

Satu form untuk dua mode, seperti `AddTodoScreen` di Modul 6:

```dart
class EntryFormPage extends StatefulWidget {
  final LogEntry? entry;                 // null = tambah, ada = edit
  const EntryFormPage({super.key, this.entry});
  @override
  State<EntryFormPage> createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  final noteC = TextEditingController();
  late DateTime _dateTime;
  int _bristol = 4;
  String _color = 'Cokelat';
  bool _hasPain = false;
  bool _useLocation = true;
  bool _isSaving = false;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.entry != null;
    _dateTime = widget.entry?.dateTime ?? DateTime.now();
    if (_isEditMode) {
      _bristol = widget.entry!.bristolType;
      _color = widget.entry!.color;
      _hasPain = widget.entry!.hasPain;
      noteC.text = widget.entry!.note;
    }
  }
```

Memilih tanggal dan jam (dari Modul 7):

```dart
Future<void> _pickDateTime() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: _dateTime,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );
  if (pickedDate == null || !mounted) return;
  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(_dateTime),
  );
  if (pickedTime == null) return;
  setState(() {
    _dateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute);
  });
}
```

Menyimpan:

```dart
Future<void> _save() async {
  setState(() => _isSaving = true);
  final log = Get.find<LogController>();

  if (_isEditMode) {
    // Edit: ubah field lalu save (lokasi lama tidak diambil ulang)
    final e = widget.entry!;
    e.dateTime = _dateTime;
    e.bristolType = _bristol;
    e.color = _color;
    e.hasPain = _hasPain;
    e.note = noteC.text.trim();
    await log.updateEntry(e);
  } else {
    double? lat, lng;
    String? address;
    if (_useLocation) {
      final pos = await LocationService.getPosition();
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
        address = await GeocodingService.reverse(lat, lng);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi tidak tersedia, disimpan tanpa lokasi.')),
        );
      }
    }
    await log.addEntry(LogEntry(
      username: Get.find<AuthController>().currentUser.value!.username,
      dateTime: _dateTime,
      bristolType: _bristol,
      color: _color,
      hasPain: _hasPain,
      note: noteC.text.trim(),
      lat: lat, lng: lng, address: address,
    ));
  }

  if (mounted) Navigator.pop(context);
}
```

Tipe Bristol dipilih dengan `DropdownButtonFormField<int>` dari `bristolLabels`. Selama `_isSaving` true, tampilkan `CircularProgressIndicator` dan nonaktifkan tombol (pola `isLoading` di Modul 5).

### F10. Detail catatan dan tombol Google Maps

**Modul:** 4 (passing data lewat constructor), 3 (conditional rendering).

```dart
class EntryDetailPage extends StatefulWidget {
  final LogEntry entry;
  const EntryDetailPage({super.key, required this.entry});
  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}
```

Tombol Google Maps hanya muncul kalau ada lokasi:

```dart
if (widget.entry.lat != null && widget.entry.lng != null)
  ElevatedButton.icon(
    icon: const Icon(Icons.map),
    label: const Text('Lihat di Google Maps'),
    onPressed: () => _openMaps(widget.entry.lat!, widget.entry.lng!),
  ),
```

```dart
Future<void> _openMaps(double lat, double lng) async {
  // ⚠ cek format link resmi di dokumentasi "Google Maps URLs"
  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!ok && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
    );
  }
}
```

Tombol edit dan hapus di `AppBar`:

```dart
// Edit: setelah kembali dari form, segarkan halaman ini
onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EntryFormPage(entry: widget.entry)),
  );
  setState(() {});
},

// Hapus: konfirmasi dulu
onPressed: () async {
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus catatan?'),
      content: const Text('Catatan ini tidak bisa dikembalikan.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
      ],
    ),
  );
  if (yes == true) {
    await Get.find<LogController>().deleteEntry(widget.entry);
    if (mounted) Navigator.pop(context);
  }
},
```

### F11. Pengingat (scheduled notification) dan pengaturannya

**Modul:** 7 (notifikasi terjadwal, `showTimePicker`), 6 (SharedPreferences).

`NotificationService` disalin dari Modul 7 (singleton, `init`, `scheduleNotification`), ditambah satu fungsi pembatal:

```dart
Future<void> cancelNotification(int id) async {
  await notificationPlugin.cancel(id);   // ⚠ cek bentuk parameter sesuai versi flutter_local_notifications
}
```

Menyimpan pengaturan dan menjadwalkan:

```dart
Future<void> _saveReminder(TimeOfDay time) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('reminderHour', time.hour);
  await prefs.setInt('reminderMinute', time.minute);
  await prefs.setBool('reminderOn', true);

  // Jadwalkan kemunculan berikutnya: hari ini jika belum lewat, kalau sudah lewat besok
  final now = DateTime.now();
  var when = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  if (when.isBefore(now)) when = when.add(const Duration(days: 1));

  await NotificationService().scheduleNotification(
    id: 1,
    title: 'Pengingat GutLog',
    body: 'Jangan lupa catat kondisi pencernaanmu hari ini.',
    scheduledTime: when,
  );
}

Future<void> _turnOff() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('reminderOn', false);
  await NotificationService().cancelNotification(1);
}
```

UI: `SwitchListTile` untuk nyala atau mati, dan `ListTile` yang membuka `showTimePicker`. Saat halaman dibuka, baca `reminderHour` dan `reminderMinute` untuk menampilkan jam tersimpan.

**Batas:** notifikasi hanya satu kali pada waktu berikutnya. Supaya terasa harian, jadwalkan ulang setiap aplikasi dibuka (cek `reminderOn` di `main.dart`). Untuk pengulangan otomatis, plugin punya opsi tersendiri ⚠ (cek `matchDateTimeComponents` di dokumentasi `flutter_local_notifications`), tapi itu di luar modul.

Tombol "Kirim notifikasi uji" (`showInstantNotification` dari Modul 7) berguna untuk demo.

### F12. Disclaimer

**Modul:** 2 (widget sederhana).

Tampilkan di halaman Profil dan di bawah form:

```dart
const Card(
  color: Color(0xFFFFF8E1),
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text(
      'GutLog bukan alat diagnosis medis. Jika ada darah pada tinja, '
      'nyeri berkepanjangan, atau keluhan lain, konsultasikan ke dokter.',
      style: TextStyle(fontSize: 12),
    ),
  ),
),
```

### F13. (Opsional) Ringkasan tempat

Hanya menghitung data yang sudah ada, tanpa materi baru:

```dart
Map<String, int> get placeCount {
  final map = <String, int>{};
  for (final e in entries) {
    if (e.address == null) continue;
    final place = e.address!.split(',').take(2).join(',').trim();
    map[place] = (map[place] ?? 0) + 1;
  }
  return map;
}
```

---

## 9. Pembagian Pengerjaan (2 Orang)

**Prinsip:** setiap file punya **satu pemilik**, supaya tidak bentrok di Git. File bersama hanya diubah oleh pemiliknya, dan perubahan diinfokan ke partner.

### 9.1 Pembagian tugas

| | **Orang A: Akun dan Data** | **Orang B: Lokasi dan Notifikasi** |
|---|---|---|
| Fokus | Fondasi aplikasi, akun, CRUD, riwayat | GPS, HTTP, form, detail, notifikasi |
| Fitur | F1, F2, F3, F4, F5, F6, F12, F13 | F7, F8, F9, F10, F11 |
| File | `main.dart`, `pubspec.yaml`, `models/*`, `controller/*`, `data/bristol.dart`, `utils/format.dart`, `login_page`, `register_page`, `root_page`, `history_page`, `profile_page`, `entry_card` | `services/*`, `entry_form_page`, `entry_detail_page`, `reminder_page`, konfigurasi Android (`build.gradle.kts`, `AndroidManifest.xml`) |
| Modul utama | 3, 4, 6, 8 | 5, 7 |
| Materi baru | Tidak ada | `url_launcher` |

Orang B memegang bagian dengan konfigurasi paling rewel (notifikasi dan Android), sedangkan Orang A memegang volume layar paling banyak. Bebannya kurang lebih seimbang.

### 9.2 Kontrak antar-orang (sepakati di Fase 0)

Supaya bisa bekerja paralel, tetapkan dulu hal-hal ini:

1. **Model** `AppUser` dan `LogEntry`, persis seperti bagian 6.2.
2. **Nama dan tanda tangan fungsi** `LogController`: `addEntry(LogEntry)`, `updateEntry(LogEntry)`, `deleteEntry(LogEntry)`, `loadEntries()`, `visibleEntries`, `filterDate`.
3. **Fungsi service milik B**: `LocationService.getPosition()`, `GeocodingService.reverse(lat, lng)`, `NotificationService().scheduleNotification(...)`.
4. **Konstruktor halaman**: `EntryFormPage({LogEntry? entry})` dan `EntryDetailPage({required LogEntry entry})`.

Selama halaman partner belum jadi, buat halaman kosong (placeholder) dengan konstruktor yang sudah disepakati.

### 9.3 Jadwal fase

Sesuaikan dengan tanggal presentasi. Hitung mundur dari 2 pertemuan terakhir.

| Fase | Orang A | Orang B | Hasil akhir fase |
|---|---|---|---|
| **0. Bersama** (setengah hari) | Buat project, struktur folder, `pubspec`, model, generate adapter, push ke GitHub | Pelajari `main.dart` dan konfigurasi Android, siapkan tiga service dengan fungsi kosong | Kerangka jalan, kontrak disepakati |
| **1. Fondasi** | Register, login, sesi, logout, root page | `LocationService`, `GeocodingService`, uji lewat tombol percobaan | Bisa login, GPS dan alamat berhasil diuji |
| **2. CRUD** | `LogController`, riwayat, filter tanggal | Form tambah dan edit, detail, tombol Google Maps | CRUD lengkap dengan lokasi |
| **3. Notifikasi dan rapi** | Profil, disclaimer, tampilan, validasi | `NotificationService`, halaman pengingat | Semua fitur wajib selesai |
| **4. Uji dan siap presentasi** | Bersama: uji semua alur, perbaiki bug, README, data demo, latihan presentasi | | Siap demo |

**Aturan penting:** akhir Fase 3 adalah garis batas. Setelah itu **tidak ada fitur baru**, hanya perbaikan dan latihan.

### 9.4 Aturan kerja Git

- Satu branch per fitur, misalnya `feat/auth`, `feat/form-lokasi`, `feat/notifikasi`. Gabungkan ke `main` lewat pull request atau merge setelah dites.
- **Tarik (`git pull`) sebelum mulai kerja**, dan commit kecil serta sering.
- **Commit file `*.g.dart`** hasil generate Hive, supaya orang lain tidak perlu menjalankan `build_runner`.
- Edit `pubspec.yaml` hanya lewat Orang A, edit `AndroidManifest.xml` hanya lewat Orang B. Kalau butuh perubahan, kabari dulu.
- Jangan commit file rahasia atau password asli. Pakai `.gitignore` bawaan Flutter.

---

## 10. Hal Penting Tambahan

### 10.1 Kasus tepi yang harus ditangani

| Situasi | Perilaku yang diharapkan |
|---|---|
| GPS mati | Catatan tetap tersimpan tanpa lokasi, tampilkan SnackBar |
| Izin lokasi ditolak | Sama seperti di atas |
| Internet mati saat ambil alamat | `address` null, tampilkan koordinat |
| Nominatim lambat atau gagal | Jangan menggantung: tampilkan loading lalu lanjut tanpa alamat |
| Username sudah dipakai | Pesan "Username sudah dipakai" |
| Kolom login kosong | Pesan wajib diisi |
| Filter tanggal tanpa hasil | Teks "Belum ada catatan" |
| Hapus saat filter aktif | Catatan yang benar terhapus (itulah alasan memakai `entry.delete()`) |
| Catatan tanpa lokasi | Tombol Google Maps tidak tampil |
| Waktu pengingat sudah lewat | Dijadwalkan untuk besok |
| Dua akun di satu HP | Masing-masing hanya melihat catatannya sendiri |
| Aplikasi ditutup lalu dibuka | Sesi dan data tetap ada |

### 10.2 Privasi

Lokasi saat BAB adalah data yang sensitif. Karena itu:
- Data hanya tersimpan di perangkat (Hive), tidak dikirim ke server kalian.
- Pengguna bisa memilih "catat tanpa lokasi".
- Satu-satunya data yang keluar adalah koordinat ke Nominatim untuk mengambil alamat. Sebutkan ini dengan jujur saat presentasi.

### 10.3 Checklist pengujian manual

- [ ] Register akun baru, lalu login
- [ ] Tutup aplikasi sepenuhnya, buka lagi: masih login
- [ ] Logout: tidak bisa kembali dengan tombol back
- [ ] Tambah catatan dengan lokasi: alamat muncul
- [ ] Tambah catatan dengan GPS dimatikan: tetap tersimpan
- [ ] Tambah catatan dengan opsi tanpa lokasi
- [ ] Edit catatan, lalu detail menampilkan data terbaru
- [ ] Hapus catatan (saat filter aktif juga)
- [ ] Filter tanggal berfungsi dan bisa dihapus
- [ ] Tombol Google Maps membuka lokasi yang benar
- [ ] Notifikasi uji langsung muncul
- [ ] Notifikasi terjadwal muncul (uji beberapa menit ke depan, di HP asli)
- [ ] Dua akun berbeda tidak saling melihat catatan
- [ ] Build release (`flutter build apk --release`) bisa dipakai: Nominatim dan Google Maps butuh izin `INTERNET` dan blok `<queries>`

### 10.4 Persiapan presentasi

Presentasi dilakukan offline di lab. Pastikan ada internet, dan tanya asisten apakah demo boleh pakai HP atau hanya emulator.

**Alur demo (sekitar 5 sampai 7 menit):**
1. Jelaskan tema dan disclaimer (30 detik).
2. Register lalu login.
3. Tambah catatan dengan lokasi: tunjukkan alamat dari Nominatim.
4. Buka riwayat, filter per tanggal.
5. Buka detail, tekan "Lihat di Google Maps".
6. Edit dan hapus satu catatan.
7. Atur pengingat dan tunjukkan notifikasi.
8. Tunjukkan struktur kode dan pemetaan ke modul.

**Siapkan:** satu akun demo dan 8 sampai 10 catatan contoh dengan tanggal berbeda, supaya riwayat dan filter langsung terlihat.

**Pembagian bicara:** Orang A menjelaskan akun, data, dan GetX. Orang B menjelaskan lokasi, HTTP, dan notifikasi. Keduanya paham seluruh alur, karena dosen atau asisten bisa bertanya ke siapa saja.

**Pertanyaan yang mungkin muncul:**
| Pertanyaan | Jawaban singkat |
|---|---|
| Kenapa Hive dan SharedPreferences? | Hive untuk data terstruktur (catatan), SharedPreferences untuk data sederhana (sesi, pengaturan) |
| Kenapa tidak pakai peta di dalam aplikasi? | Fokus pada fitur wajib dan stabilitas. Lokasi tetap tersedia lewat Google Maps |
| Bagian mana yang memakai HTTP? | Reverse geocoding Nominatim, lengkap dengan `jsonDecode` dan penanganan error |
| Bagaimana otorisasi bekerja? | Setiap catatan menyimpan `username` pemiliknya, dan daftar disaring berdasarkan user yang login |
| Apa fungsi `Obx`? | Hanya bagian yang membaca variabel reaktif yang di-render ulang |
| Bagaimana privasi lokasi dijaga? | Data hanya di perangkat, ada opsi tanpa lokasi |

### 10.5 Definition of Done (satu fitur dianggap selesai bila...)

1. Berjalan tanpa error di HP atau emulator.
2. Kasus tepi di tabel 10.1 yang relevan sudah ditangani.
3. Sudah di-merge ke `main` dan bisa dijalankan dari hasil clone yang baru.
4. Pembuatnya bisa menjelaskan kodenya.

### 10.6 README repository

Karena laporan tidak wajib, README jadi satu-satunya dokumentasi. Isi minimal: nama dan deskripsi aplikasi, daftar fitur, anggota dan tugas, cara menjalankan (`flutter pub get`, lalu `dart run build_runner build` jika `*.g.dart` tidak ikut di-commit), dan ringkasan pemetaan ke modul.

---

## 11. Risiko dan Cara Mengatasinya

| Risiko | Dampak | Penanganan |
|---|---|---|
| Notifikasi tidak muncul di HP tertentu | Fitur modul 7 gagal saat demo | Uji dini di HP asli, siapkan tombol notifikasi langsung sebagai cadangan |
| Konfigurasi Android bermasalah | Aplikasi tidak bisa dibuild | Orang B mengerjakannya di Fase 0, bukan di akhir |
| Konflik versi package | Build gagal | Pakai versi persis dari modul, hindari memperbarui sembarangan |
| Hive adapter tidak ter-generate | Aplikasi crash saat start | Commit `*.g.dart`, tulis langkah di README |
| Nominatim lambat atau memblokir | Alamat kosong saat demo | Fallback koordinat, siapkan catatan contoh yang sudah punya alamat |
| Tombol Google Maps tidak membuka | Fitur lokasi tampak rusak | Pastikan blok `<queries>` ada, uji di perangkat demo |
| Fitur terus bertambah | Tidak selesai | Pegang batasan bagian 3, garis batas di akhir Fase 3 |
| Salah satu anggota sakit atau sibuk | Pekerjaan macet | Kontrak antar-orang jelas, kode dibaca bersama di tiap akhir fase |
| Tema sama dengan kelompok lain | Harus ganti tema | Konfirmasi ke asisten sebelum mulai |
| Isi data tidak terhapus saat ganti akun | Data bocor antar akun | Muat ulang `entries` setelah login, kosongkan setelah logout |

---

## 12. Pemetaan Modul ke Kode

| Modul | Materi | Dipakai di |
|---|---|---|
| 2 | Widget dan layout | Semua halaman: `Scaffold`, `AppBar`, `ListView.builder`, `ListTile`, `Card`, `TextField`, `ElevatedButton`, `Column`, `Row`, `SingleChildScrollView` |
| 3 | State, model, controller teks | Login, register, form (`setState`, `TextEditingController`), `LogEntry`, tombol Maps bersyarat |
| 4 | Navigation | `pushReplacement` (login), `push` dan passing data (detail, form), `pop`, `pushAndRemoveUntil` (logout), `BottomNavigationBar` |
| 5 | HTTP | `GeocodingService` (Nominatim) |
| 6 | Local storage | Hive (`users`, `entries`), SharedPreferences (sesi, pengingat) |
| 7 | Notification dan LBS | `NotificationService`, `LocationService`, picker tanggal dan jam, izin lokasi |
| 8 | GetX | `AuthController`, `LogController`, `Obx`, `Get.put`, `Get.find` |

---

## 13. Daftar Hal yang Harus Dicek Sendiri (⚠)

1. Versi terbaru `get` dan `url_launcher` di pub.dev.
2. Format link resmi di dokumentasi **Google Maps URLs**.
3. Bentuk parameter `cancel` di `flutter_local_notifications` sesuai versi yang dipakai.
4. Opsi pengulangan notifikasi (`matchDateTimeComponents`), kalau ingin pengingat harian otomatis.
5. Kebijakan pemakaian **Nominatim** (User-Agent, batas permintaan) dan syarat atribusi OpenStreetMap.
6. Label skala Bristol terhadap referensi yang dipercaya.
7. Apakah asisten menerima navigasi `Navigator` untuk Modul 4 bersama GetX untuk state (bagian 4).
8. Apakah demo boleh memakai HP atau hanya emulator, dan apakah ada internet di lab.
