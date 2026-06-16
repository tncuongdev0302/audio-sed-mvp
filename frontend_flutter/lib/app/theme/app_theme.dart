import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors from design.pen variables
  static const Color brandPrimary = Color(0xFF1250DC);
  static const Color brandPrimaryLight = Color(0xFFEAEFFA);
  static const Color textPrimary = Color(0xFF020B27);
  static const Color textSecondary = Color(0xFF4A4F63);
  static const Color textTertiary = Color(0xFFA9B2BE);
  static const Color bgBase = Color(0xFFF6F7F9);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE4E8ED);
  static const Color successColor = Color(0xFF51B848);
  static const Color warningColor = Color(0xFFFA8C16);
  static const Color errorColor = Color(0xFFF04438);

  // Legacy names mapped to design.pen tokens for backward compatibility
  static const Color primaryBlue = brandPrimary;
  static const Color primaryBlueDark = Color(0xFF002C9A); // Updated to match Figma darker blue
  static const Color primaryBlueLight = brandPrimaryLight;
  static const Color navyText = Color(0xFF020B27); // Updated to textPrimary navy color

  static const Color accentOrange = warningColor;
  static const Color accentOrangeHover = Color(0xFFE2783A); // Updated to Figma secondary orange
  static const Color accentOrangeLight = Color(0xFFFFF5F0);

  static const Color accentGreen = successColor;
  static const Color accentGreenLight = Color(0xFFE9FBF2); // Updated to match alert green light background

  static const Color textDark = textPrimary;
  static const Color textMuted = textTertiary;
  static const Color bgBody = bgBase;

  // Light Color Scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: brandPrimary,
    onPrimary: Colors.white,
    primaryContainer: brandPrimaryLight,
    onPrimaryContainer: textPrimary,
    secondary: warningColor,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFF5F0),
    onSecondaryContainer: warningColor,
    tertiary: successColor,
    onTertiary: Colors.white,
    error: errorColor,
    onError: Colors.white,
    surface: bgSurface,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    outline: borderColor,
    shadow: Color(0x0F02509B),
  );

  // Dark Color Scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF38BDF8), // Light blue for dark mode
    onPrimary: Color(0xFF090D16),
    primaryContainer: Color(0xFF1E293B),
    onPrimaryContainer: Color(0xFFF8FAFC),
    secondary: Color(0xFFFB923C), // Orange gold
    onSecondary: Color(0xFF090D16),
    secondaryContainer: Color(0xFF1B263F),
    onSecondaryContainer: Color(0xFFFFF5F0),
    tertiary: Color(0xFF10B981), // Teal
    onTertiary: Color(0xFF090D16),
    error: errorColor,
    onError: Colors.white,
    surface: Color(0xFF131C2E), // Premium Card
    onSurface: Color(0xFFF8FAFC),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFF1E293B),
    shadow: Colors.black54,
  );
}

class AppTheme {
  static TextTheme _scaleTextTheme(TextTheme base, {double scale = 1.1}) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: (base.displayLarge?.fontSize ?? 57) * scale),
      displayMedium: base.displayMedium?.copyWith(fontSize: (base.displayMedium?.fontSize ?? 45) * scale),
      displaySmall: base.displaySmall?.copyWith(fontSize: (base.displaySmall?.fontSize ?? 36) * scale),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: (base.headlineLarge?.fontSize ?? 32) * scale),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: (base.headlineMedium?.fontSize ?? 28) * scale),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: (base.headlineSmall?.fontSize ?? 24) * scale),
      titleLarge: base.titleLarge?.copyWith(fontSize: (base.titleLarge?.fontSize ?? 22) * scale),
      titleMedium: base.titleMedium?.copyWith(fontSize: (base.titleMedium?.fontSize ?? 16) * scale),
      titleSmall: base.titleSmall?.copyWith(fontSize: (base.titleSmall?.fontSize ?? 14) * scale),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: (base.bodyLarge?.fontSize ?? 16) * scale),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: (base.bodyMedium?.fontSize ?? 14) * scale),
      bodySmall: base.bodySmall?.copyWith(fontSize: (base.bodySmall?.fontSize ?? 12) * scale),
      labelLarge: base.labelLarge?.copyWith(fontSize: (base.labelLarge?.fontSize ?? 14) * scale),
      labelMedium: base.labelMedium?.copyWith(fontSize: (base.labelMedium?.fontSize ?? 12) * scale),
      labelSmall: base.labelSmall?.copyWith(fontSize: (base.labelSmall?.fontSize ?? 11) * scale),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    final scaledTextTheme = _scaleTextTheme(baseTextTheme);
    
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.bgBody,
      textTheme: scaledTextTheme.copyWith(
        titleLarge: scaledTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        titleMedium: scaledTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: scaledTextTheme.bodyLarge?.copyWith(color: AppColors.textDark),
        bodyMedium: scaledTextTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final scaledTextTheme = _scaleTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF020617),
      textTheme: scaledTextTheme.copyWith(
        titleLarge: scaledTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        titleMedium: scaledTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: scaledTextTheme.bodyLarge?.copyWith(color: const Color(0xFFF1F5F9)),
        bodyMedium: scaledTextTheme.bodyMedium?.copyWith(color: const Color(0xFF94A3B8)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFFF1F5F9),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF1F5F9),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF131C2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: Color(0xFF1E293B)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF38BDF8),
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
