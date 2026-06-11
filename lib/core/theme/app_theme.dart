import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFF242424);
  static const primary = Color(0xFFCC0000);
  static const accent = Color(0xFFFFD700);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFF9E9E9E);
  static const divider = Color(0xFF2C2C2C);

  static const Map<String, Color> typeColors = {
    'fire': Color(0xFFFF6B35),
    'water': Color(0xFF4FC3F7),
    'grass': Color(0xFF66BB6A),
    'electric': Color(0xFFFFD700),
    'psychic': Color(0xFFEC407A),
    'ice': Color(0xFF80DEEA),
    'dragon': Color(0xFF7C4DFF),
    'dark': Color(0xFF5D4037),
    'fairy': Color(0xFFF48FB1),
    'fighting': Color(0xFFE53935),
    'poison': Color(0xFFAB47BC),
    'ground': Color(0xFFD7CCC8),
    'flying': Color(0xFF90CAF9),
    'bug': Color(0xFF9CCC65),
    'rock': Color(0xFFBCAAA4),
    'ghost': Color(0xFF7E57C2),
    'steel': Color(0xFF90A4AE),
    'normal': Color(0xFF757575),
  };

  static Color typeColor(String type) =>
      typeColors[type.toLowerCase()] ?? const Color(0xFF757575);
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          labelSmall: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerColor: AppColors.divider,
        useMaterial3: true,
      );
}
