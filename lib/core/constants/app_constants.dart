import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Café primary palette
  static const Color primary = Color(0xFF5D4037); // Deep Brown
  static const Color primaryLight = Color(0xFF8D6E63); // Light Brown
  static const Color primaryDark = Color(0xFF3E2723); // Very Dark Brown
  static const Color accent = Color(0xFFFFB300); // Amber
  static const Color accentDark = Color(0xFFFF8F00); // Dark Amber
  static const Color surface = Color(0xFFFFF8E1); // Cream
  static const Color background = Color(0xFFF5F0EB); // Warm Off-White
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFEFEBE9);
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF1E88E5);

  // Dark theme
  static const Color darkBg = Color(0xFF1A1209);
  static const Color darkSurface = Color(0xFF2C1F0E);
  static const Color darkCard = Color(0xFF3D2B14);
  static const Color darkText = Color(0xFFF5ECD7);
  static const Color darkTextSecondary = Color(0xFFBCAB93);

  // Cash/Card
  static const Color cashColor = Color(0xFF2E7D32);
  static const Color cardColor = Color(0xFF1565C0);

  // Sidebar
  static const Color sidebarBg = Color(0xFF3E2723);
  static const Color sidebarSelected = Color(0xFFFFB300);
  static const Color sidebarText = Color(0xFFF5ECD7);
  static const Color sidebarTextSelected = Color(0xFF3E2723);
}

class AppSizes {
  AppSizes._();

  static const double sidebarWidth = 240.0;
  static const double sidebarCollapsedWidth = 64.0;
  static const double appBarHeight = 60.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double cardElevation = 2.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

class AppStrings {
  AppStrings._();
  static const String dbName = 'cafe_db.sqlite';
  static const String prefThemeKey = 'theme_mode';
  static const String prefLangKey = 'language';
  static const String prefRememberKey = 'remember_me';
  static const String prefLoggedInKey = 'logged_in';
  static const String prefTaxEnabledKey = 'tax_enabled';
  static const String prefTaxPercentKey = 'tax_percent';
  static const String prefDiscountEnabledKey = 'discount_enabled';
  static const String prefDiscountTypeKey = 'discount_type';
  static const String prefDiscountValueKey = 'discount_value';
}
