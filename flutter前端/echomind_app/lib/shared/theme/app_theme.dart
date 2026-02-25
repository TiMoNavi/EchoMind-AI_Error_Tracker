import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Claymorphism Color Palette ("Candy Shop") ───
  static const Color canvas = Color(0xFFF4F1FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF332F3A);
  static const Color muted = Color(0xFF635F69);

  // Accents
  static const Color accent = Color(0xFF7C3AED);       // Vivid Violet
  static const Color accentAlt = Color(0xFFDB2777);     // Hot Pink
  static const Color accentLight = Color(0xFFA78BFA);   // Light Violet
  static const Color tertiary = Color(0xFF0EA5E9);      // Sky Blue
  static const Color success = Color(0xFF10B981);       // Emerald
  static const Color warning = Color(0xFFF59E0B);       // Amber
  static const Color danger = Color(0xFFEF4444);        // Red

  // Legacy aliases (so other pages don't break)
  static const Color primary = accent;
  static const Color background = canvas;
  static const Color surface = cardBg;
  static const Color textPrimary = foreground;
  static const Color textSecondary = muted;
  static const Color divider = Color(0xFFE5E5EA);

  // ─── Spacing ───
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;

  // ─── Claymorphism Radii (Super-Rounded) ───
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusCard = 32;
  static const double radiusHero = 48;

  // ─── Claymorphism Shadow Stacks ───
  static List<BoxShadow> get shadowClayCard => [
    const BoxShadow(
      offset: Offset(16, 16),
      blurRadius: 32,
      color: Color.fromRGBO(160, 150, 180, 0.2),
    ),
    const BoxShadow(
      offset: Offset(-10, -10),
      blurRadius: 24,
      color: Color.fromRGBO(255, 255, 255, 0.9),
    ),
  ];

  static List<BoxShadow> get shadowClayButton => [
    const BoxShadow(
      offset: Offset(12, 12),
      blurRadius: 24,
      color: Color.fromRGBO(139, 92, 246, 0.3),
    ),
    const BoxShadow(
      offset: Offset(-8, -8),
      blurRadius: 16,
      color: Color.fromRGBO(255, 255, 255, 0.4),
    ),
  ];

  static List<BoxShadow> get shadowClayPressed => [
    const BoxShadow(
      offset: Offset(6, 6),
      blurRadius: 12,
      color: Color(0xFFD9D4E3),
    ),
    const BoxShadow(
      offset: Offset(-6, -6),
      blurRadius: 12,
      color: Color(0xFFFFFFFF),
    ),
  ];

  static List<BoxShadow> get shadowClayStatOrb => [
    const BoxShadow(
      offset: Offset(8, 8),
      blurRadius: 20,
      color: Color.fromRGBO(139, 92, 246, 0.15),
    ),
    const BoxShadow(
      offset: Offset(-6, -6),
      blurRadius: 16,
      color: Color.fromRGBO(255, 255, 255, 0.8),
    ),
  ];

  // ─── Gradients ───
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
  );

  static const LinearGradient gradientPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
  );

  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
  );

  static const LinearGradient gradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
  );

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
  );

  // ─── Typography Helpers ───
  static TextStyle heading({double size = 28, FontWeight weight = FontWeight.w800}) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: foreground,
      height: 1.1,
    );
  }

  static TextStyle body({double size = 16, FontWeight weight = FontWeight.w500, Color color = foreground}) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle label({double size = 12, Color color = muted}) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.5,
    );
  }

  // ─── Theme Data ───
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: accent,
    scaffoldBackgroundColor: canvas,
    colorScheme: const ColorScheme.light(
      primary: accent,
      secondary: accentAlt,
      surface: cardBg,
      error: danger,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: foreground,
      elevation: 0,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: foreground,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCard),
      ),
    ),
  );
}
