import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controller/auth_controller.dart';
import 'controller/log_controller.dart';
import 'models/app_user.dart';
import 'models/log_entry.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
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
      title: 'Leega',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: loggedIn ? const RootPage() : const LoginPage(),
    );
  }
}
