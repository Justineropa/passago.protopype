import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/passenger_button_service.dart';

/// Holds everything the screens share: who is signed in, the chosen shift,
/// the driver's status, the live passenger count and the queue.
class AppState extends ChangeNotifier {
  AppState(this._button) {
    _eventSub = _button.events.listen(_onButtonEvent);
    _connectionSub = _button.connection.listen((_) => notifyListeners());
  }

  final PassengerButtonService _button;
  late final StreamSubscription<ButtonEvent> _eventSub;
  late final StreamSubscription<ButtonConnection> _connectionSub;

  // ---- Driver and shift ----
  String driverName = MockData.driverName;
  String driverBodyNo = MockData.driverBodyNo;
  Shift shift = Shift.am;
  DriverStatus status = DriverStatus.available;
  DateTime? _shiftStartedAt;

  void signIn() {
    // Prototype: any ID resolves to the placeholder driver. Real
    // authentication (for example Firebase Auth) replaces this later.
    driverName = MockData.driverName;
    driverBodyNo = MockData.driverBodyNo;
  }

  void startShift(Shift chosen) {
    shift = chosen;
    status = DriverStatus.available;
    // Policy shown in the app: passenger counts reset at shift start.
    passengerCount = 0;
    _handledEventIds.clear();
    lastRegisteredAt = null;
    _shiftStartedAt = DateTime.now();
    _offer = MockData.offer;
    notifyListeners();
    connectButton();
  }

  Duration get onDuty => _shiftStartedAt == null
      ? Duration.zero
      : DateTime.now().difference(_shiftStartedAt!);

  void setStatus(DriverStatus value) {
    status = value;
    notifyListeners();
  }

  // ---- Bluetooth button ----
  ButtonConnection get connection => _button.currentConnection;
  int? get batteryPercent => _button.batteryPercent;

  Future<void> connectButton() => _button.connect();

  /// Test helper: pretend the physical button was pressed.
  bool simulateButtonPress() {
    final service = _button;
    if (service is SimulatedButtonService) return service.press();
    return false;
  }

  // ---- Passenger count ----
  int passengerCount = 0;
  DateTime? lastRegisteredAt;
  bool showRegisteredToast = false;
  Timer? _toastTimer;
  final Set<String> _handledEventIds = {};

  Future<void> _onButtonEvent(ButtonEvent event) async {
    // A repeated id is a re-sent event. Count it once, but still acknowledge
    // it so the device stops re-sending.
    if (_handledEventIds.add(event.id)) {
      passengerCount++;
      lastRegisteredAt = event.at;
      showRegisteredToast = true;
      _toastTimer?.cancel();
      _toastTimer = Timer(const Duration(milliseconds: 1600), () {
        showRegisteredToast = false;
        notifyListeners();
      });
      notifyListeners();
    }
    await _button.acknowledge(event.id);
  }

  // ---- Queue ----
  QueueDriver get me => QueueDriver(
        name: driverName,
        bodyNo: driverBodyNo,
        passengers: passengerCount,
        status: status,
        waitMinutes: 12,
      );

  /// Everyone in the terminal, fewest passengers first.
  List<QueueDriver> get queue {
    final all = [...MockData.otherDrivers, me];
    all.sort((a, b) {
      final byPax = a.passengers.compareTo(b.passengers);
      return byPax != 0 ? byPax : a.bodyNo.compareTo(b.bodyNo);
    });
    return all;
  }

  List<QueueDriver> get availableQueue =>
      queue.where((d) => d.status == DriverStatus.available).toList();

  /// 1-based position among available drivers, or null if not available.
  int? get myPosition {
    final index = availableQueue.indexWhere((d) => d.bodyNo == driverBodyNo);
    return index == -1 ? null : index + 1;
  }

  /// Average passengers across the whole terminal (prototype data).
  double get terminalAverage {
    final all = queue;
    final total = all.fold<int>(0, (sum, d) => sum + d.passengers);
    return total / all.length;
  }

  /// The next available driver after me, who receives a declined trip.
  QueueDriver? get nextDriverAfterMe {
    for (final d in availableQueue) {
      if (d.bodyNo != driverBodyNo) return d;
    }
    return null;
  }

  // ---- Trip offer ----
  TripOffer? _offer;
  TripOffer? get offer => _offer;

  final List<TripRecord> acceptedTrips = [];

  void acceptOffer() {
    final current = _offer;
    if (current == null) return;
    acceptedTrips.insert(
      0,
      TripRecord(
        daysAgo: 0,
        time: _formatTime(DateTime.now()),
        shift: shift,
        destination: current.destination,
        passengers: current.passengers,
        distanceKm: current.distanceKm,
        turnNo: acceptedTrips.length + 1,
        fare: current.fare,
      ),
    );
    _offer = null;
    status = DriverStatus.onTrip;
    notifyListeners();
  }

  void declineOffer() {
    _offer = null;
    notifyListeners();
  }

  // ---- Trip records ----
  List<TripRecord> get allTrips => [...acceptedTrips, ...MockData.trips];

  List<TripRecord> get todaysTrips => allTrips
      .where((t) => t.daysAgo == 0 && t.shift == shift)
      .toList();

  int get todaysCompletedTrips =>
      todaysTrips.where((t) => !t.cancelled).length;

  int get todaysFares =>
      todaysTrips.fold<int>(0, (sum, t) => sum + t.fare);

  static String _formatTime(DateTime t) {
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:$minute $suffix';
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
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
