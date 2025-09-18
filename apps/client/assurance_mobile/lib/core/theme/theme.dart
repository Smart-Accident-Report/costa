import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Based on Lumi brand colors
  static const Color primaryColor =
      Color(0xFF00D084); // Vibrant green from Lumi
  static const Color secondaryColor = Color(0xFF00B872); // Darker green variant
  static const Color accentColor = Color(0xFF1A1A1A); // Deep dark background

  // Background Colors
  static const Color backgroundColor =
      Color(0xFF0F1419); // Dark teal background
  static const Color surfaceColor = Color(0xFF1E2A32); // Dark surface
  static const Color cardColor = Color(0xFF253339); // Slightly lighter cards

  // Text Colors - Modern and clean
  static const Color primaryTextColor = Color(0xFFFFFFFF); // Pure white text
  static const Color secondaryTextColor = Color(0xFFE0E6ED); // Light gray
  static const Color hintTextColor = Color(0xFF8A9BA8); // Medium gray hints

  // Interactive Colors
  static const Color buttonColor = Color(0xFF00D084); // Lumi green for buttons
  static const Color selectedColor = Color(0xFF00D084); // Green selection
  static const Color borderColor = Color(0xFF3A4A52); // Subtle dark borders

  // Status Colors
  static const Color successColor = Color(0xFF00D084); // Green success
  static const Color errorColor = Color(0xFFFF4757); // Red error
  static const Color warningColor = Color(0xFFFFB142); // Orange warning
  static const Color infoColor = Color(0xFF2ED5D9); // Cyan info

  // Reading-focused Colors
  static const Color readingBackgroundColor =
      Color(0xFF0F1419); // Dark reading background
  static const Color highlightColor = Color(0xFF00D084); // Green highlight
  static const Color bookmarkColor = Color(0xFF00D084); // Green bookmark

  // Social Colors
  static const Color googleColor = Color(0xFF4285F4);
  static const Color facebookColor = Color(0xFF1877F2);

  // Transparent Colors
  static const Color overlayColor = Color(0x80000000);
  static const Color shimmerColor = Color(0xFF2A3A42);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark, // Using dark theme as primary based on image
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: primaryTextColor,
        onBackground: primaryTextColor,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textTheme: TextTheme(
        // Display styles - For major headings
        displayLarge: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.8,
        ),
        displaySmall: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.6,
        ),

        // Headline styles - For section headings
        headlineLarge: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.4,
        ),
        headlineSmall: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.3,
        ),

        // Title styles - For UI elements
        titleLarge: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.1,
        ),
        titleSmall: GoogleFonts.inter(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
        ),

        // Body styles - For reading content
        bodyLarge: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: -0.1,
        ),
        bodyMedium: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0,
        ),
        bodySmall: GoogleFonts.inter(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0,
        ),

        // Label styles - For buttons and small UI elements
        labelLarge: GoogleFonts.inter(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        labelSmall: GoogleFonts.inter(
          color: hintTextColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: hintTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Alternative light theme for better readability in bright conditions
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF000000), // Pure black for OLED
      cardColor: const Color(0xFF1A1A1A),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color(0xFF1A1A1A),
        background: const Color(0xFF000000),
        error: errorColor,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.8,
        ),
        displaySmall: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.6,
        ),
        headlineLarge: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.4,
        ),
        headlineSmall: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.1,
        ),
        titleSmall: GoogleFonts.inter(
          color: const Color(0xFFB0B0B0),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
        ),
        bodyLarge: GoogleFonts.inter(
          color: const Color(0xFFE0E0E0),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: -0.1,
        ),
        bodyMedium: GoogleFonts.inter(
          color: const Color(0xFFE0E0E0),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0,
        ),
        bodySmall: GoogleFonts.inter(
          color: const Color(0xFFB0B0B0),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0,
        ),
        labelLarge: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          color: const Color(0xFFB0B0B0),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        labelSmall: GoogleFonts.inter(
          color: const Color(0xFF666666),
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
