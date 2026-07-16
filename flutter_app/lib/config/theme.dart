import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────────────────
  static const Color background     = Color(0xFF0D1117);
  static const Color card           = Color(0xFF161B22);
  static const Color elevated       = Color(0xFF1C2333);
  static const Color inputFill      = Color(0xFF21262D);
  static const Color border         = Color(0xFF30363D);
  static const Color muted          = Color(0xFF484F58);
  static const Color bodyText       = Color(0xFF8B949E);
  static const Color white          = Color(0xFFFFFFFF);
  static const Color primaryGreen   = Color(0xFF00E676);
  static const Color amber          = Color(0xFFFFB300);
  static const Color limited        = Color(0xFFFFB74D);
  static const Color soldOut        = Color(0xFFFF5252);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryGreen,
      cardColor: card,
      dividerColor: border,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        surface: card,
        background: background,
        onBackground: white,
        onSurface: white,
        onPrimary: background,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
        displayLarge:  TextStyle(color: white,    fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: white,    fontWeight: FontWeight.w700),
        displaySmall:  TextStyle(color: white,    fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: white,    fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: white,    fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: white,    fontWeight: FontWeight.w600),
        titleLarge:    TextStyle(color: white,    fontWeight: FontWeight.w600),
        titleMedium:   TextStyle(color: white,    fontWeight: FontWeight.w500),
        titleSmall:    TextStyle(color: bodyText, fontWeight: FontWeight.w500),
        bodyLarge:     TextStyle(color: white),
        bodyMedium:    TextStyle(color: bodyText),
        bodySmall:     TextStyle(color: muted),
        labelLarge:    TextStyle(color: white,    fontWeight: FontWeight.w600),
        labelMedium:   TextStyle(color: bodyText),
        labelSmall:    TextStyle(color: muted),
      )),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: white),
        titleTextStyle: GoogleFonts.poppins(
          color: white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primaryGreen,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: inputFill,
        labelStyle: GoogleFonts.poppins(color: bodyText, fontSize: 12),
        side: const BorderSide(color: border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: GoogleFonts.poppins(color: muted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: soldOut,
          side: const BorderSide(color: soldOut, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  static ThemeData get lightTheme {
    const Color lightBg = Color(0xFFF8F9FA);
    const Color lightCard = Color(0xFFFFFFFF);
    const Color lightElevated = Color(0xFFF1F3F5);
    const Color lightInputFill = Color(0xFFE9ECEF);
    const Color lightBorder = Color(0xFFDEE2E6);
    const Color lightMuted = Color(0xFF868E96);
    const Color lightBodyText = Color(0xFF495057);
    const Color lightText = Color(0xFF212529);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: primaryGreen,
      cardColor: lightCard,
      dividerColor: lightBorder,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        surface: lightCard,
        background: lightBg,
        onBackground: lightText,
        onSurface: lightText,
        onPrimary: white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
        displayLarge:  TextStyle(color: lightText,    fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: lightText,    fontWeight: FontWeight.w700),
        displaySmall:  TextStyle(color: lightText,    fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: lightText,    fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: lightText,    fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: lightText,    fontWeight: FontWeight.w600),
        titleLarge:    TextStyle(color: lightText,    fontWeight: FontWeight.w600),
        titleMedium:   TextStyle(color: lightText,    fontWeight: FontWeight.w500),
        titleSmall:    TextStyle(color: lightBodyText, fontWeight: FontWeight.w500),
        bodyLarge:     TextStyle(color: lightText),
        bodyMedium:    TextStyle(color: lightBodyText),
        bodySmall:     TextStyle(color: lightMuted),
        labelLarge:    TextStyle(color: lightText,    fontWeight: FontWeight.w600),
        labelMedium:   TextStyle(color: lightBodyText),
        labelSmall:    TextStyle(color: lightMuted),
      )),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightText),
        titleTextStyle: GoogleFonts.poppins(
          color: lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: lightBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCard,
        selectedItemColor: primaryGreen,
        unselectedItemColor: lightMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightInputFill,
        labelStyle: GoogleFonts.poppins(color: lightBodyText, fontSize: 12),
        side: const BorderSide(color: lightBorder),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightInputFill,
        hintStyle: GoogleFonts.poppins(color: lightMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: soldOut,
          side: const BorderSide(color: soldOut, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
