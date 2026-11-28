/// Plain data types shared by the logic and the screens.

enum Shift { am, pm }

extension ShiftInfo on Shift {
  String get label => this == Shift.am ? 'AM' : 'PM';
  int get startHour => this == Shift.am ? 5 : 13;
  int get endHour => this == Shift.am ? 13 : 21;
  String get hours =>
      this == Shift.am ? '5:00 AM - 1:00 PM' : '1:00 PM - 9:00 PM';
}

/// What the driver is doing right now (while a shift is active).
enum DriverPhase {
  /// On shift, not in the queue, not carrying passengers.
  idle,

  /// Waiting in the terminal line.
  inQueue,

  /// Carrying passengers. The app shows Trip mode.
  onTrip,

  /// Resting. Not in the queue.
  onBreak,
}

enum TripOrigin { terminal, street }

enum ShiftEndReason { quotaReached, manual, scheduledHours }

/// One driver in the terminal line.
class QueueEntry {
  QueueEntry({
    required this.id,
    required this.name,
    required this.bodyNo,
    required this.passengers,
    this.skips = 0,
    this.isMe = false,
  });

  final String id;
  final String name;
  final String bodyNo;

  /// Passengers registered this shift.
  int passengers;

  /// How many times a driver behind this one left first. A driver who was
  /// skipped twice goes next (see queue_logic.dart).
  int skips;

  final bool isMe;
}

/// A finished trip (one or more passengers carried).
class TripRecord {
  const TripRecord({
    required this.startedAt,
    required this.minutes,
    required this.passengers,
    required this.origin,
    required this.shift,
  });

  final DateTime startedAt;
  final int minutes;
  final int passengers;
  final TripOrigin origin;
  final Shift shift;
}

/// Shown on the shift summary screen.
class ShiftSummary {
  const ShiftSummary({
    required this.driverName,
    required this.bodyNo,
    required this.shift,
    required this.quota,
    required this.passengers,
    required this.trips,
    required this.duration,
    required this.reason,
  });

  final String driverName;
  final String bodyNo;
  final Shift shift;
  final int quota;
  final int passengers;
  final int trips;
  final Duration duration;
  final ShiftEndReason reason;
}
