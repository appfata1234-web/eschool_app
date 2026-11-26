import 'package:flutter/material.dart';

/// User-selected off-white and deep ink palette.
class AppColors {
  AppColors._();
  static const primary = Color(0xFF011627);
  static const primarySoft = Color(0xFFE9EFF2);
  static const accent = Color(0xFFFDFFFC);
  static const accentSoft = Color(0xFFF4F7F5);
  static const accentInk = primary;
  static const coral = Color(0xFFB42318);
  static const lightBackground = accent;
  static const lightSurface = Color(0xFFF4F7F5);
  static const lightSurfaceAlt = primarySoft;
  static const lightBorder = Color(0xFFD3DCE2);
  static const lightTextPrimary = primary;
  static const lightTextSecondary = Color(0xFF4A5B69);
  static const darkBackground = primary;
  static const darkSurface = Color(0xFF0A2236);
  static const darkSurfaceAlt = Color(0xFF132E45);
  static const darkBorder = Color(0xFF1E3A52);
  static const darkTextPrimary = accent;
  static const darkTextSecondary = Color(0xFF98AAB8);
  static const grade5 = primary;
  static const grade4 = Color(0xFF4A5B69);
  static const grade3 = Color(0xFF5C7080);
  static const grade2 = coral;
  static const success = primary;
  static const warning = grade3;
  static const danger = coral;
  static const info = grade4;
  static Color forGrade(int value) => switch (value) {
    5 => grade5,
    4 => grade4,
    3 => grade3,
    _ => grade2,
  };
  static Color forAverage(double value) => forGrade(
    value >= 4.5
        ? 5
        : value >= 3.5
        ? 4
        : value >= 2.5
        ? 3
        : 2,
  );
}

class AppRadii {
  AppRadii._();
  static const card = 14.0;
  static const focus = 16.0;
  static const chip = 6.0;
  static const input = 10.0;
  static const dock = 31.0;
  static const sheet = 24.0;
}

class AppSpacing {
  AppSpacing._();
  static const page = 18.0;
  static const section = 20.0;
  static const gap = 12.0;
  static const touch = 48.0;
  static const wide = 840.0;
  static const rail = 232.0;
  static const content = 960.0;
}

/// A single family with clear hierarchy and tabular numeric metrics.
class AppText {
  AppText._();

  static const String bodyFamily = 'Onest';
  static const String displayFamily = 'Onest';
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextStyle pageTitle(Color color) => TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: color,
  );

  static TextStyle display(Color color, {double size = 32}) => TextStyle(
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
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.45,
    color: color,
  );

  static TextStyle body(Color color, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontSize: 15,
        height: 1.35,
        fontWeight: weight,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle small(Color color, {FontWeight weight = FontWeight.w500}) =>
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

  Color get appPrimary => appInk;
  Color get appPrimarySoft => appSurfaceAlt;
  Color get appAccent => appInk;
  Color get appAccentSoft => appSurfaceAlt;
  Color get appHero => isDark ? AppColors.darkSurface : AppColors.primary;
  Color get appGrade => appInk;
  Color get appOnInk => isDark ? AppColors.primary : AppColors.accent;
  Color get appError => isDark ? const Color(0xFFF97066) : AppColors.danger;
  Color get appBorderStrong =>
      isDark ? const Color(0xFF3A566E) : const Color(0xFF9FB0BC);
  Color get appInkSoft =>
      isDark ? AppColors.darkSurfaceAlt : const Color(0xFF132C42);
  Color get dockBackground =>
      isDark ? const Color(0xFF0D263C) : AppColors.primary;
}

/// Application light and dark themes.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceAlt = isDark
        ? AppColors.darkSurfaceAlt
        : AppColors.lightSurfaceAlt;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final ink = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final muted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final primary = ink;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? AppColors.primary : AppColors.accent,
      secondary: primary,
      onSecondary: isDark ? AppColors.primary : AppColors.accent,
      error: isDark ? const Color(0xFFF97066) : AppColors.danger,
      onError: AppColors.accent,
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
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? AppColors.primary : AppColors.accent,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppText.body(AppColors.accent, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          minimumSize: const Size(48, 48),
          textStyle: AppText.small(primary, weight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        hintStyle: AppText.body(muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
            return isDark ? AppColors.primary : AppColors.accent;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
      ),
    );
  }
}
