import 'package:flutter/material.dart';

class AppColors {
  static const primary     = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const accent      = Color(0xFF06B6D4);
  static const success     = Color(0xFF10B981);
  static const warning     = Color(0xFFF59E0B);
  static const error       = Color(0xFFEF4444);
  static const bg          = Color(0xFFEEF2FF);
  static const surface     = Color(0xFFFFFFFF);
  static const border      = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub     = Color(0xFF6B7280);
  static const textMuted   = Color(0xFF9CA3AF);
}

class AppTextStyles {
  static const heading = TextStyle(
      fontSize: 26, fontWeight: FontWeight.w800,
      color: AppColors.textPrimary, height: 1.2);
  static const title = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static const subtitle = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500,
      color: AppColors.textSub, height: 1.3);
  static const label = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500,
      color: AppColors.textPrimary);
  static const body = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400,
      color: AppColors.textPrimary);
  static const caption = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.textSub);
  static const mono = TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600,
      fontFamily: 'monospace', color: AppColors.primary, letterSpacing: 1);
}

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: AppTextStyles.caption,
        floatingLabelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: AppColors.primary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),

      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),

      dividerTheme: const DividerThemeData(
        space: 0, thickness: 1, color: AppColors.border,
      ),
    );
  }
}
