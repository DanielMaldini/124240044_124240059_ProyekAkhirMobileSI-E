import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/log_controller.dart';
import '../../services/notification_service.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [HomePage(), HistoryPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();

    // Arahkan ke tab Home (indeks 0) saat user men-tap notifikasi kesehatan
    NotificationService().onOpenHomeTab = () {
      if (mounted) {
        setState(() => _selectedIndex = 0);
      }
    };

    // Cek pola catatan BAB setelah frame pertama selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<LogController>()) {
        final logController = Get.find<LogController>();
        final dates = logController.entries.map((e) => e.dateTime).toList();
        NotificationService().checkDigestivePattern(dates);
      }
    });
  }

  @override
  void dispose() {
    NotificationService().onOpenHomeTab = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF4F775A),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
