import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FORGE INTELLIGENCE — Design Tokens (from mobile_app/forge_intelligence/DESIGN.md)
// ═══════════════════════════════════════════════════════════════════════════

// ─── Primary Brand ───
const kPrimary = Color(0xFFA73300);
const kOnPrimary = Color(0xFFFFFFFF);
const kPrimaryContainer = Color(0xFFD14405);
const kOnPrimaryContainer = Color(0xFFFFFBFF);
const kPrimaryFixed = Color(0xFFFFDBD0);
const kPrimaryFixedDim = Color(0xFFFFB59D);
const kOnPrimaryFixed = Color(0xFF390C00);
const kOnPrimaryFixedVariant = Color(0xFF832600);
const kInversePrimary = Color(0xFFFFB59D);
const kSurfaceTint = Color(0xFFAC3500);

// ─── Secondary ───
const kSecondary = Color(0xFF5C5F60);
const kOnSecondary = Color(0xFFFFFFFF);
const kSecondaryContainer = Color(0xFFE1E3E4);
const kOnSecondaryContainer = Color(0xFF626566);
const kSecondaryFixed = Color(0xFFE1E3E4);
const kSecondaryFixedDim = Color(0xFFC5C7C8);

// ─── Tertiary ───
const kTertiary = Color(0xFF5A5C5C);
const kOnTertiary = Color(0xFFFFFFFF);
const kTertiaryContainer = Color(0xFF737575);
const kOnTertiaryContainer = Color(0xFFFCFCFC);

// ─── Error ───
const kError = Color(0xFFBA1A1A);
const kOnError = Color(0xFFFFFFFF);
const kErrorContainer = Color(0xFFFFDAD6);
const kOnErrorContainer = Color(0xFF93000A);

// ─── Surfaces ───
const kSurface = Color(0xFFF7F9FF);
const kSurfaceDim = Color(0xFFD7DADF);
const kSurfaceBright = Color(0xFFF7F9FF);
const kSurfaceContainerLowest = Color(0xFFFFFFFF);
const kSurfaceContainerLow = Color(0xFFF1F4F9);
const kSurfaceContainer = Color(0xFFEBEEF3);
const kSurfaceContainerHigh = Color(0xFFE5E8EE);
const kSurfaceContainerHighest = Color(0xFFE0E3E8);
const kOnSurface = Color(0xFF181C20);
const kOnSurfaceVariant = Color(0xFF5A4139);
const kInverseSurface = Color(0xFF2D3135);
const kInverseOnSurface = Color(0xFFEEF1F6);
const kSurfaceVariant = Color(0xFFE0E3E8);

// ─── Background (aliases surface in M3) ───
const kBackground = Color(0xFFF7F9FF);
const kOnBackground = Color(0xFF181C20);

// ─── Outline ───
const kOutline = Color(0xFF8E7067);
const kOutlineVariant = Color(0xFFE2BFB4);

// ─── Semantic Status ───
const kSuccessColor = Color(0xFF0F9B58);
const kWarningColor = Color(0xFFF5A623);
const kWarningBg = Color(0xFFFFF8E1);
const kWarningBorder = Color(0xFFF59E0B);

// ─── Brand Accent (for nav highlights, logos) ───
const kForgeOrange = Color(0xFFE8541A);

// ═══════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY
// ═══════════════════════════════════════════════════════════════════════════

const kFontFamily = 'Inter';

// Display Large — 32px / 600 / -0.02em
const kDisplayLg = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 32,
  fontWeight: FontWeight.w600,
  height: 40 / 32,
  letterSpacing: -0.64,
  color: kOnSurface,
);

// Headline Medium — 24px / 600 / -0.01em
const kHeadlineMd = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 24,
  fontWeight: FontWeight.w600,
  height: 32 / 24,
  letterSpacing: -0.24,
  color: kOnSurface,
);

// Title Small — 18px / 600
const kTitleSm = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 24 / 18,
  color: kOnSurface,
);

// Body Medium — 16px / 400
const kBodyMd = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 24 / 16,
  color: kOnSurface,
);

// Label Medium — 14px / 500
const kLabelMd = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 14,
  fontWeight: FontWeight.w500,
  height: 20 / 14,
  color: kOnSurface,
);

