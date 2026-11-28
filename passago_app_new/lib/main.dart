import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'services/passenger_button_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() {
  runApp(const PassaGoApp());
}

class PassaGoApp extends StatefulWidget {
  const PassaGoApp({super.key});

  @override
  State<PassaGoApp> createState() => _PassaGoAppState();
}

class _PassaGoAppState extends State<PassaGoApp> {
  // The simulated button is used until the real Bluetooth service exists.
  // To switch, replace SimulatedButtonService() with the BLE implementation.
  late final AppState _state = AppState(SimulatedButtonService());

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'PassaGo',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // The app stays in its light design even when the phone is in dark
        // mode. All colors are in theme.dart, so a dark theme can be added
        // later in one place.
        themeMode: ThemeMode.light,
        // The "Text size" setting scales all text.
        builder: (context, child) {
          final large = AppScope.of(context).largeText;
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(large ? 1.2 : 1.0),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const WelcomeScreen(),
      ),
    );
  }
}
