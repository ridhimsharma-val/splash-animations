import 'package:flutter/material.dart';

/// Design tokens and theme for the Onboarding & Splash Animation Lab.
/// Soft pastel lavender, baby-pink, and off-white palette.
class AppColors {
  AppColors._();

  // Core Theme Palette
  static const Color background = Color(0xFFF8F7FC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFFDCC8F5);
  static const Color secondaryAccent = Color(0xFFF7DDEB);
  static const Color softLavender = Color(0xFFEEE6FA);
  static const Color lavenderSurface = Color(0xFFF3EDFD);
  static const Color pinkSurface = Color(0xFFFDF0F6);
  static const Color textPrimary = Color(0xFF292536);
  static const Color textSecondary = Color(0xFF817B8D);
  static const Color textMuted = Color(0xFFAAA5B5);
  static const Color border = Color(0xFFECE7F2);
  static const Color borderSubtle = Color(0xFFF0ECF6);

  // Vibrant highlights for badges & accents
  static const Color deepLavender = Color(0xFF7E57C2);
  static const Color deepPink = Color(0xFFD81B60);
  static const Color activeGreen = Color(0xFF10B981);
  static const Color phoneBezel = Color(0xFFE5DFEE);
  static const Color phoneScreenBg = Color(0xFFFAFAFE);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepLavender,
        secondary: AppColors.deepPink,
        surface: AppColors.cardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}
