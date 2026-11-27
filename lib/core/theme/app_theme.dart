import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviaTheme {
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131A2A);
  static const Color borderDark = Color(0xFF1F293D);
  static const Color primary = Color(0xFF6366F1); // PROVIA Indigo
  static const Color accent = Color(0xFF10B981); // XP / Başarı Yeşili
  static const Color warning = Color(0xFFF59E0B); // Teslim / Zorluk Sarısı
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surfaceDark,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
  );
}
