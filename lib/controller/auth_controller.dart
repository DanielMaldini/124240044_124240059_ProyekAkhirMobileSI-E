import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import 'log_controller.dart';

class AuthController extends GetxController {
  final Box<AppUser> _usersBox = Hive.box<AppUser>('users');
  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  /// Mengembalikan pesan error, atau null jika berhasil.
  String? register(String username, String password, String name) {
    final u = username.trim();
    final p = password.trim();
    final n = name.trim();

    if (u.isEmpty || p.isEmpty || n.isEmpty) {
      return 'Semua kolom wajib diisi';
    }
    if (_usersBox.containsKey(u)) {
      return 'Username sudah dipakai';
    }

    _usersBox.put(u, AppUser(username: u, password: p, name: n));
    return null;
  }

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> login(String username, String password) async {
    final u = username.trim();
    final p = password.trim();

    if (u.isEmpty || p.isEmpty) {
      return 'Username dan password wajib diisi';
    }

    final user = _usersBox.get(u);
    if (user == null || user.password != p) {
      return 'Username atau password salah';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionUser', u);
    currentUser.value = user;
    return null;
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('sessionUser');
    if (username == null) return false;

    currentUser.value = _usersBox.get(username);
    return currentUser.value != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionUser');
    currentUser.value = null;
    Get.find<LogController>().entries.clear();
  }
}
