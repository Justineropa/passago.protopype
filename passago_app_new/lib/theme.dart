import 'package:material_ui/material_ui.dart';

/// PassaGo brand colors, taken from the approved palette and Stitch designs.
/// White dominates. Plum is the main brand color, magenta is a sparing accent.
class PG {
  static const plum = Color(0xFF410332);
  static const plumDark = Color(0xFF2B0021);
  static const magenta = Color(0xFFAF0088);
  static const pink = Color(0xFFEE008A);

  static const ink = Color(0xFF1B1B1E);
  static const body = Color(0xFF3A3A3D);
  static const secondary = Color(0xFF51434A);
  static const muted = Color(0xFF83737A);

  static const border = Color(0xFFEBE7EC);
  static const borderStrong = Color(0xFFD5C1CA);
  static const hairline = Color(0xFFF0EEF2);
  static const surface = Color(0xFFF5F3F6);
  static const tint = Color(0xFFFBF8FC);

  /// Magenta at 10% opacity, for small badges.
  static const magentaTint = Color(0x1AAF0088);

  /// Soft background used on Welcome, Login and Schedule (from the designs).
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBF8FA), Color(0xFFF5EFF5), Color(0xFFEDE6EE)],
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: PG.plum,
    primary: PG.plum,
    onPrimary: Colors.white,
    secondary: PG.magenta,
    surface: Colors.white,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    // Android's default font is Roboto, which is the chosen interface font.
    textTheme: Typography.blackMountainView.apply(
      bodyColor: PG.ink,
      displayColor: PG.ink,
    ),
    splashFactory: InkRipple.splashFactory,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: PG.magentaTint,
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? PG.plum : PG.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? PG.plum : PG.muted, size: 24);
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: PG.ink,
    ),
  );
}
