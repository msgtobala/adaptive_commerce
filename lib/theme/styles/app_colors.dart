import 'package:flutter/material.dart';

/// Design tokens for **Happy Paws** — aligned with the pet-store landing palette
/// (#5F1606, #662113, #F5F2EC, #8E594E, #FFFFFF) and the
/// [Figma community reference](https://www.figma.com/design/q28CrmRWnz85eekjk31kZv/Landing-page-for-Pet-food-store--Community-?node-id=1-3).
///
/// Figma variable sync: `get_variable_defs` returned no remote tokens; names below
/// map to the mockup roles (background, headline, primary CTA, secondary copy).
abstract final class AppColors {
  AppColors._();

  // --- Raw palette (from design) ---

  /// Darkest brown — logo, headlines, nav outlines, social icon circles.
  static const Color burgundy = Color(0xFF5F1606);

  /// Deep brown — supporting body / subcopy.
  static const Color deepBrown = Color(0xFF662113);

  /// Light beige — page / scaffold background.
  static const Color beige = Color(0xFFF5F2EC);

  /// Medium brown — primary actions, filled nav “Home”, hero CTA fill.
  static const Color clay = Color(0xFF8E594E);

  /// Pure white — text on filled buttons, icons on dark chips.
  static const Color white = Color(0xFFFFFFFF);

  // --- Semantic aliases (use in UI & theme) ---

  static const Color background = beige;

  /// Default **card / sheet / nav bar** surface (white on beige).
  /// Wired to [ThemeData.cardTheme] and `ColorScheme.surface`.
  static const Color surface = Color(0xFFFFFFFF);

  /// Softer panel: **text fields**, chips (disabled), and low-emphasis blocks.
  /// Use [surface] for primary cards if you want a cleaner lift off [background].
  static const Color surfaceVariant = Color(0xFFFFFBF7);
  static const Color headline = burgundy;
  static const Color bodySecondary = deepBrown;
  /// “Quiet” text for hints, captions, and helper labels.
  static const Color mutedText = Color(0xB3662113);
  static const Color primary = clay;
  static const Color onPrimary = white;
  /// Soft fill behind primary-tinted chips / nav indicator.
  static const Color primaryContainer = Color(0xFFE5D5D1);
  /// Muted secondary container for badges / sections.
  static const Color secondaryContainer = Color(0xFFF0E6E3);
  static const Color outline = burgundy;
  static const Color divider = Color(0x33662113);
  static const Color disabled = Color(0x80662113);
  /// Material error (matches [ThemeData] default tone for accessibility).
  static const Color error = Color(0xFFB3261E);

  // --- Status colors (kept minimal & readable on beige) ---
  static const Color success = Color(0xFF1E6B3A);
  static const Color warning = Color(0xFFB25A00);

  // --- Derived surfaces (M3-style layers on [background]) ---
  static const Color surfaceContainerLow = Color(0xFFF9F6F0);
  static const Color surfaceContainer = Color(0xFFF2EDE6);
}
