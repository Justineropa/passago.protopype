import '../models.dart';

/// ALL sample data lives in this one file. Everything here is PLACEHOLDER
/// data for the school prototype. Change the names here and every screen
/// updates. Replace this file with real data (for example Firebase) later.
class MockData {
  static const terminalName = 'Poblacion Market Terminal';

  // The signed-in driver.
  static const driverName = 'Ramon Dela Cruz';
  static const driverBodyNo = '127';

  /// The other drivers already waiting in the line, in arrival order.
  /// A new list each call, because the queue logic changes the entries.
  static List<QueueEntry> sampleLine() => [
        QueueEntry(
            id: 'd1', name: 'Jun Bautista', bodyNo: '089', passengers: 4),
        QueueEntry(
            id: 'd2', name: 'Arnel Santos', bodyNo: '214', passengers: 2),
        QueueEntry(
            id: 'd3', name: 'Edwin Reyes', bodyNo: '056', passengers: 5),
        QueueEntry(
            id: 'd4', name: 'Mario Lopez', bodyNo: '033', passengers: 3),
      ];

  /// Earlier trips, so Trip Records has something to show. Newest first.
  static List<TripRecord> history(DateTime now) {
    DateTime at(int daysAgo, int hour, int minute) {
      final day = now.subtract(Duration(days: daysAgo));
      return DateTime(day.year, day.month, day.day, hour, minute);
    }

    final all = [
      TripRecord(
          startedAt: at(0, 7, 18),
          minutes: 14,
          passengers: 2,
          origin: TripOrigin.terminal,
          shift: Shift.am),
      TripRecord(
          startedAt: at(0, 8, 5),
          minutes: 9,
          passengers: 1,
          origin: TripOrigin.street,
          shift: Shift.am),
      TripRecord(
          startedAt: at(1, 15, 12),
          minutes: 18,
          passengers: 3,
          origin: TripOrigin.terminal,
          shift: Shift.pm),
      TripRecord(
          startedAt: at(1, 6, 30),
          minutes: 11,
          passengers: 2,
          origin: TripOrigin.terminal,
          shift: Shift.am),
      TripRecord(
          startedAt: at(4, 10, 5),
          minutes: 16,
          passengers: 3,
          origin: TripOrigin.street,
          shift: Shift.am),
      TripRecord(
          startedAt: at(12, 14, 40),
          minutes: 20,
          passengers: 2,
          origin: TripOrigin.terminal,
          shift: Shift.pm),
    ];
    all.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return all;
  }
}
