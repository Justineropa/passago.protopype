import '../models.dart';

/// The queue rules, kept free of any screen code so they are easy to test.
///
/// The line itself is in ARRIVAL order and never reorders. Only the choice of
/// who goes next uses the passenger counts (the "hybrid" rule):
///
///   * Look at the first [queueWindow] drivers in the line.
///   * A driver who has already been skipped [maxSkips] times goes next.
///   * Otherwise the driver with the FEWEST passengers goes next. On a tie,
///     the one who arrived first.
///
/// This only shows who is next. The app cannot force who gets a passenger.
const int queueWindow = 3;
const int maxSkips = 2;

QueueEntry? pickNext(List<QueueEntry> line) {
  if (line.isEmpty) return null;
  final window = line.take(queueWindow).toList();

  for (final entry in window) {
    if (entry.skips >= maxSkips) return entry;
  }

  var best = window.first;
  for (final entry in window.skip(1)) {
    if (entry.passengers < best.passengers) best = entry;
  }
  return best;
}

/// Removes [id] from the line because that driver left it (loaded a
/// passenger). Every driver who was ahead in the line was skipped once.
/// Returns false if [id] is not in the line.
bool dispatch(List<QueueEntry> line, String id) {
  final index = line.indexWhere((e) => e.id == id);
  if (index == -1) return false;
  for (var i = 0; i < index; i++) {
    line[i].skips++;
  }
  line.removeAt(index);
  return true;
}

/// 1-based position in the line, or null if not in it.
int? positionOf(List<QueueEntry> line, String id) {
  final index = line.indexWhere((e) => e.id == id);
  return index == -1 ? null : index + 1;
}
