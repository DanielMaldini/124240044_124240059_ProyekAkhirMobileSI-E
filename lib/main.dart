import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controller/auth_controller.dart';
import 'controller/log_controller.dart';
import 'models/app_user.dart';
import 'models/log_entry.dart';
import 'services/notification_service.dart';
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
    const primaryGreen = Color(0xFF718B73);
    const creamBg = Color(0xFFF8F7F2);
    const warmOffWhite = Color(0xFFE8EEE5);
    const darkCharcoal = Color(0xFF303A32);

    return GetMaterialApp(
      title: 'Leega',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: creamBg,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: darkCharcoal,
          displayColor: darkCharcoal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: warmOffWhite,
        ),
      ),
      home: loggedIn ? const RootPage() : const LoginPage(),
    );
  }
}