// Data XS — 12px / 500 / 0.02em
const kDataXs = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 16 / 12,
  letterSpacing: 0.24,
  color: kOnSurface,
);

// ═══════════════════════════════════════════════════════════════════════════
// SPACING (4px base grid)
// ═══════════════════════════════════════════════════════════════════════════

const kSpaceXS = 4.0;
const kSpaceSM = 8.0;
const kSpaceMD = 16.0;
const kSpaceLG = 24.0;
const kSpaceXL = 32.0;
const kSpaceMarginMobile = 20.0;
const kSpaceGutterMobile = 12.0;

// ═══════════════════════════════════════════════════════════════════════════
// BORDER RADIUS
// ═══════════════════════════════════════════════════════════════════════════

const kRadiusSM = 4.0;
const kRadiusDefault = 8.0;
const kRadiusMD = 12.0;
const kRadiusLG = 16.0;
const kRadiusXL = 24.0;

// ═══════════════════════════════════════════════════════════════════════════
// ELEVATION — Ambient Shadows (no borders!)
// ═══════════════════════════════════════════════════════════════════════════

/// Low elevation — 4px blur, 4% opacity for standard cards
const kSoftShadow = [
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 20,
    offset: Offset(0, 4),
    spreadRadius: -4,
  ),
];

/// High elevation — 12px blur, 6% opacity for floating actions / modals
const kHighElevation = [
  BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 24,
    offset: Offset(0, 12),
    spreadRadius: -8,
  ),
];

/// Bottom nav shadow
const kNavShadow = [
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 12,
    offset: Offset(0, -4),
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
// THEME DATA
// ═══════════════════════════════════════════════════════════════════════════

class ForgeTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: kFontFamily,
      scaffoldBackgroundColor: kBackground,
      cardColor: kSurfaceContainerLowest,
      dividerColor: kSurfaceContainer,
      colorScheme: const ColorScheme.light(
        primary: kPrimary,
        onPrimary: kOnPrimary,
        primaryContainer: kPrimaryContainer,
        onPrimaryContainer: kOnPrimaryContainer,
        secondary: kSecondary,
        onSecondary: kOnSecondary,
        secondaryContainer: kSecondaryContainer,
        onSecondaryContainer: kOnSecondaryContainer,
        tertiary: kTertiary,
        onTertiary: kOnTertiary,
        tertiaryContainer: kTertiaryContainer,
        onTertiaryContainer: kOnTertiaryContainer,
        error: kError,
        onError: kOnError,
        errorContainer: kErrorContainer,
        onErrorContainer: kOnErrorContainer,
        surface: kSurface,
        onSurface: kOnSurface,
        onSurfaceVariant: kOnSurfaceVariant,
        inverseSurface: kInverseSurface,
        onInverseSurface: kInverseOnSurface,
        inversePrimary: kInversePrimary,
        outline: kOutline,
        outlineVariant: kOutlineVariant,
        surfaceContainerLowest: kSurfaceContainerLowest,
        surfaceContainerLow: kSurfaceContainerLow,
        surfaceContainer: kSurfaceContainer,
        surfaceContainerHigh: kSurfaceContainerHigh,
        surfaceContainerHighest: kSurfaceContainerHighest,
        surfaceBright: kSurfaceBright,
        surfaceDim: kSurfaceDim,
        surfaceTint: kSurfaceTint,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kSurfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: kSecondary),
        titleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: kOnSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceContainerLowest,
        contentPadding: const EdgeInsets.all(kSpaceMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          borderSide: const BorderSide(color: kPrimary, width: 1),
        ),
        hintStyle: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: kOutline.withValues(alpha: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: kSpaceLG, vertical: kSpaceMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusMD),
          ),
          textStyle: const TextStyle(
            fontFamily: kFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: kPrimary,
        inactiveTrackColor: kSurfaceContainer,
        thumbColor: kPrimary,
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 22),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
        overlayColor: kPrimary.withValues(alpha: 0.12),
      ),
      dividerTheme: const DividerThemeData(
        color: kSurfaceContainer,
        thickness: 1,
        space: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: kDisplayLg,
        headlineMedium: kHeadlineMd,
        titleSmall: kTitleSm,
        bodyMedium: kBodyMd,
        labelMedium: kLabelMd,
        labelSmall: kDataXs,
      ),
    );
  }
}
