import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final pfColors = isDark ? PfThemeColors.dark() : PfThemeColors.light();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: pfColors.surface,
      onSurface: pfColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: pfColors.background,
      colorScheme: colorScheme,
      extensions: [pfColors],
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: pfColors.textPrimary,
            displayColor: pfColors.textPrimary,
          ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: pfColors.background,
        foregroundColor: pfColors.textPrimary,
        surfaceTintColor: pfColors.background,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pfColors.card,
        hintStyle: TextStyle(color: pfColors.textMuted),
        labelStyle: TextStyle(color: pfColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: pfColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: pfColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: pfColors.nav,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: pfColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(color: pfColors.stroke),
      iconTheme: IconThemeData(color: pfColors.textPrimary),
    );
  }
}

@immutable
class PfThemeColors extends ThemeExtension<PfThemeColors> {
  const PfThemeColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.nav,
    required this.stroke,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  factory PfThemeColors.dark() => const PfThemeColors(
        background: Color(0xFF0D0D0D),
        surface: Color(0xFF111820),
        card: Color(0xFF12161D),
        nav: Color(0xFF080A0D),
        stroke: Color(0xFF222A35),
        textPrimary: Color(0xFFF5F7FA),
        textSecondary: Color(0xFFB8C0CC),
        textMuted: Color(0xFF7A8494),
      );

  factory PfThemeColors.light() => const PfThemeColors(
        background: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        card: Color(0xFFFFFFFF),
        nav: Color(0xFFFFFFFF),
        stroke: Color(0xFFE2E8F0),
        textPrimary: Color(0xDD000000),
        textSecondary: Color(0xFF374151),
        textMuted: Color(0xFF6B7280),
      );

  final Color background;
  final Color surface;
  final Color card;
  final Color nav;
  final Color stroke;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  @override
  PfThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? nav,
    Color? stroke,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
  }) {
    return PfThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      nav: nav ?? this.nav,
      stroke: stroke ?? this.stroke,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  PfThemeColors lerp(ThemeExtension<PfThemeColors>? other, double t) {
    if (other is! PfThemeColors) return this;
    return PfThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      nav: Color.lerp(nav, other.nav, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

extension PfThemeAccess on BuildContext {
  PfThemeColors get pfColors {
    final extension = Theme.of(this).extension<PfThemeColors>();
    if (extension != null) return extension;

    return Theme.of(this).brightness == Brightness.dark
        ? PfThemeColors.dark()
        : PfThemeColors.light();
  }
}
