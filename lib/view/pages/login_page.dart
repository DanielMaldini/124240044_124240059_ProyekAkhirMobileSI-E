import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/log_controller.dart';
import '../../utils/app_theme.dart';
import 'register_page.dart';
import 'root_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final auth = Get.find<AuthController>();
    final error = await auth.login(
      _usernameController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.red),
      );
      return;
    }

    Get.find<LogController>().loadEntries();
    ScaffoldMessenger.of(context).clearSnackBars();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RootPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Login Leega',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Catat kondisi, waktu, dan lokasi rutinitas pencernaanmu.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.inkSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _onLogin,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Belum punya akun? Daftar di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
