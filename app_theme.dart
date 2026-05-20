import 'package:flutter/material.dart';

import 'app_colors.dart';

class InnpoTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
      primary: AppColors.primaryBlue,
      error: AppColors.criticalRed,
      surface: AppColors.cardWhite,
      surfaceContainerHighest: AppColors.lightBackground,
      outlineVariant: AppColors.softBorder,
    );
    return _base(
      scheme: scheme,
      scaffoldBackground: AppColors.lightBackground,
      technicalBackground: AppColors.darkNavy,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.dark,
      primary: const Color(0xFF60A5FA),
      error: const Color(0xFFF87171),
      surface: AppColors.darkNavy,
      surfaceContainerHighest: AppColors.darkNavyAlt,
      outlineVariant: const Color(0xFF334155),
    );
    return _base(
      scheme: scheme,
      scaffoldBackground: AppColors.darkNavy,
      technicalBackground: AppColors.darkNavy,
    );
  }

  static ThemeData _base({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color technicalBackground,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      visualDensity: VisualDensity.standard,
      fontFamily: 'Roboto',
      textTheme: _textTheme(scheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.subtleShadow,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withOpacity(0.12),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: scheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      extensions: [
        BatterySemanticColors(
          ok: AppColors.successGreen,
          warning: AppColors.warningAmber,
          danger: AppColors.criticalRed,
          info: AppColors.infoBlue,
        ),
        InnpoSurfaceColors(
          technicalBackground: technicalBackground,
          separator: scheme.outlineVariant,
          cleanCard: scheme.surface,
          technicalGradientStart: AppColors.technicalBlueGradientStart,
          technicalGradientEnd: AppColors.technicalBlueGradientEnd,
        ),
      ],
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    return TextTheme(
      headlineMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        color: scheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        color: scheme.onSurface,
        fontSize: 16,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(
        color: AppColors.neutralGrey,
        fontSize: 14,
        height: 1.45,
        letterSpacing: 0,
      ),
      labelLarge: TextStyle(
        color: scheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class BatterySemanticColors extends ThemeExtension<BatterySemanticColors> {
  const BatterySemanticColors({
    required this.ok,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final Color ok;
  final Color warning;
  final Color danger;
  final Color info;

  @override
  BatterySemanticColors copyWith({
    Color? ok,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return BatterySemanticColors(
      ok: ok ?? this.ok,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  BatterySemanticColors lerp(
    covariant ThemeExtension<BatterySemanticColors>? other,
    double t,
  ) {
    if (other is! BatterySemanticColors) {
      return this;
    }
    return BatterySemanticColors(
      ok: Color.lerp(ok, other.ok, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

class InnpoSurfaceColors extends ThemeExtension<InnpoSurfaceColors> {
  const InnpoSurfaceColors({
    required this.technicalBackground,
    required this.separator,
    required this.cleanCard,
    required this.technicalGradientStart,
    required this.technicalGradientEnd,
  });

  final Color technicalBackground;
  final Color separator;
  final Color cleanCard;
  final Color technicalGradientStart;
  final Color technicalGradientEnd;

  @override
  InnpoSurfaceColors copyWith({
    Color? technicalBackground,
    Color? separator,
    Color? cleanCard,
    Color? technicalGradientStart,
    Color? technicalGradientEnd,
  }) {
    return InnpoSurfaceColors(
      technicalBackground: technicalBackground ?? this.technicalBackground,
      separator: separator ?? this.separator,
      cleanCard: cleanCard ?? this.cleanCard,
      technicalGradientStart:
          technicalGradientStart ?? this.technicalGradientStart,
      technicalGradientEnd: technicalGradientEnd ?? this.technicalGradientEnd,
    );
  }

  @override
  InnpoSurfaceColors lerp(
    covariant ThemeExtension<InnpoSurfaceColors>? other,
    double t,
  ) {
    if (other is! InnpoSurfaceColors) {
      return this;
    }
    return InnpoSurfaceColors(
      technicalBackground:
          Color.lerp(technicalBackground, other.technicalBackground, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      cleanCard: Color.lerp(cleanCard, other.cleanCard, t)!,
      technicalGradientStart: Color.lerp(
        technicalGradientStart,
        other.technicalGradientStart,
        t,
      )!,
      technicalGradientEnd: Color.lerp(
        technicalGradientEnd,
        other.technicalGradientEnd,
        t,
      )!,
    );
  }
}
