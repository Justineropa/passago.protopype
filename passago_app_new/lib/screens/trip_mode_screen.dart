import 'package:flutter/material.dart';

import '../services/passenger_button_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Trip mode: shown automatically from the first passenger registration until
/// the driver ends the trip. Only the essentials are available: the passenger
/// count, +1, and a press-and-hold End trip button. No navigation, no
/// settings, no back button.
///
/// NOTE: this does not detect whether the vehicle is moving. The warning and
/// the hold-to-end button reduce accidental taps, but it is not a full
/// safety lock (GPS speed detection is listed as future work).
class TripModeScreen extends StatelessWidget {
  const TripModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final connected = state.connection == ButtonConnection.connected;

    return Scaffold(
      appBar: pgAppBar(title: 'Trip mode'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const StatusDot(color: PG.pink),
                const SizedBox(width: 8),
                const Text(
                  'Trip in progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PG.ink,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    'Body No. ${state.driverBodyNo}',
                    style: const TextStyle(fontSize: 13, color: PG.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _SafetyBanner(),
            const SizedBox(height: 14),
            PgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Passengers on this trip',
                    style: TextStyle(fontSize: 14, color: PG.body),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale:
                          Tween<double>(begin: 0.85, end: 1).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      '${state.tripPassengers}',
                      key: ValueKey<int>(state.tripPassengers),
                      style: const TextStyle(
                        fontSize: 72,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: PG.ink,
                      ),
                    ),
                  ),
                  Text(
                    'Shift total: ${state.shiftPassengers} of ${state.quota}',
                    style: const TextStyle(fontSize: 13, color: PG.muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        connected ? Icons.bluetooth_connected : Icons.touch_app,
                        size: 16,
                        color: PG.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          connected
                              ? 'Handlebar button connected'
                              : 'Count passengers with +1',
                          style:
                              const TextStyle(fontSize: 12, color: PG.muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PgButton(
              label: '+1 passenger',
              icon: Icons.add,
              background: PG.magenta,
              height: 88,
              onPressed: () => state.registerPassenger(fromButton: false),
            ),
            if (state.quotaReached) ...[
              const SizedBox(height: 14),
              const PgPanel(
                color: PG.tint,
                borderColor: PG.magenta,
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag_outlined, color: PG.magenta),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You reached your quota. Your shift ends after this '
                        'trip.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: PG.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _HoldToEndButton(onComplete: state.endTrip),
            const SizedBox(height: 8),
            const Text(
              'Stop the vehicle before ending the trip.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: PG.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PG.dangerFill,
        borderRadius: BorderRadius.circular(PG.radius),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: PG.dangerText),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety first',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PG.dangerText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Do not use the phone while driving.',
                  style: TextStyle(fontSize: 14, color: PG.dangerText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Must be held for two seconds. Letting go early cancels, so the trip cannot
/// be ended by an accidental tap.
class _HoldToEndButton extends StatefulWidget {
  const _HoldToEndButton({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_HoldToEndButton> createState() => _HoldToEndButtonState();
}

class _HoldToEndButtonState extends State<_HoldToEndButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
    reverseDuration: const Duration(milliseconds: 250),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        widget.onComplete();
      }
    });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'End trip. Press and hold for 2 seconds.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: PG.canvas,
            borderRadius: BorderRadius.circular(PG.radius),
            border: Border.all(color: PG.plum, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _controller.value,
                      heightFactor: 1,
                      child: const ColoredBox(color: PG.plum),
                    ),
                  ),
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Text(
                    _controller.value > 0.5
                        ? 'Keep holding...'
                        : 'Press and hold to end trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _controller.value > 0.5 ? Colors.white : PG.plum,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
