import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens transcribed from stitch_fasol_doctor_agriculture_app_design/
/// lush_agritech/DESIGN.md — "Tactile Modern Organic". Do not hand-pick new
/// colors/radii outside this file; every screen should read from here so the
/// app stays visually identical to the approved Stitch screens.
class AppColors {
  // Palette Architecture (DESIGN.md "Colors")
  static const primary = Color(0xFF166534); // Deep paddy green — decisive actions
  static const primaryDark = Color(0xFF004C22); // primary-container tone used as page-level "primary" in Stitch tailwind config
  static const primaryFixed = Color(0xFFA6F4B5); // high-vis pill / accent backgrounds
  static const primaryFixedDim = Color(0xFF8BD79B);
  static const onPrimaryFixedVariant = Color(0xFF005226);
  static const secondary = Color(0xFFD97706); // Harvest amber — alerts, warnings, voice accents
  static const secondaryContainer = Color(0xFFFE932C);
  static const onSecondaryContainer = Color(0xFF663500);
  static const tertiary = Color(0xFF0D9488); // Irrigation teal — secondary utilities

  static const surfaceField = Color(0xFFF8FAF6); // page background
  static const surfaceRaised = Color(0xFFFFFFFF); // cards, sheets
  static const surfaceContainer = Color(0xFFE6EEFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainerHigh = Color(0xFFDEE9FC);
  static const surfaceContainerHighest = Color(0xFFD9E3F6);
  static const borderSoft = Color(0xFFE2E8F0);

  static const onSurface = Color(0xFF1F2937); // Deep charcoal bark
  static const onSurfaceVariant = Color(0xFF404940);

  static const diseaseAlert = Color(0xFFDC2626);
  static const pestNotice = Color(0xFFEA580C);
  static const healthyCrop = Color(0xFF16A34A);
  static const error = Color(0xFFBA1A1A);
}

/// Typography scale from DESIGN.md, tied to Noto Sans / Noto Sans Bengali —
/// Bengali needs 20-25% taller line heights than Latin for matras/kars.
class AppText {
  static TextStyle _style(double size, double height, FontWeight weight, Color color) {
    return GoogleFonts.notoSansBengali(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle displayLg({Color color = AppColors.onSurface}) => _style(32, 44, FontWeight.w700, color);
  static TextStyle headlineLg({Color color = AppColors.onSurface}) => _style(26, 36, FontWeight.w700, color);
  static TextStyle headlineMd({Color color = AppColors.onSurface}) => _style(22, 32, FontWeight.w600, color);
  static TextStyle headlineSm({Color color = AppColors.onSurface}) => _style(18, 26, FontWeight.w600, color);
  static TextStyle bodyLg({Color color = AppColors.onSurface}) => _style(18, 28, FontWeight.w400, color);
  static TextStyle bodyMd({Color color = AppColors.onSurface}) => _style(16, 24, FontWeight.w400, color);
  static TextStyle bodySm({Color color = AppColors.onSurfaceVariant}) => _style(14, 20, FontWeight.w500, color);
  static TextStyle labelLg({Color color = AppColors.onSurface}) => _style(16, 22, FontWeight.w700, color);
  static TextStyle labelMd({Color color = AppColors.onSurface}) => _style(14, 18, FontWeight.w600, color);
  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) => _style(12, 16, FontWeight.w600, color);
}

/// Elevation & Depth — "dual-token depth": ambient shadow + crisp low-contrast
/// outline, never a bare drop-shadow. DESIGN.md Level 1/2/3.
class AppElevation {
  static const level1 = [
    BoxShadow(color: Color(0x0F166534), blurRadius: 6, offset: Offset(0, 2), spreadRadius: -1),
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1), spreadRadius: -1),
  ];
  static const level2 = [
    BoxShadow(color: Color(0x1F166534), blurRadius: 20, offset: Offset(0, 8), spreadRadius: -3),
  ];
  static const level1Border = BorderSide(color: AppColors.borderSoft, width: 1);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surfaceField,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.tertiary,
        surface: AppColors.surfaceField,
        error: AppColors.error,
        outline: AppColors.borderSoft,
      ),
      textTheme: TextTheme(
        displayMedium: AppText.displayLg(),
        headlineLarge: AppText.headlineLg(),
        headlineMedium: AppText.headlineMd(),
        headlineSmall: AppText.headlineSm(),
        bodyLarge: AppText.bodyLg(),
        bodyMedium: AppText.bodyMd(),
        bodySmall: AppText.bodySm(),
        labelLarge: AppText.labelLg(),
        labelMedium: AppText.labelMd(),
        labelSmall: AppText.labelSm(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56), // Primary Action (Leaf Action)
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppText.labelLg(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52), // Secondary Action (Soil Action)
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppText.labelLg(color: AppColors.primary),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSoft),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceRaised.withOpacity(0.95),
        indicatorColor: AppColors.primaryFixed.withOpacity(0.5),
        elevation: 0,
        height: 80,
        labelTextStyle: WidgetStateProperty.all(AppText.labelSm()),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceRaised.withOpacity(0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppText.headlineSm(),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
    );
  }
}
