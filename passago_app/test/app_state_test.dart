import 'package:flutter_test/flutter_test.dart';
import 'package:passago_app/data/mock_data.dart';
import 'package:passago_app/services/passenger_button_service.dart';
import 'package:passago_app/state/app_state.dart';

void main() {
  late SimulatedButtonService button;
  late AppState state;

  setUp(() async {
    button = SimulatedButtonService();
    state = AppState(button);
    await button.connect();
  });

  tearDown(() => state.dispose());

  test('one button press registers exactly one passenger and is acknowledged',
      () async {
    expect(state.passengerCount, 0);

    expect(button.press(), isTrue);
    await Future<void>.delayed(Duration.zero);

    expect(state.passengerCount, 1);
    expect(button.acknowledged, contains('sim-1'));
  });

  test('a re-sent event is acknowledged again but counted only once',
      () async {
    button.press();
    await Future<void>.delayed(Duration.zero);

    expect(button.resendLast(), isTrue);
    await Future<void>.delayed(Duration.zero);

    expect(state.passengerCount, 1);
  });

  test('pressing while disconnected sends nothing', () async {
    await button.disconnect();

    expect(button.press(), isFalse);
    await Future<void>.delayed(Duration.zero);

    expect(state.passengerCount, 0);
  });

  test('starting a shift resets the passenger count', () async {
    button.press();
    await Future<void>.delayed(Duration.zero);
    expect(state.passengerCount, 1);

    state.startShift(Shift.pm);

    expect(state.passengerCount, 0);
    expect(state.shift, Shift.pm);
  });

  test('queue puts drivers with fewer passengers first', () {
    final counts = state.queue.map((d) => d.passengers).toList();
    final sorted = [...counts]..sort();
    expect(counts, sorted);
  });

  test('a driver who is not available has no queue position', () {
    state.setStatus(DriverStatus.onBreak);
    expect(state.myPosition, isNull);

    state.setStatus(DriverStatus.available);
    expect(state.myPosition, isNotNull);
  });
}
