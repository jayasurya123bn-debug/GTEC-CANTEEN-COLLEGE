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
      cardTheme: const CardTheme(
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
  }
}
