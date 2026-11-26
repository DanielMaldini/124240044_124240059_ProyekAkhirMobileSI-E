import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../utils/app_theme.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  final user = auth.currentUser.value;
                  final displayName = user?.name ?? '-';
                  final initial = displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : '?';
                  return Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${user?.username ?? '-'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.subtleBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Pengingat Harian',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
                subtitle: const Text(
                  'Atur jam notifikasi pengingat',
                  style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.inkMuted,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderPage()),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.subtleBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.inkSecondary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Leega bukan alat diagnosis medis. Jika ada darah pada '
                      'tinja, nyeri berkepanjangan, atau keluhan lain, '
                      'konsultasikan ke dokter.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, size: 18, color: AppColors.red),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFECACA)),
                backgroundColor: AppColors.redSoft,
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
