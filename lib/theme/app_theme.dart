import 'package:flutter/material.dart';

/// Brand and semantic colors for the school diary.
///
/// The palette is built from school materials: cobalt ink, cool paper and a
/// highlighter yellow. Subject colors stay secondary to these tokens.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1F45E5);
  static const Color primarySoft = Color(0xFFE7EBFF);
  static const Color accent = Color(0xFFDDF247);
  static const Color accentSoft = Color(0xFFF1F7C7);
  static const Color accentInk = Color(0xFF141E00);
  static const Color coral = Color(0xFFF05A3C);

  static const Color lightBackground = Color(0xFFF1F4F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFE8EDF3);
  static const Color lightBorder = Color(0xFFD2DAE5);
  static const Color lightTextPrimary = Color(0xFF0B1524);
  static const Color lightTextSecondary = Color(0xFF5A6878);

  static const Color darkBackground = Color(0xFF080D18);
  static const Color darkSurface = Color(0xFF111A2B);
  static const Color darkSurfaceAlt = Color(0xFF1A2539);
  static const Color darkBorder = Color(0xFF2A3850);
  static const Color darkTextPrimary = Color(0xFFF3F6FC);
  static const Color darkTextSecondary = Color(0xFF9FAFC5);

  static const Color grade5 = Color(0xFF0B7A55);
  static const Color grade4 = Color(0xFF1D5FD1);
  static const Color grade3 = Color(0xFFA85A00);
  static const Color grade2 = Color(0xFFB3261E);

  static const Color success = grade5;
  static const Color warning = grade3;
  static const Color danger = Color(0xFFC43A20);
  static const Color info = grade4;

  static Color forGrade(int value) {
    switch (value) {
      case 5:
        return grade5;
      case 4:
        return grade4;
      case 3:
        return grade3;
      default:
        return grade2;
    }
  }

  static Color forAverage(double avg) {
    if (avg >= 4.5) return grade5;
    if (avg >= 3.5) return grade4;
    if (avg >= 2.5) return grade3;
    return grade2;
  }
}

/// Typography rules: Unbounded carries the page title and oversized numbers;
/// Onest carries every body size. Three body steps are used: 13, 15 and 22.
class AppText {
  AppText._();

  static const String bodyFamily = 'Onest';
  static const String displayFamily = 'Unbounded';
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextStyle pageTitle(Color color) => TextStyle(
        fontFamily: displayFamily,
        fontSize: 29,
        height: 1.05,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.1,
        color: color,
      );

  static TextStyle display(Color color, {double size = 66}) => TextStyle(
        fontFamily: displayFamily,
        fontSize: size,
        height: 0.96,
        fontWeight: FontWeight.w700,
        letterSpacing: size * -0.045,
        color: color,
        fontFeatures: tabular,
      );

  static TextStyle section(Color color) => TextStyle(
        fontFamily: bodyFamily,
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.45,
        color: color,
      );

  static TextStyle body(
    Color color, {
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontSize: 15,
        height: 1.45,
        fontWeight: weight,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle small(
    Color color, {
    FontWeight weight = FontWeight.w500,
  }) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontSize: 13,
        height: 1.35,
        fontWeight: weight,
        letterSpacing: -0.05,
        color: color,
      );
}

/// Shortcuts for the active light or dark palette.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground =>
      isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get appSurface =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;

  Color get appSurfaceAlt =>
      isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;

  Color get appBorder => isDark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get appInk =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get appMuted =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get appPrimary => isDark ? const Color(0xFF8CA2FF) : AppColors.primary;

  Color get appPrimarySoft =>
      isDark ? const Color(0xFF1B2B58) : AppColors.primarySoft;

  Color get appAccent => AppColors.accent;

  Color get appAccentSoft =>
      isDark ? const Color(0xFF2A3510) : AppColors.accentSoft;

  Color get appHero =>
      isDark ? const Color(0xFF1835C4) : AppColors.primary;

  Color get appGrade => isDark ? AppColors.grade4 : AppColors.primary;
}

/// Application light and dark themes.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceAlt =
        isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final ink =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primary = isDark ? const Color(0xFF8CA2FF) : AppColors.primary;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? const Color(0xFF071126) : Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.accentInk,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: surfaceAlt,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ink,
      onInverseSurface: surface,
      inversePrimary: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surface,
      dividerColor: border,
      fontFamily: AppText.bodyFamily,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: TextTheme(
        headlineMedium: AppText.pageTitle(ink),
        titleLarge: AppText.section(ink),
        titleMedium: AppText.body(ink, weight: FontWeight.w600),
        bodyMedium: AppText.body(ink),
        bodySmall: AppText.small(muted),
        labelLarge: AppText.body(ink, weight: FontWeight.w600),
        labelMedium: AppText.small(muted, weight: FontWeight.w600),
      ),
      iconTheme: IconThemeData(color: ink, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? const Color(0xFF071126) : Colors.white,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppText.body(Colors.white, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          minimumSize: const Size(0, 40),
          textStyle: AppText.small(primary, weight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: AppText.body(muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? const Color(0xFF071126) : Colors.white;
          }
          return muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return surfaceAlt;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : border,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border),
        ),
        titleTextStyle: AppText.section(ink),
        contentTextStyle: AppText.body(muted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: AppText.body(surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
      ),
    );
  }
}
