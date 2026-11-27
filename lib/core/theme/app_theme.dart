import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PROVIA tasarım sistemi: koyu lacivert katmanlı yüzeyler, ince kenarlıklar,
/// turuncu marka/aksiyon rengi, Inter (arayüz) + JetBrains Mono (sayılar).
class ProviaTheme {
  // --- Lacivert yüzeyler ---
  static const Color bgDark = Color(0xFF0A0F1C); // Tuval
  static const Color surfaceDark = Color(0xFF0F1629); // Kartlar
  static const Color surfaceElevated = Color(0xFF162038); // Hover / input
  static const Color borderDark = Color(0xFF1C2740); // İnce kenarlık
  static const Color borderStrong = Color(0xFF2A3A5C);

  // --- Marka ve durum renkleri ---
  static const Color primary = Color(0xFFF97316); // PROVIA Turuncu
  static const Color primaryStrong = Color(0xFFEA580C); // Basılı / koyu ton
  static const Color onPrimary = Color(0xFF0A0F1C); // Turuncu üstü yazı (6.8:1)
  static const Color xp = Color(0xFFFB923C); // XP / seviye
  static const Color accent = Color(0xFF10B981); // Başarı / tamamlandı
  static const Color warning = Color(0xFFFBBF24); // Orta zorluk
  static const Color danger = Color(0xFFEF4444); // Zor / hata
  static const Color info = Color(0xFF38BDF8); // AI / bilgi

  // --- Metin ---
  static const Color textPrimary = Color(0xFFE6EDF7);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textSubtle = Color(0xFF7A8BA8); // >= 4.5:1 lacivertte

  /// Vurgulu kart kenarlığı (Turuncu %40).
  static Color get borderHighlight => primary.withValues(alpha: 0.4);

  static const double radius = 12;

  /// Sayılar, XP, sıra, skor ve URL'ler için monospace yazı stili.
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w600,
    Color color = textPrimary,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: -0.2,
  );

  /// Başlıklar için sıkı harf aralıklı Inter.
  static TextStyle heading({
    double size = 20,
    FontWeight weight = FontWeight.w700,
  }) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: -0.4,
    color: textPrimary,
    height: 1.2,
  );

  static OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    canvasColor: bgDark,
    focusColor: primary.withValues(alpha: 0.22),
    hoverColor: Colors.white.withValues(alpha: 0.03),
    highlightColor: primary.withValues(alpha: 0.08),
    splashColor: primary.withValues(alpha: 0.1),
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surfaceDark,
      error: danger,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary),
    dividerColor: borderDark,
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shape: Border(bottom: BorderSide(color: borderDark)),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceElevated,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: textSubtle, fontSize: 13),
      labelStyle: const TextStyle(color: textMuted, fontSize: 13),
      prefixIconColor: textSubtle,
      suffixIconColor: textSubtle,
      border: _inputBorder(borderDark),
      enabledBorder: _inputBorder(borderDark),
      focusedBorder: _inputBorder(primary, 1.5),
      errorBorder: _inputBorder(danger.withValues(alpha: 0.7)),
      focusedErrorBorder: _inputBorder(danger, 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: primary.withValues(alpha: 0.35),
        disabledForegroundColor: onPrimary.withValues(alpha: 0.7),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 40),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: borderStrong),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 40),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bgDark,
      surfaceTintColor: Colors.transparent,
      height: 64,
      indicatorColor: primary.withValues(alpha: 0.18),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 20,
          color: states.contains(WidgetState.selected)
              ? textPrimary
              : textSubtle,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? textPrimary
              : textSubtle,
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surfaceElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: borderStrong),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: borderDark),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderStrong),
      ),
      textStyle: const TextStyle(color: textPrimary, fontSize: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceElevated,
      contentTextStyle: const TextStyle(color: textPrimary, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: borderStrong),
      ),
    ),
  );
}
