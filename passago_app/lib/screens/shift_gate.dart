import 'package:flutter/material.dart';

import '../models.dart';
import '../state/app_state.dart';
import 'main_shell.dart';
import 'schedule_screen.dart';
import 'shift_summary_screen.dart';
import 'trip_mode_screen.dart';

/// Decides which screen to show after login, from the app state:
///
///  * shift summary, right after a shift ends
///  * Schedule Selection, when no shift is active
///  * Trip mode, while the driver is on a trip
///  * the main screens (Dashboard / Distribution / Trips) otherwise
///
/// Because the state decides, Trip mode appears the moment the first
/// passenger is registered, whether from the app or the physical button.
class ShiftGate extends StatelessWidget {
  const ShiftGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final Widget child;
    if (!state.signedIn) {
      child = const SizedBox.shrink();
    } else if (state.summary != null) {
      child = ShiftSummaryScreen(summary: state.summary!);
    } else if (!state.shiftActive) {
      child = const ScheduleScreen();
    } else if (state.phase == DriverPhase.onTrip) {
      child = const TripModeScreen();
    } else {
      child = const MainShell();
    }

    return PopScope(
      // The system back button must never leave a shift or a trip by accident.
      // On the Schedule screen it works like "Cancel and return".
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!state.shiftActive && state.summary == null) {
          state.signOut();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey<Type>(child.runtimeType),
          child: child,
        ),
      ),
    );
  }
}
