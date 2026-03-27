import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';

/// AppTheme - Uygulama tema yönetimi
/// Renk, tipografi ve spacing yalnızca bu dosya ve SizeTokens üzerinden yönetilir.
/// View içinde inline stil minimum tutulur.
class AppTheme {
  AppTheme._();

  // ─── RENKLER ────────────────────────────────────────────
  static const Color primary = Color(0xFF231F20); // Dark Gray / Black
  static const Color accent = Color(0xFFFFCE00);  // Yellow / Gold
  static const Color primaryContainer = Color(0xFF332D2F);
  static const Color secondary = Color(0xFFFFCE00);
  static const Color secondaryContainer = Color(0xFFFFF4CC);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // ─── TEXT RENKLERI ─────────────────────────────────────
  static const Color textPrimary = Color(0xFF231F20);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF231F20);

  // ─── BORDER / DIVIDER ─────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ─── STATUS RENKLERI ──────────────────────────────────
  static const Color statusStokta = Color(0xFF22C55E);
  static const Color statusSatildi = Color(0xFF2E7DFF);

  // ─── SHADOW ───────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: SizeTokens.spacingMd,
          offset: Offset(0, SizeTokens.spacingXs),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: SizeTokens.spacingXxl,
          offset: Offset(0, SizeTokens.spacingSm),
        ),
      ];

  // ─── THEME DATA ───────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: textOnPrimary,
        onSecondary: textOnAccent,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _titleMedium,
        scrolledUnderElevation: 0.5,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: _labelSmall,
        unselectedLabelStyle: _labelSmall,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          side: BorderSide(color: border, width: SizeTokens.borderThin),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textOnAccent,
          minimumSize: Size(double.infinity, SizeTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          ),
          textStyle: _labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: Size(double.infinity, SizeTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          ),
          side: BorderSide(color: border, width: SizeTokens.borderThin),
          textStyle: _labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingLg,
          vertical: SizeTokens.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          borderSide: BorderSide(color: border, width: SizeTokens.borderThin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          borderSide: BorderSide(color: border, width: SizeTokens.borderThin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          borderSide: BorderSide(color: accent, width: SizeTokens.borderMedium),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          borderSide: BorderSide(color: error, width: SizeTokens.borderThin),
        ),
        hintStyle: _bodyMedium.copyWith(color: textTertiary),
        labelStyle: _bodyMedium.copyWith(color: textSecondary),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: SizeTokens.borderThin,
        space: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: _headlineLarge,
        headlineMedium: _headlineMedium,
        headlineSmall: _headlineSmall,
        titleLarge: _titleLarge,
        titleMedium: _titleMedium,
        titleSmall: _titleSmall,
        bodyLarge: _bodyLarge,
        bodyMedium: _bodyMedium,
        bodySmall: _bodySmall,
        labelLarge: _labelLarge,
        labelMedium: _labelMedium,
        labelSmall: _labelSmall,
      ),
    );
  }

  // ─── TEXT STYLES ──────────────────────────────────────
  static TextStyle get _headlineLarge => GoogleFonts.inter(
        fontSize: SizeTokens.font4xl,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get _headlineMedium => GoogleFonts.inter(
        fontSize: SizeTokens.font3xl,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get _headlineSmall => GoogleFonts.inter(
        fontSize: SizeTokens.fontXxl,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get _titleLarge => GoogleFonts.inter(
        fontSize: SizeTokens.fontXl,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get _titleMedium => GoogleFonts.inter(
        fontSize: SizeTokens.fontLg,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get _titleSmall => GoogleFonts.inter(
        fontSize: SizeTokens.fontMd,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get _bodyLarge => GoogleFonts.inter(
        fontSize: SizeTokens.fontMd,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get _bodyMedium => GoogleFonts.inter(
        fontSize: SizeTokens.fontSm,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get _bodySmall => GoogleFonts.inter(
        fontSize: SizeTokens.fontXs,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.5,
      );

  static TextStyle get _labelLarge => GoogleFonts.inter(
        fontSize: SizeTokens.fontMd,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get _labelMedium => GoogleFonts.inter(
        fontSize: SizeTokens.fontSm,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get _labelSmall => GoogleFonts.inter(
        fontSize: SizeTokens.fontXs,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.4,
      );
}
