import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color secondary = Color(0xFFFF8F00);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color teal = Color(0xFF00897B);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surfaceColor = Colors.white;
  static const Color textDark = Color(0xFF263238);
  static const Color textMedium = Color(0xFF546E7A);
  static const Color textLight = Color(0xFF90A4AE);

  static const TextStyle heading1 = TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle heading2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle heading3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textDark);
  static const TextStyle heading4 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);
  static const TextStyle bodyMedium = TextStyle(fontSize: 15, color: textMedium);
  static const TextStyle bodySmall = TextStyle(fontSize: 13, color: textLight);

  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8));
  static const BoxShadow shadowMd = BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4));
  static const BoxShadow shadowSm = BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2));

  static InputDecoration inputDecoration({required String label, Widget? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefix,
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(borderRadius: radiusMd, borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: false,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
    ),
  );
}