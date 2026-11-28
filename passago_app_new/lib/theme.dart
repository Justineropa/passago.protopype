import 'package:flutter/material.dart';

/// PassaGo design tokens, from the "PassaGo Driver System" file (Stitch).
///
/// Flat Android style: white surfaces, 1px hairline borders, no shadows,
/// small corner radius, no pill shapes. EVERY color in the app comes from
/// this file, so a dark theme can be added later by changing it in one place.
class PG {
  // Brand
  static const plum = Color(0xFF410332); // primary actions
  static const magenta = Color(0xFFAF0088); // active states, accents
  static const pink = Color(0xFFEE008A); // small live-status dots only

  // Text
  static const ink = Color(0xFF000000); // headlines, key numbers
  static const body = Color(0xFF3A3A3D); // body copy
  static const muted = Color(0xFF727270); // secondary text, timestamps

  // Surfaces and lines
  static const canvas = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F3F6); // subtle fill for tags/segments
  static const tint = Color(0xFFFBF8FC); // faint highlight
  static const border = Color(0xFFBCB7B2); // hairlines
  static const borderSoft = Color(0xFFE4E0E3); // very light dividers
  static const disabledFill = Color(0xFFF0EFEF);

  // Magenta at about 10% for small highlights
  static const magentaTint = Color(0x1AAF0088);

  // Safety / warning banner
  static const dangerFill = Color(0xFFFFDAD6);
  static const dangerText = Color(0xFF93000A);

  // QR scan screen (camera view is always dark)
  static const scanBackdrop = Color(0xFF1B1B1E);

  // Shape
  static const radius = 6.0;
  static const radiusSmall = 4.0;
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: PG.plum,
    primary: PG.plum,
    onPrimary: Colors.white,
    secondary: PG.magenta,
    surface: PG.canvas,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PG.canvas,
    // Android's default font is Roboto, the chosen interface font.
    textTheme: Typography.blackMountainView.apply(
      bodyColor: PG.body,
      displayColor: PG.ink,
    ),
    dividerColor: PG.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: PG.canvas,
      foregroundColor: PG.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: PG.body,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? Colors.white : PG.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? PG.magenta : PG.surface,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? PG.magenta
            : PG.border,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? PG.magenta : null,
      ),
      side: const BorderSide(color: PG.border, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PG.radiusSmall),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: PG.canvas,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PG.radius)),
      ),
    ),
  );
}
