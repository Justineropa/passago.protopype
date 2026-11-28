import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../logic/queue_logic.dart';
import '../models.dart';
import '../services/passenger_button_service.dart';

/// What happened when a passenger registration was attempted.
enum RegisterResult {
  /// Counted.
  counted,

  /// No shift is active, so nothing can be recorded.
  noShift,

  /// The same device press arrived twice. Counted once.
  duplicate,

  /// An app tap right after a device press. Treated as the same passenger.
  sameAsDevicePress,
}

/// Everything the screens share: the signed-in driver, the shift and quota,
/// the driver's phase (idle / in queue / on trip / on break), the queue,
/// the trip history and the Bluetooth button.
///
/// The main rules (from the agreed workflow):
///  * A passenger registration comes from the physical button or the +1
///    button in the app. The app button works with no device at all.
///  * The FIRST registration starts a trip. The driver leaves the queue
///    (if in it) and the app shows Trip mode. A street pickup works the same.
///  * The driver ends the trip. Then the driver is idle and may join the queue
///    again by scanning the terminal QR code.
///  * The shift ends when the quota is reached (after the current trip), when
///    the driver ends it, or when the scheduled hours run out.
class AppState extends ChangeNotifier {
  AppState(this._button, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now {
    _trips = MockData.history(_now());
    _eventSub = _button.events.listen(_onButtonEvent);
    _connectionSub = _button.connection.listen((_) => notifyListeners());
  }

  final PassengerButtonService _button;
  final DateTime Function() _now;
  late final StreamSubscription<ButtonEvent> _eventSub;
  late final StreamSubscription<ButtonConnection> _connectionSub;

  /// An app tap this soon after a device press is ignored (same passenger).
  static const doubleCountWindow = Duration(seconds: 2);

  // ---------------------------------------------------------------- session
  bool signedIn = false;
  final String driverName = MockData.driverName;
  final String driverBodyNo = MockData.driverBodyNo;

  /// Which bottom tab is open (0 Dashboard, 1 Distribution, 2 Trips).
  int tabIndex = 0;

  /// Settings: larger text for easier reading.
  bool largeText = false;

  void setLargeText(bool value) {
    largeText = value;
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  void signIn() {
    signedIn = true;
    notifyListeners();
  }

  void signOut() {
    _clearShift();
    summary = null;
    signedIn = false;
    tabIndex = 0;
    _button.disconnect();
    notifyListeners();
  }

  // ------------------------------------------------------------------ shift
  Shift? _shift;
  int quota = 0;
  int shiftPassengers = 0;
  int shiftTripCount = 0;
  DateTime? _shiftStartedAt;
  bool _startedInsideWindow = false;
  Timer? _scheduleTimer;
  DriverPhase phase = DriverPhase.idle;

  /// Set when a shift ends, until the driver taps Done.
  ShiftSummary? summary;

  Shift? get shift => _shift;
  bool get shiftActive => _shift != null;
  DateTime? get shiftStartedAt => _shiftStartedAt;
  bool get quotaReached => shiftActive && shiftPassengers >= quota;

  Duration get onDuty => _shiftStartedAt == null
      ? Duration.zero
      : _now().difference(_shiftStartedAt!);

  /// Starts a shift. Passenger counts reset at shift start.
  void startShift(Shift shift, int quota) {
    final now = _now();
    _shift = shift;
    this.quota = quota < 1 ? 1 : quota;
    shiftPassengers = 0;
    shiftTripCount = 0;
    _shiftStartedAt = now;
    // The shift only ends by itself at its scheduled end time if the driver
    // started it inside its scheduled hours. This keeps demos from ending
    // immediately when a shift is started outside its hours.
    _startedInsideWindow = now.hour >= shift.startHour && now.hour < shift.endHour;
    phase = DriverPhase.idle;
    _line = MockData.sampleLine();
    _handledEventIds.clear();
    _lastButtonAt = null;
    _tripStartedAt = null;
    tripPassengers = 0;
    summary = null;
    tabIndex = 0;
    _scheduleTimer?.cancel();
    _scheduleTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkScheduledEnd(),
    );
    notifyListeners();
  }

  /// The quota can only go up during a shift.
  bool raiseQuota(int newQuota) {
    if (!shiftActive || newQuota <= quota) return false;
    quota = newQuota;
    notifyListeners();
    return true;
  }

  /// Ends the shift on the driver's request. Not possible during a trip.
  bool endShiftManually() {
    if (!shiftActive || phase == DriverPhase.onTrip) return false;
    _endShift(ShiftEndReason.manual);
    return true;
  }

  /// Ends the shift if its scheduled hours have run out (and no trip is in
  /// progress). Called every 30 seconds while a shift is active.
  void checkScheduledEnd() {
    if (!shiftActive || phase == DriverPhase.onTrip) return;
    if (_scheduleElapsed()) _endShift(ShiftEndReason.scheduledHours);
  }

  bool _scheduleElapsed() {
    final started = _shiftStartedAt;
    final shift = _shift;
    if (!_startedInsideWindow || started == null || shift == null) return false;
    final end = DateTime(started.year, started.month, started.day, shift.endHour);
    return !_now().isBefore(end);
  }

  void _endShift(ShiftEndReason reason) {
    final shift = _shift;
    final started = _shiftStartedAt;
    if (shift == null || started == null) return;
    summary = ShiftSummary(
      driverName: driverName,
      bodyNo: driverBodyNo,
      shift: shift,
      quota: quota,
      passengers: shiftPassengers,
      trips: shiftTripCount,
      duration: _now().difference(started),
      reason: reason,
    );
    _clearShift();
    notifyListeners();
  }

  /// Done on the shift summary screen.
  void dismissSummary() {
    summary = null;
    notifyListeners();
  }

  void _clearShift() {
    _scheduleTimer?.cancel();
    _scheduleTimer = null;
    _shift = null;
    quota = 0;
    shiftPassengers = 0;
    shiftTripCount = 0;
    _shiftStartedAt = null;
    _startedInsideWindow = false;
    phase = DriverPhase.idle;
    _line = [];
    _tripStartedAt = null;
    tripPassengers = 0;
  }

  // ------------------------------------------------------------------ queue
  List<QueueEntry> _line = [];

  /// The terminal line in arrival order (includes the driver when in queue).
  List<QueueEntry> get line => List.unmodifiable(_line);

  /// Who goes next under the hybrid rule (first 3 in line, fewest passengers).
  QueueEntry? get nextInLine => pickNext(_line);

  int? get myPosition => positionOf(_line, _myId);

  static const _myId = 'me';

  /// Joins the end of the line. The terminal QR scan must succeed first
  /// (that check is done by the QR screen).
  bool joinQueue() {
    if (!shiftActive) return false;
    if (phase != DriverPhase.idle && phase != DriverPhase.onBreak) return false;
    _line.add(QueueEntry(
      id: _myId,
      name: driverName,
      bodyNo: driverBodyNo,
      passengers: shiftPassengers,
      isMe: true,
    ));
    phase = DriverPhase.inQueue;
    notifyListeners();
    return true;
  }

  void leaveQueue() {
    if (phase != DriverPhase.inQueue) return;
    _line.removeWhere((e) => e.id == _myId);
    phase = DriverPhase.idle;
    notifyListeners();
  }

  /// Break on or off. Starting a break removes the driver from the queue.
  void setBreak(bool onBreak) {
    if (!shiftActive || phase == DriverPhase.onTrip) return;
    if (onBreak) {
      _line.removeWhere((e) => e.id == _myId);
      phase = DriverPhase.onBreak;
    } else if (phase == DriverPhase.onBreak) {
      phase = DriverPhase.idle;
    }
    notifyListeners();
  }

  // ------------------------------------------------------- counting and trips
  final Set<String> _handledEventIds = {};
  DateTime? _lastButtonAt;
  DateTime? _tripStartedAt;
  TripOrigin _tripOrigin = TripOrigin.street;
  int tripPassengers = 0;

  TripOrigin get tripOrigin => _tripOrigin;
  DateTime? get tripStartedAt => _tripStartedAt;

  /// Registers one passenger, from the physical button ([fromButton]) or the
  /// +1 button in the app. The first registration starts a trip.
  RegisterResult registerPassenger({
    required bool fromButton,
    String? eventId,
  }) {
    if (!shiftActive) return RegisterResult.noShift;
    final now = _now();

    if (fromButton) {
      if (eventId != null && !_handledEventIds.add(eventId)) {
        return RegisterResult.duplicate;
      }
      _lastButtonAt = now;
    } else {
      // With the device connected, a tap right after a device press is the
      // same passenger, not a new one.
      final last = _lastButtonAt;
      if (_button.currentConnection == ButtonConnection.connected &&
          last != null &&
          now.difference(last) < doubleCountWindow) {
        return RegisterResult.sameAsDevicePress;
      }
    }

    if (phase != DriverPhase.onTrip) {
      // The first registration starts a trip.
      _tripOrigin = phase == DriverPhase.inQueue
          ? TripOrigin.terminal
          : TripOrigin.street;
      if (phase == DriverPhase.inQueue) dispatch(_line, _myId);
      phase = DriverPhase.onTrip;
      _tripStartedAt = now;
      tripPassengers = 0;
    }

    tripPassengers++;
    shiftPassengers++;
    notifyListeners();
    return RegisterResult.counted;
  }

  /// Ends the current trip and records it. If the quota was reached (or the
  /// scheduled hours ran out) during the trip, the shift ends now.
  void endTrip() {
    final shift = _shift;
    if (phase != DriverPhase.onTrip || shift == null) return;
    final started = _tripStartedAt ?? _now();
    var minutes = _now().difference(started).inMinutes;
    if (minutes < 1) minutes = 1;

    _trips.insert(
      0,
      TripRecord(
        startedAt: started,
        minutes: minutes,
        passengers: tripPassengers,
        origin: _tripOrigin,
        shift: shift,
      ),
    );
    shiftTripCount++;
    tripPassengers = 0;
    _tripStartedAt = null;
    phase = DriverPhase.idle;

    if (quotaReached) {
      _endShift(ShiftEndReason.quotaReached);
    } else if (_scheduleElapsed()) {
      _endShift(ShiftEndReason.scheduledHours);
    } else {
      notifyListeners();
    }
  }

  // ---------------------------------------------------------- trip history
  List<TripRecord> _trips = [];

  /// All recorded trips, newest first (earlier sample trips included).
  List<TripRecord> get trips => List.unmodifiable(_trips);

  // ------------------------------------------------------- Bluetooth button
  ButtonConnection get connection => _button.currentConnection;
  int? get batteryPercent => _button.batteryPercent;
  bool get lowBattery => batteryPercent != null && batteryPercent! < 20;

  /// The explanation screens are shown once per session, before the system
  /// permission request (added with the real Bluetooth and camera code).
  bool bluetoothExplained = false;
  bool cameraExplained = false;

  Future<void> connectButton() => _button.connect();

  Future<void> disconnectButton() async {
    await _button.disconnect();
    notifyListeners();
  }

  Future<void> _onButtonEvent(ButtonEvent event) async {
    final result = registerPassenger(fromButton: true, eventId: event.id);
    // Acknowledge only once the press is recorded (or was already recorded).
    // The ESP32 shows REGISTERED on its OLED only after this.
    if (result == RegisterResult.counted ||
        result == RegisterResult.duplicate) {
      await _button.acknowledge(event.id);
    }
  }

  // ------------------------------------------------------------ demo tools
  int _cycleCount = 0;

  /// Demo: another driver loads a passenger and leaves the front of the line,
  /// and a driver comes back at the end with a few more passengers.
  void simulateDriverCycle() {
    if (!shiftActive) return;
    final others = _line.where((e) => !e.isMe).toList();
    if (others.isEmpty) return;
    final picked = pickNext(_line);
    final QueueEntry chosen =
        (picked == null || picked.isMe) ? others.first : picked;
    dispatch(_line, chosen.id);
    _cycleCount++;
    _line.add(QueueEntry(
      id: chosen.id,
      name: chosen.name,
      bodyNo: chosen.bodyNo,
      passengers: chosen.passengers + 1 + (_cycleCount % 3),
    ));
    notifyListeners();
  }

  /// Demo: the Bluetooth link drops, then returns after a few seconds.
  void simulateConnectionLoss() {
    final service = _button;
    if (service is SimulatedButtonService) service.dropConnection();
  }

  /// Demo: back to the start (signed out, sample data restored).
  void resetDemo() {
    _clearShift();
    summary = null;
    _trips = MockData.history(_now());
    signedIn = false;
    tabIndex = 0;
    _button.disconnect();
    notifyListeners();
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    _eventSub.cancel();
    _connectionSub.cancel();
    _button.dispose();
    super.dispose();
  }
}

/// Gives every screen access to [AppState] with `AppScope.of(context)`.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found above this widget');
    return scope!.notifier!;
  }
}
