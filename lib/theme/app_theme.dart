import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette lifted 1:1 from the Voice2Law web design tokens
/// (`src/styles/globals.css` -> --color-dark-green / --color-emerald-green /
/// --color-gold-accent / --color-light-green / --color-off-white).
class AppColors {
  const AppColors._();

  static const Color darkGreen = Color(0xFF0B3D2E);
  static const Color emerald = Color(0xFF1FAA59);
  static const Color gold = Color(0xFFC5A253);
  static const Color goldLight = Color(0xFFD4B76E);
  static const Color lightGreen = Color(0xFFE8F5ED);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);

  /// Deep purple accent used by AI action buttons and callouts.
  static const Color deepPurple = Color(0xFF5B21B6);

  /// Green used for hairline borders on cards/chips.
  static const Color borderGreen = Color(0xFF1FAA59);

  // ---------------------------------------------------------------------------
  // Semantic text tokens.
  // Contrast ratios verified against WCAG AA (4.5:1 for body text, 3:1 for
  // non-text UI) with the ui-ux-pro-max audit scripts in
  // `d:\final-fyp-main\tools\uiux_contrast_*.py`. Prefer these over
  // translucent `darkGreen.withValues(...)`, which drops below 4.5:1 on white
  // at alpha < 0.7.
  // ---------------------------------------------------------------------------

  /// Secondary/caption body text - 5.60:1 on white, 4.99:1 on lightGreen.
  static const Color textSecondary = Color(0xFF4A6F64);

  /// Gold text on light surfaces - 5.04:1 on white (`gold` itself is 2.42:1
  /// and must only be used on dark backgrounds such as the darkGreen app bar).
  static const Color goldText = Color(0xFF8A6A22);

  /// Selected chip/segment background carrying a white label - 5.02:1.
  static const Color emeraldDeep = Color(0xFF15803D);

  /// Emerald text (small labels/badges) on light surfaces - 5.02:1.
  static const Color emeraldText = Color(0xFF15803D);

  /// Inactive bottom-nav labels - 4.87:1 on white (old #7A8B84 was 3.59:1).
  static const Color navUnselected = Color(0xFF64756E);

  /// `gradient-green` utility class from the website.
  static const LinearGradient gradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[darkGreen, emerald],
  );

  static const LinearGradient gradientEmeraldToDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[emerald, darkGreen],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[gold, goldLight],
  );

  /// Page background used by every inner page of the website
  /// (`bg-gradient-to-br from-[#E8F5ED] to-white`).
  static const LinearGradient gradientPage = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[lightGreen, white],
  );
}

/// Typography helpers. English uses EB Garamond for headings and Lato for body
/// text (the design-system font pairing). Urdu uses the bundled Noto Nastaliq
/// Urdu font.
class AppText {
  const AppText._();

  static const String urduFamily = 'NotoNastaliqUrdu';

  /// English heading style — EB Garamond serif.
  static TextStyle heading({
    double size = 27,
    Color color = AppColors.darkGreen,
    FontWeight weight = FontWeight.w700,
    double height = 1.25,
  }) {
    return GoogleFonts.ebGaramond(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }

  /// English body style — Lato sans-serif.
  static TextStyle body({
    double size = 15,
    Color color = AppColors.darkGreen,
    FontWeight weight = FontWeight.w400,
    double height = 1.6,
  }) {
    return GoogleFonts.lato(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }

  static TextStyle urdu({
    double size = 18,
    Color color = AppColors.darkGreen,
    FontWeight weight = FontWeight.w500,
    double height = 2.0,
  }) {
    return TextStyle(
      fontFamily: urduFamily,
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkGreen,
      primary: AppColors.darkGreen,
      secondary: AppColors.emerald,
      tertiary: AppColors.gold,
      surface: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 3,
        shadowColor: AppColors.darkGreen.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkGreen.withValues(alpha: 0.12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.darkGreen.withValues(alpha: 0.12),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.darkGreen.withValues(alpha: 0.12),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.emerald, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkGreen),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.emerald, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGreen,
        selectedColor: AppColors.emeraldDeep,
        labelStyle: const TextStyle(
          color: AppColors.darkGreen,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.darkGreen,
        unselectedItemColor: AppColors.navUnselected,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.white),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGreen,
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.emerald,
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.darkGreen),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.emerald,
        selectionColor: Color(0x551FAA59),
        selectionHandleColor: AppColors.emerald,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkGreen,
      brightness: Brightness.dark,
      primary: AppColors.emerald,
      secondary: AppColors.gold,
      tertiary: AppColors.goldLight,
      surface: const Color(0xFF1A2E25),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0F1F18),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B3D2E),
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A2E25),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.white.withValues(alpha: 0.12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2E25),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.white.withValues(alpha: 0.12),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.white.withValues(alpha: 0.12),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.emerald, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.emerald, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1A2E25),
        selectedColor: AppColors.emeraldDeep,
        labelStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B3D2E),
        selectedItemColor: AppColors.emerald,
        unselectedItemColor: AppColors.navUnselected,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1A2E25)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A2E25),
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.emerald,
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.emerald),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.emerald,
        selectionColor: Color(0x551FAA59),
        selectionHandleColor: AppColors.emerald,
      ),
    );
  }
}
