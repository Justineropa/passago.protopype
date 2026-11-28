import 'package:flutter_test/flutter_test.dart';
import 'package:passago_app/logic/queue_logic.dart';
import 'package:passago_app/models.dart';

QueueEntry e(String id, int passengers, {int skips = 0}) => QueueEntry(
      id: id,
      name: 'Driver $id',
      bodyNo: id,
      passengers: passengers,
      skips: skips,
    );

void main() {
  test('empty line has nobody next', () {
    expect(pickNext([]), isNull);
  });

  test('among the first three, the fewest passengers goes next', () {
    final line = [e('a', 5), e('b', 2), e('c', 4), e('d', 0)];
    // d has the fewest but is 4th in line, so it is not in the window.
    expect(pickNext(line)!.id, 'b');
  });

  test('a tie goes to the driver who arrived first', () {
    final line = [e('a', 3), e('b', 3), e('c', 3)];
    expect(pickNext(line)!.id, 'a');
  });

  test('a driver skipped twice goes next, even with more passengers', () {
    final line = [e('a', 9, skips: 2), e('b', 0), e('c', 1)];
    expect(pickNext(line)!.id, 'a');
  });

  test('a driver skipped once is not yet forced', () {
    final line = [e('a', 9, skips: 1), e('b', 0), e('c', 1)];
    expect(pickNext(line)!.id, 'b');
  });

  test('leaving out of order counts one skip for each driver ahead', () {
    final line = [e('a', 5), e('b', 4), e('c', 1)];
    expect(dispatch(line, 'c'), isTrue);

    expect(line.map((x) => x.id), ['a', 'b']);
    expect(line[0].skips, 1);
    expect(line[1].skips, 1);
  });

  test('the first driver leaving skips nobody', () {
    final line = [e('a', 5), e('b', 4)];
    dispatch(line, 'a');
    expect(line.single.skips, 0);
  });

  test('nobody is skipped more than twice when the pick rule is followed', () {
    // Drivers always leave in the order pickNext chooses.
    final line = [e('a', 9), e('b', 0), e('c', 0), e('d', 0), e('e', 0)];
    var rounds = 0;
    while (line.isNotEmpty) {
      final next = pickNext(line)!;
      for (final x in line) {
        expect(x.skips <= maxSkips, isTrue);
      }
      dispatch(line, next.id);
      rounds++;
      expect(rounds < 20, isTrue);
    }
  });

  test('position is 1-based and null when not in line', () {
    final line = [e('a', 1), e('b', 1)];
    expect(positionOf(line, 'b'), 2);
    expect(positionOf(line, 'z'), isNull);
  });
}
