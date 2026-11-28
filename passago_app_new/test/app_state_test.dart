import 'package:flutter_test/flutter_test.dart';
import 'package:passago_app/models.dart';
import 'package:passago_app/services/passenger_button_service.dart';
import 'package:passago_app/state/app_state.dart';

void main() {
  late SimulatedButtonService button;
  late AppState state;
  late DateTime now;

  setUp(() {
    button = SimulatedButtonService();
    now = DateTime(2026, 11, 28, 8, 0); // inside the AM shift
    state = AppState(button, clock: () => now);
  });

  tearDown(() => state.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('nothing can be registered before a shift starts', () {
    final result = state.registerPassenger(fromButton: false);
    expect(result, RegisterResult.noShift);
    expect(state.shiftPassengers, 0);
  });

  test('starting a shift resets counts and sets the quota', () {
    state.startShift(Shift.am, 5);
    state.registerPassenger(fromButton: false);
    expect(state.shiftPassengers, 1);

    state.endTrip();
    state.startShift(Shift.pm, 8);

    expect(state.shiftPassengers, 0);
    expect(state.shiftTripCount, 0);
    expect(state.quota, 8);
    expect(state.shift, Shift.pm);
    expect(state.phase, DriverPhase.idle);
  });

  test('the first registration on the street starts a street trip', () {
    state.startShift(Shift.am, 10);

    state.registerPassenger(fromButton: false);

    expect(state.phase, DriverPhase.onTrip);
    expect(state.tripOrigin, TripOrigin.street);
    expect(state.tripPassengers, 1);

    state.registerPassenger(fromButton: false);
    expect(state.tripPassengers, 2);
    expect(state.shiftPassengers, 2);
  });

  test('registering from the queue starts a terminal trip and leaves the line',
      () {
    state.startShift(Shift.am, 10);
    final before = state.line.length;

    expect(state.joinQueue(), isTrue);
    expect(state.phase, DriverPhase.inQueue);
    expect(state.myPosition, before + 1);

    state.registerPassenger(fromButton: false);

    expect(state.phase, DriverPhase.onTrip);
    expect(state.tripOrigin, TripOrigin.terminal);
    expect(state.myPosition, isNull);
    expect(state.line.length, before);
    // Everyone who was ahead of the driver was skipped once.
    expect(state.line.every((e) => e.skips == 1), isTrue);
  });

  test('ending a trip records it and returns the driver to idle', () {
    state.startShift(Shift.am, 10);
    final tripsBefore = state.trips.length;

    state.registerPassenger(fromButton: false);
    state.registerPassenger(fromButton: false);
    now = now.add(const Duration(minutes: 7));
    state.endTrip();

    expect(state.phase, DriverPhase.idle);
    expect(state.shiftTripCount, 1);
    expect(state.trips.length, tripsBefore + 1);
    expect(state.trips.first.passengers, 2);
    expect(state.trips.first.minutes, 7);
    expect(state.trips.first.origin, TripOrigin.street);
  });

  test('reaching the quota ends the shift only after the trip ends', () {
    state.startShift(Shift.am, 2);

    state.registerPassenger(fromButton: false);
    state.registerPassenger(fromButton: false);
    expect(state.quotaReached, isTrue);
    expect(state.shiftActive, isTrue); // still on the trip

    state.endTrip();

    expect(state.shiftActive, isFalse);
    expect(state.summary, isNotNull);
    expect(state.summary!.reason, ShiftEndReason.quotaReached);
    expect(state.summary!.passengers, 2);
    expect(state.summary!.trips, 1);
  });

  test('the quota can be raised but never lowered', () {
    state.startShift(Shift.am, 5);

    expect(state.raiseQuota(4), isFalse);
    expect(state.raiseQuota(5), isFalse);
    expect(state.quota, 5);

    expect(state.raiseQuota(8), isTrue);
    expect(state.quota, 8);
  });

  test('a break removes the driver from the queue', () {
    state.startShift(Shift.am, 10);
    state.joinQueue();

    state.setBreak(true);

    expect(state.phase, DriverPhase.onBreak);
    expect(state.myPosition, isNull);

    // Joining again after the break goes to the end of the line.
    expect(state.joinQueue(), isTrue);
    expect(state.myPosition, state.line.length);
  });

  test('a passenger registered during a break starts a street trip', () {
    state.startShift(Shift.am, 10);
    state.setBreak(true);

    state.registerPassenger(fromButton: false);

    expect(state.phase, DriverPhase.onTrip);
    expect(state.tripOrigin, TripOrigin.street);
  });

  test('during a trip: no break, no joining, no ending the shift', () {
    state.startShift(Shift.am, 10);
    state.registerPassenger(fromButton: false);

    state.setBreak(true);
    expect(state.phase, DriverPhase.onTrip);
    expect(state.joinQueue(), isFalse);
    expect(state.endShiftManually(), isFalse);
    expect(state.shiftActive, isTrue);
  });

  test('ending the shift manually creates a manual summary', () {
    state.startShift(Shift.am, 10);
    state.registerPassenger(fromButton: false);
    state.endTrip();

    expect(state.endShiftManually(), isTrue);

    expect(state.shiftActive, isFalse);
    expect(state.summary!.reason, ShiftEndReason.manual);

    state.dismissSummary();
    expect(state.summary, isNull);
  });

  test('the shift ends at its scheduled hour when started inside its hours',
      () {
    state.startShift(Shift.am, 10); // started 8:00, AM ends 13:00

    now = DateTime(2026, 11, 28, 12, 59);
    state.checkScheduledEnd();
    expect(state.shiftActive, isTrue);

    now = DateTime(2026, 11, 28, 13, 0);
    state.checkScheduledEnd();
    expect(state.shiftActive, isFalse);
    expect(state.summary!.reason, ShiftEndReason.scheduledHours);
  });

  test('a shift started outside its hours does not end by itself', () {
    now = DateTime(2026, 11, 28, 20, 0); // 8 PM, outside the AM hours
    state.startShift(Shift.am, 10);

    now = DateTime(2026, 11, 28, 22, 0);
    state.checkScheduledEnd();

    expect(state.shiftActive, isTrue);
  });

  test('the scheduled end waits for a trip in progress', () {
    state.startShift(Shift.pm, 10);
    now = DateTime(2026, 11, 28, 14, 0);
    state.startShift(Shift.pm, 10); // restart inside PM hours
    state.registerPassenger(fromButton: false);

    now = DateTime(2026, 11, 28, 21, 5);
    state.checkScheduledEnd();
    expect(state.shiftActive, isTrue);

    state.endTrip();
    expect(state.shiftActive, isFalse);
    expect(state.summary!.reason, ShiftEndReason.scheduledHours);
  });

  group('Bluetooth button', () {
    setUp(() async {
      await button.connect();
    });

    test('one press counts once and is acknowledged', () async {
      state.startShift(Shift.am, 10);

      expect(button.press(), isTrue);
      await settle();

      expect(state.shiftPassengers, 1);
      expect(button.acknowledged, contains('sim-1'));
    });

    test('a re-sent press is acknowledged again but counted once', () async {
      state.startShift(Shift.am, 10);
      button.press();
      await settle();

      expect(button.resendLast(), isTrue);
      await settle();

      expect(state.shiftPassengers, 1);
    });

    test('an app tap right after a device press is not counted twice',
        () async {
      state.startShift(Shift.am, 10);
      button.press();
      await settle();

      final result = state.registerPassenger(fromButton: false);

      expect(result, RegisterResult.sameAsDevicePress);
      expect(state.shiftPassengers, 1);

      now = now.add(const Duration(seconds: 3));
      expect(state.registerPassenger(fromButton: false),
          RegisterResult.counted);
      expect(state.shiftPassengers, 2);
    });

    test('a press with no active shift is not acknowledged', () async {
      button.press();
      await settle();

      expect(state.shiftPassengers, 0);
      expect(button.acknowledged, isEmpty);
    });
  });

  test('the app +1 works with no device connected', () {
    state.startShift(Shift.am, 10);
    expect(state.connection, ButtonConnection.disconnected);

    expect(state.registerPassenger(fromButton: false), RegisterResult.counted);
    expect(state.shiftPassengers, 1);
  });

  test('the demo driver cycle keeps the line the same size', () {
    state.startShift(Shift.am, 10);
    final before = state.line.length;

    state.simulateDriverCycle();

    expect(state.line.length, before);
  });
}
