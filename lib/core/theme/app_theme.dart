import 'package:flutter/material.dart';

/// CourseMate design tokens — black & cyan glassmorphism palette.
/// All authenticated screens should use these constants or derive from
/// Theme.of(context) which is configured here.
class AppTheme {
  // ── Cyan accent ────────────────────────────────────────────────────────────
  static const Color cyanPrimary   = Color(0xFF20DDF5);
  static const Color cyanSecondary = Color(0xFF168FE5);

  // ── Dark (authenticated) palette ───────────────────────────────────────────
  static const Color darkBgMain      = Color(0xFF050A0D); // page background
  static const Color darkBgSecondary = Color(0xFF071318); // section surfaces
  static const Color darkCardBg      = Color(0xFF0B171D); // cards / panels
  static const Color darkSurface     = Color(0xFF0D1E27); // elevated surfaces
  static const Color darkInputBg     = Color(0xFF0F1E26); // text field fill

  static const Color darkTextPrimary   = Color(0xFFF4F7FA);
  static const Color darkTextSecondary = Color(0xFF9BAAB7);
  static const Color darkTextHint      = Color(0xFF5A6A76);

  static const Color darkBorderCyan  = Color(0x2820DDF5); // thin low-opacity
  static const Color darkBorderSubtle= Color(0x14FFFFFF); // very subtle white

  // ── Light palette (fallback — app defaults to dark) ────────────────────────
  static const Color lightBg        = Color(0xFFF0F4F8);
  static const Color lightCardBg    = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0D1B22);
  static const Color lightTextSecondary = Color(0xFF4A6072);
  static const Color lightBorder    = Color(0xFFD0DAE3);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ── Kept for backward compat — some screens reference these ───────────────
  /// @deprecated use [cyanPrimary] instead
  static const Color primaryPurple  = cyanPrimary;
  /// @deprecated use [cyanSecondary] instead
  static const Color accentCyan     = cyanSecondary;

  // Old aliases used in auth / onboarding screens — left pointing at cyan so
  // those screens stay consistent without a rewrite.
  static const Color darkScaffoldBg = darkBgMain;
  static const Color darkInputBgOld = darkInputBg;

  // ── Dark ThemeData ─────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBgMain,
      primaryColor: cyanPrimary,
      colorScheme: const ColorScheme.dark(
        primary: cyanPrimary,
        secondary: cyanSecondary,
        surface: darkSurface,
        error: error,
        onPrimary: Color(0xFF050A0D),
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: darkBorderCyan, width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkCardBg,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorderSubtle,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyanPrimary,
          foregroundColor: Color(0xFF050A0D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cyanPrimary,
          side: const BorderSide(color: cyanPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cyanPrimary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: darkBorderCyan),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: darkBorderCyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: cyanPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: const TextStyle(color: darkTextHint),
        labelStyle: const TextStyle(color: darkTextSecondary),
        prefixIconColor: darkTextSecondary,
        suffixIconColor: darkTextSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardBg,
        selectedItemColor: cyanPrimary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: darkCardBg,
        selectedIconTheme: IconThemeData(color: cyanPrimary, size: 26),
        unselectedIconTheme: IconThemeData(color: darkTextSecondary, size: 24),
        selectedLabelTextStyle: TextStyle(
          color: cyanPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 12,
        ),
        indicatorColor: Color(0x2020DDF5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkInputBg,
        labelStyle: const TextStyle(color: darkTextPrimary),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF050A0D)),
        secondarySelectedColor: cyanPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: darkBorderCyan),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: TextStyle(color: darkTextPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: cyanPrimary,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: cyanPrimary,
        labelColor: cyanPrimary,
        unselectedLabelColor: darkTextSecondary,
        dividerColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: darkTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: darkTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall:  TextStyle(color: darkTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium:TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleLarge:    TextStyle(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium:   TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge:     TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium:    TextStyle(color: darkTextSecondary, fontSize: 14, fontWeight: FontWeight.normal),
        labelLarge:    TextStyle(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        bodySmall:     TextStyle(color: darkTextSecondary, fontSize: 12, fontWeight: FontWeight.normal),
        labelSmall:    TextStyle(color: darkTextHint, fontSize: 11, fontWeight: FontWeight.normal),
      ),
    );
  }

  // ── Light ThemeData (kept for future use) ──────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: cyanSecondary,
      colorScheme: const ColorScheme.light(
        primary: cyanSecondary,
        secondary: cyanPrimary,
        surface: lightCardBg,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF050A0D),
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 1,
        shadowColor: Color(0x14000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: lightBorder, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyanSecondary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cyanSecondary,
          side: const BorderSide(color: cyanSecondary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cyanSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8F4FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: cyanSecondary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: lightTextSecondary),
        labelStyle: const TextStyle(color: lightTextSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCardBg,
        selectedItemColor: cyanSecondary,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE0EEF5),
        labelStyle: const TextStyle(color: lightTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkCardBg,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: cyanSecondary,
        labelColor: cyanSecondary,
        unselectedLabelColor: lightTextSecondary,
        dividerColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: lightTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: lightTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall:  TextStyle(color: lightTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: lightTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium:TextStyle(color: lightTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleLarge:    TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium:   TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge:     TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium:    TextStyle(color: lightTextSecondary, fontSize: 14),
        labelLarge:    TextStyle(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        bodySmall:     TextStyle(color: lightTextSecondary, fontSize: 12),
        labelSmall:    TextStyle(color: lightTextSecondary, fontSize: 11),
      ),
    );
  }
}
