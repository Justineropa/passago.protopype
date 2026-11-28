import 'dart:async';

/// State of the link between the phone and the ESP32 push-button.
enum ButtonConnection { disconnected, connecting, connected }

/// One press of the physical button.
///
/// [id] must be unique for every press. The app uses it to ignore duplicates,
/// for example when the ESP32 re-sends an event after a Bluetooth reconnect.
class ButtonEvent {
  const ButtonEvent({required this.id, required this.at});

  final String id;
  final DateTime at;
}

/// The only thing the rest of the app knows about the hardware.
///
/// Phase 3 of the plan adds a real implementation of this interface that talks
/// to the ESP32-C3 over Bluetooth Low Energy (phone = central, ESP32 =
/// peripheral). Nothing else in the app has to change when that happens.
///
/// Intended flow (from the project handoff):
///   1. Driver presses the button -> ESP32 sends a [ButtonEvent] with a unique id.
///   2. The app records the passenger.
///   3. The app calls [acknowledge] with that id.
///   4. The ESP32 shows REGISTERED on the OLED only after the acknowledgment.
abstract class PassengerButtonService {
  Stream<ButtonEvent> get events;
  Stream<ButtonConnection> get connection;
  ButtonConnection get currentConnection;

  /// Battery of the handlebar device in percent, or null when unknown.
  int? get batteryPercent;

  Future<void> connect();
  Future<void> disconnect();

  /// Tell the device that the app has recorded the event with [eventId].
  Future<void> acknowledge(String eventId);

  void dispose();
}

/// A fake device so the app can be tested without hardware.
/// It behaves like the real one will: connects after a short delay, emits
/// events with unique ids, and records which events were acknowledged.
class SimulatedButtonService implements PassengerButtonService {
  final _events = StreamController<ButtonEvent>.broadcast();
  final _connection = StreamController<ButtonConnection>.broadcast();

  ButtonConnection _current = ButtonConnection.disconnected;
  int _sequence = 0;

  /// Ids the app has acknowledged. Useful for checking behavior in tests.
  final Set<String> acknowledged = {};

  @override
  Stream<ButtonEvent> get events => _events.stream;

  @override
  Stream<ButtonConnection> get connection => _connection.stream;

  @override
  ButtonConnection get currentConnection => _current;

  // Placeholder value from the design. A real device reports its own battery.
  @override
  int? get batteryPercent =>
      _current == ButtonConnection.connected ? 94 : null;

  void _setConnection(ButtonConnection value) {
    _current = value;
    _connection.add(value);
  }

  @override
  Future<void> connect() async {
    if (_current != ButtonConnection.disconnected) return;
    _setConnection(ButtonConnection.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    // The user may have disconnected while we were "connecting".
    if (_current == ButtonConnection.connecting) {
      _setConnection(ButtonConnection.connected);
    }
  }

  @override
  Future<void> disconnect() async {
    if (_current == ButtonConnection.disconnected) return;
    _setConnection(ButtonConnection.disconnected);
  }

  /// Pretend the driver pressed the physical button.
  /// Returns false if the device is not connected (nothing is sent).
  bool press() {
    if (_current != ButtonConnection.connected) return false;
    _sequence++;
    final event = ButtonEvent(id: 'sim-$_sequence', at: DateTime.now());
    _lastEvent = event;
    _events.add(event);
    return true;
  }

  ButtonEvent? _lastEvent;

  /// Pretend the device re-sent its last event (this happens after a
  /// Bluetooth reconnect). The app must count it only once.
  bool resendLast() {
    final last = _lastEvent;
    if (last == null || _current != ButtonConnection.connected) return false;
    _events.add(last);
    return true;
  }

  @override
  Future<void> acknowledge(String eventId) async {
    acknowledged.add(eventId);
  }

  @override
  void dispose() {
    _events.close();
    _connection.close();
  }
}
