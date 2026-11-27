import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PROVIA tasarım sistemi: nötr monokrom (zinc) koyu yüzeyler, 1px kılcal
/// kenarlıklar, beyaz birincil aksiyon. Renk yalnızca durum/veri için.
/// Inter (arayüz) + JetBrains Mono (XP, skor, sıra, tarih, URL).
class ProviaTheme {
  // --- Yüzeyler (zinc) ---
  static const Color bgDark = Color(0xFF09090B); // Tuval
  static const Color surfaceDark = Color(0xFF111113); // Yüzey
  static const Color surfaceElevated = Color(0xFF18181B); // Hover / seçili
  static const Color borderDark = Color(0xFF27272A); // Kılcal kenarlık
  static const Color borderStrong = Color(0xFF3F3F46); // Hover kenarlık

  // --- Birincil aksiyon: beyaz zemin + siyah yazı ---
  static const Color primary = Color(0xFFFAFAFA);
  static const Color primaryStrong = Color(0xFFE4E4E7);
  static const Color onPrimary = Color(0xFF09090B);

  // --- Sinyal renkleri (yalnızca durum ve veri) ---
  static const Color accent = Color(0xFF10B981); // Doğrulandı / tamamlandı
  static const Color warning = Color(0xFFF59E0B); // Devam ediyor / uyarı
  static const Color danger = Color(0xFFEF4444); // Zor / acil
  static const Color xp = Color(0xFFF59E0B); // XP verisi
  static const Color info = Color(0xFFA1A1AA); // Nötr bilgi

  // --- Metin ---
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textMuted = Color(0xFFA1A1AA);

  /// #71717A tuvalde 4.1:1 kalıyor; 4.5:1 için bir ton açıldı.
  static const Color textSubtle = Color(0xFF82828C);

  /// Vurgulu kenarlık: parlama yok, sadece bir ton daha açık çizgi.
  static Color get borderHighlight => borderStrong;

  static const double radius = 8; // Kart / buton
  static const double radiusSmall = 6; // Input / etiket

  /// Sayılar, XP, sıra, skor, tarih ve URL'ler için monospace.
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = textPrimary,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: -0.2,
  );

  /// Sayfa ve bölüm başlıkları: sıkı harf aralığı, w600.
  static TextStyle heading({
    double size = 20,
    FontWeight weight = FontWeight.w600,
  }) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: size >= 20 ? -0.5 : -0.2,
    color: textPrimary,
    height: 1.25,
  );

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(radiusSmall),
    borderSide: BorderSide(color: color),
  );

  static final ButtonStyle _compact = ButtonStyle(
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.1),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    elevation: const WidgetStatePropertyAll(0),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    canvasColor: bgDark,
    focusColor: Colors.white.withValues(alpha: 0.12),
    hoverColor: Colors.white.withValues(alpha: 0.04),
    highlightColor: Colors.white.withValues(alpha: 0.06),
    splashFactory: NoSplash.splashFactory,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      secondary: textMuted,
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
        side: const BorderSide(color: borderDark),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 52,
      shape: Border(bottom: BorderSide(color: borderDark)),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: const TextStyle(color: textSubtle, fontSize: 13),
      labelStyle: const TextStyle(color: textMuted, fontSize: 13),
      floatingLabelStyle: const TextStyle(color: textPrimary, fontSize: 13),
      prefixIconColor: textSubtle,
      suffixIconColor: textSubtle,
      border: _inputBorder(borderDark),
      enabledBorder: _inputBorder(borderDark),
      focusedBorder: _inputBorder(const Color(0xFF71717A)),
      errorBorder: _inputBorder(danger.withValues(alpha: 0.6)),
      focusedErrorBorder: _inputBorder(danger),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _compact.merge(
        ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: primary.withValues(alpha: 0.3),
          disabledForegroundColor: onPrimary.withValues(alpha: 0.6),
          shadowColor: Colors.transparent,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _compact.merge(
        OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: borderDark),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 32),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bgDark,
      surfaceTintColor: Colors.transparent,
      height: 60,
      elevation: 0,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 20,
          color: states.contains(WidgetState.selected)
              ? textPrimary
              : const Color(0xFF71717A),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? textPrimary
              : textSubtle,
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: borderDark),
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
        borderRadius: BorderRadius.circular(radiusSmall),
        border: Border.all(color: borderDark),
      ),
      textStyle: const TextStyle(color: textPrimary, fontSize: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceElevated,
      contentTextStyle: const TextStyle(color: textPrimary, fontSize: 13),
      actionTextColor: textPrimary,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: borderDark),
      ),
    ),
  );
}
