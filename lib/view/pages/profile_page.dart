import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import 'login_page.dart';
import 'reminder_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_circle,
              size: 88,
              color: Color(0xFF718B73),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final user = auth.currentUser.value;
              return Column(
                children: [
                  Text(
                    user?.name ?? '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user?.username ?? '-'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF718B73),
                ),
                title: const Text(
                  'Pengingat Harian',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Atur jam notifikasi pengingat'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderPage()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Color(0xFF718B73),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Leega bukan alat diagnosis medis. Jika ada darah pada '
                        'tinja, nyeri berkepanjangan, atau keluhan lain, '
                        'konsultasikan ke dokter.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
