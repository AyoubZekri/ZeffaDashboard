import 'package:flutter/material.dart';
import 'Colorapp.dart';

// ═══════════════════════════════════════════════════════
// Custom ThemeExtension for app-specific colors
// ═══════════════════════════════════════════════════════
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color sidebarColor;
  final Color topBarColor;
  final Color inputFillColor;
  final Color borderColor;
  final Color subtitleColor;
  final Color cardColor;
  final Color shadowColor;

  const AppColors({
    required this.sidebarColor,
    required this.topBarColor,
    required this.inputFillColor,
    required this.borderColor,
    required this.subtitleColor,
    required this.cardColor,
    required this.shadowColor,
  });

  // Light mode colors
  static const light = AppColors(
    sidebarColor: AppColor.sidebarLight,
    topBarColor: Colors.white,
    inputFillColor: Color(0xFFF1F5F9),
    borderColor: Color(0xFFE0E0E0),
    subtitleColor: Color(0xFF757575),
    cardColor: Colors.white,
    shadowColor: Color(0x0A000000),
  );

  // Dark mode colors
  static const dark = AppColors(
    sidebarColor: AppColor.sidebarDark,
    topBarColor: AppColor.surfaceDark,
    inputFillColor: Color(0x0DFFFFFF),
    borderColor: Color(0x1AFFFFFF),
    subtitleColor: Color(0xFF8E92BC),
    cardColor: AppColor.surfaceDark,
    shadowColor: Color(0x05000000),
  );

  @override
  AppColors copyWith({
    Color? sidebarColor,
    Color? topBarColor,
    Color? inputFillColor,
    Color? borderColor,
    Color? subtitleColor,
    Color? cardColor,
    Color? shadowColor,
  }) {
    return AppColors(
      sidebarColor: sidebarColor ?? this.sidebarColor,
      topBarColor: topBarColor ?? this.topBarColor,
      inputFillColor: inputFillColor ?? this.inputFillColor,
      borderColor: borderColor ?? this.borderColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      cardColor: cardColor ?? this.cardColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      sidebarColor: Color.lerp(sidebarColor, other.sidebarColor, t)!,
      topBarColor: Color.lerp(topBarColor, other.topBarColor, t)!,
      inputFillColor: Color.lerp(inputFillColor, other.inputFillColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════
// Global Themes
// ═══════════════════════════════════════════════════════
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    primaryColor: AppColor.primaryPurple,
    scaffoldBackgroundColor: AppColor.backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: AppColor.primaryPurple,
      secondary: AppColor.accentPurple,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: AppColor.textLight,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColor.textLight),
      bodyMedium: TextStyle(color: AppColor.textLight),
      titleLarge: TextStyle(color: AppColor.textLight),
      titleMedium: TextStyle(color: AppColor.textLight),
      titleSmall: TextStyle(color: AppColor.textLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.backgroundLight,
      iconTheme: IconThemeData(color: AppColor.textLight),
      titleTextStyle: TextStyle(color: AppColor.textLight, fontSize: 20),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.primaryPurple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 13),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColor.primaryPurple.withOpacity(0.1),
      selectedColor: AppColor.primaryPurple,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      side: const BorderSide(color: Color(0xFFE0E0E0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),
    extensions: const [AppColors.light],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    primaryColor: AppColor.primaryPurple,
    scaffoldBackgroundColor: AppColor.backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: AppColor.primaryPurple,
      secondary: AppColor.accentPurple,
      surface: AppColor.surfaceDark,
      onPrimary: Colors.white,
      onSurface: AppColor.textDark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColor.textDark),
      bodyMedium: TextStyle(color: AppColor.textDark),
      titleLarge: TextStyle(color: AppColor.textDark),
      titleMedium: TextStyle(color: AppColor.textDark),
      titleSmall: TextStyle(color: AppColor.textDark),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.backgroundDark,
      iconTheme: IconThemeData(color: AppColor.textDark),
      titleTextStyle: TextStyle(color: AppColor.textDark, fontSize: 20),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColor.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    cardTheme: const CardThemeData(
      color: AppColor.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x0DFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.primaryPurple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      hintStyle: const TextStyle(color: Color(0xFF8E92BC), fontSize: 13),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.06),
      selectedColor: AppColor.primaryPurple,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      side: const BorderSide(color: Color(0x1AFFFFFF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x1AFFFFFF),
      thickness: 1,
    ),
    extensions: const [AppColors.dark],
  );
}
