import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F766E);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF1F5F4);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF15803D);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primarySoft = Color(0xFFD7EFEA);
  static const Color dangerSoft = Color(0xFFFDE2E2);
  static const Color successSoft = Color(0xFFD9F2E3);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: primary).copyWith(primary: primary);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Dekorasi kolom input yang konsisten di seluruh aplikasi.
  static InputDecoration input(String label, {String? hint, Widget? suffix, String? prefixText}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
