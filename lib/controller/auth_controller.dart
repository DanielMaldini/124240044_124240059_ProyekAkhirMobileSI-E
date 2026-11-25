import 'package:get/get.dart';
import '../models/app_user.dart';

class AuthController extends GetxController {
  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  String? register(String username, String password, String name) {
    // TODO: Implementasi di Tahap 1
    return null;
  }

  Future<String?> login(String username, String password) async {
    // TODO: Implementasi di Tahap 1
    return null;
  }

  Future<bool> restoreSession() async {
    // TODO: Implementasi di Tahap 1
    return false;
  }

  Future<void> logout() async {
    // TODO: Implementasi di Tahap 1
  }
}
