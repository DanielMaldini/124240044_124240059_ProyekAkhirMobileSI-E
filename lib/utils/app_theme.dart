import 'package:flutter/material.dart';

/// Palet warna minimalis modern Leega:
/// Dominan putih & hitam pekat, dengan warna status fungsional yang lembut.
class AppColors {
  static const Color canvas = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF111827);
  static const Color inkSecondary = Color(0xFF6B7280);
  static const Color inkMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color subtleBg = Color(0xFFF3F4F6);

  // Warna status fungsional
  static const Color green = Color(0xFF15803D);
  static const Color greenSoft = Color(0xFFECFDF5);
  static const Color amber = Color(0xFFB45309);
  static const Color amberSoft = Color(0xFFFFFBEB);
  static const Color orange = Color(0xFFC2410C);
  static const Color orangeSoft = Color(0xFFFFF7ED);
  static const Color red = Color(0xFFDC2626);
  static const Color redSoft = Color(0xFFFEF2F2);
}

class BowelConditionOption {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const BowelConditionOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class BowelConditions {
  static const String normal = 'Normal';
  static const String hard = 'Keras / Susah';
  static const String soft = 'Lembek';
  static const String watery = 'Cair / Diare';

  static const List<BowelConditionOption> all = [
    BowelConditionOption(
      label: normal,
      subtitle: 'Lancar & nyaman',
      icon: Icons.check_circle_outline,
      color: AppColors.green,
      bgColor: AppColors.greenSoft,
    ),
    BowelConditionOption(
      label: hard,
      subtitle: 'Keras / perlu mengejan',
      icon: Icons.warning_amber_rounded,
      color: AppColors.amber,
      bgColor: AppColors.amberSoft,
    ),
    BowelConditionOption(
      label: soft,
      subtitle: 'Lebih lunak dari biasa',
      icon: Icons.water_drop_outlined,
      color: AppColors.orange,
      bgColor: AppColors.orangeSoft,
    ),
    BowelConditionOption(
      label: watery,
      subtitle: 'Encer / berair',
      icon: Icons.error_outline,
      color: AppColors.red,
      bgColor: AppColors.redSoft,
    ),
  ];

  static const List<String> symptomOptions = [
    'Kembung',
    'Mulas',
    'Tidak Tuntas',
  ];

  static BowelConditionOption? fromLabel(String? label) {
    if (label == null || label.isEmpty) return null;
    for (final item in all) {
      if (item.label == label) return item;
    }
    return null;
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.ink,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.red,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      shape: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border, width: 1.2),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.ink,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.ink,
      unselectedItemColor: AppColors.inkMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.inkSecondary),
      hintStyle: const TextStyle(color: AppColors.inkMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.ink;
        return AppColors.border;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
