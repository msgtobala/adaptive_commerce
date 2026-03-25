import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// **Happy Paws** — Alegreya Sans + warm pet-store palette.
ThemeData buildHappyPawsTheme() {
  final baseScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.headline,
    secondary: AppColors.bodySecondary,
    onSecondary: AppColors.onPrimary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.bodySecondary,
    tertiary: AppColors.warning,
    onTertiary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.headline,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.bodySecondary,
    outline: AppColors.outline,
    outlineVariant: AppColors.divider,
    error: AppColors.error,
    onError: AppColors.onPrimary,
  );

  final textTheme = GoogleFonts.alegreyaSansTextTheme(
    ThemeData(brightness: Brightness.light).textTheme,
  );

  final resolvedTextTheme = textTheme.copyWith(
    displayLarge: textTheme.displayLarge?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: textTheme.displayMedium?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: textTheme.displaySmall?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: textTheme.headlineLarge?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: textTheme.headlineMedium?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: textTheme.headlineSmall?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: textTheme.titleLarge?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: textTheme.titleMedium?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: textTheme.titleSmall?.copyWith(
      color: AppColors.bodySecondary,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: textTheme.bodyLarge?.copyWith(
      color: AppColors.bodySecondary,
      fontWeight: FontWeight.w400,
      height: 1.35,
    ),
    bodyMedium: textTheme.bodyMedium?.copyWith(
      color: AppColors.bodySecondary,
      height: 1.35,
    ),
    bodySmall: textTheme.bodySmall?.copyWith(
      color: AppColors.mutedText,
      height: 1.35,
    ),
    labelLarge: textTheme.labelLarge?.copyWith(
      color: AppColors.onPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
    labelMedium: textTheme.labelMedium?.copyWith(
      color: AppColors.headline,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelSmall: textTheme.labelSmall?.copyWith(
      color: AppColors.mutedText,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );

  final borderRadius = BorderRadius.circular(14);

  return ThemeData(
    useMaterial3: true,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: resolvedTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.headline,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.alegreyaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.headline,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 24,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainerLow,
      selectedColor: AppColors.primaryContainer,
      disabledColor: AppColors.surfaceVariant,
      labelStyle: GoogleFonts.alegreyaSans(
        color: AppColors.headline,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      secondaryLabelStyle: GoogleFonts.alegreyaSans(
        color: AppColors.bodySecondary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.divider),
      ),
      showCheckmark: false,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.bodySecondary,
      contentTextStyle: GoogleFonts.alegreyaSans(
        color: AppColors.onPrimary,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.alegreyaSans(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.surfaceVariant,
        disabledForegroundColor: AppColors.disabled,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.alegreyaSans(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.headline,
        disabledForegroundColor: AppColors.disabled,
        side: const BorderSide(color: AppColors.outline, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.alegreyaSans(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.alegreyaSans(
        color: AppColors.mutedText,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: GoogleFonts.alegreyaSans(
        color: AppColors.bodySecondary,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: GoogleFonts.alegreyaSans(
        color: AppColors.error,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.headline,
      size: 24,
      grade: 0,
      weight: 400,
    ),
    primaryIconTheme: const IconThemeData(
      color: AppColors.onPrimary,
      size: 24,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      iconSize: 24,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.mutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.alegreyaSans(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.alegreyaSans(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.alegreyaSans(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 12,
          color: selected ? AppColors.primary : AppColors.mutedText,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.primary : AppColors.mutedText,
        );
      }),
    ),
  );
}
