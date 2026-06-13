import 'package:flutter/material.dart';

class AppColors {
  // === Primary (Deep Teal) ===
  static const Color primary = Color(0xFF00897B);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryExtraLight = Color(0xFFE0F2F1);

  // === Secondary (Warm Coral) ===
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFE05555);
  static const Color secondaryLight = Color(0xFFFFAB40);

  // === Accent (Gold) ===
  static const Color accent = Color(0xFFFFD166);
  static const Color accentDark = Color(0xFFFFB347);

  // === Semantic Colors ===
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE65100);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // === Text Colors (Light Mode) ===
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF44474F);
  static const Color textTertiary = Color(0xFF74777F);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // === Background Colors (Light Mode) ===
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFECEFF4);

  // === Dark Mode - Material 3 Correct ===
  static const Color darkBackground = Color(0xFF10131A);
  static const Color darkSurface = Color(0xFF1C2030);
  static const Color darkSurfaceVariant = Color(0xFF252A3B);
  static const Color darkCard = Color(0xFF1E2336);
  static const Color darkBorder = Color(0xFF2E3450);
  static const Color darkTextPrimary = Color(0xFFE2E6F0);
  static const Color darkTextSecondary = Color(0xFF9EA8C0);

  // === Apartment Status (FIXED: rented=green, vacant=grey, late=red) ===
  static const Color apartmentRented = Color(0xFF2E7D32);
  static const Color apartmentVacant = Color(0xFF78909C);
  static const Color apartmentLate = Color(0xFFC62828);
  static const Color apartmentRentedLight = Color(0xFFE8F5E9);
  static const Color apartmentVacantLight = Color(0xFFECEFF1);
  static const Color apartmentLateLight = Color(0xFFFFEBEE);

  // === Contract Status ===
  static const Color contractActive = Color(0xFF2E7D32);
  static const Color contractEnding = Color(0xFFE65100);
  static const Color contractEnded = Color(0xFFC62828);

  // === Gradient Definitions ===
  static const List<Color> primaryGradient = [Color(0xFF00897B), Color(0xFF26A69A)];
  static const List<Color> secondaryGradient = [Color(0xFFFF6B6B), Color(0xFFFF8E53)];
  static const List<Color> successGradient = [Color(0xFF2E7D32), Color(0xFF43A047)];
  static const List<Color> warningGradient = [Color(0xFFE65100), Color(0xFFFF6D00)];
  static const List<Color> infoGradient = [Color(0xFF1565C0), Color(0xFF1976D2)];
  static const List<Color> purpleGradient = [Color(0xFF6A1B9A), Color(0xFF8E24AA)];
  static const List<Color> headerGradient = [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF26A69A)];

  // === Neutral ===
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF616161);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color divider = Color(0xFFE0E0E0);

  // === Shimmer ===
  static const Color shimmerBase = Color(0xFFE8ECF0);
  static const Color shimmerHighlight = Color(0xFFF5F7FA);
  static const Color shimmerBaseDark = Color(0xFF252A3B);
  static const Color shimmerHighlightDark = Color(0xFF2E3450);
}