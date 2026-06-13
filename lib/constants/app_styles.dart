import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppStyles {
  static TextStyle get heading1 => GoogleFonts.cairo(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3);

  static TextStyle get heading2 => GoogleFonts.cairo(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3);

  static TextStyle get heading3 => GoogleFonts.cairo(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);

  static TextStyle get heading4 => GoogleFonts.cairo(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);

  static TextStyle get bodyLarge => GoogleFonts.cairo(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5);

  static TextStyle get bodyMedium => GoogleFonts.cairo(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);

  static TextStyle get bodySmall => GoogleFonts.cairo(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary, height: 1.5);

  static TextStyle get label => GoogleFonts.cairo(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5);

  static TextStyle get caption => GoogleFonts.cairo(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  static TextStyle get button => GoogleFonts.cairo(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3);

  static TextStyle get statNumber => GoogleFonts.cairo(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white, height: 1.0);

  static TextStyle get statLabel => GoogleFonts.cairo(
    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.white.withValues(alpha: 0.85));

  // Legacy aliases for backward compatibility
  static TextStyle get bodyText1 => bodyLarge;
  static TextStyle get bodyText2 => bodyMedium;

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
    textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
    elevation: 2,
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
  );

  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.inputRadius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.cairo(color: AppColors.textTertiary, fontSize: 14),
    );
  }

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
    boxShadow: [
      BoxShadow(color: AppColors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
      BoxShadow(color: AppColors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
    ],
  );
}