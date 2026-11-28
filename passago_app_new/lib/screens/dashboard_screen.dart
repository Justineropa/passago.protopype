import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../services/passenger_button_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Screen 4 of 6: Driver Dashboard.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenQueue,
    required this.onOpenTrips,
  });

  final VoidCallback onOpenQueue;
  final VoidCallback onOpenTrips;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _DriverHeader(state: state),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PassengerCard(state: state),
              const SizedBox(height: 16),
              _QueueCard(state: state, onOpenQueue: onOpenQueue),
              const SizedBox(height: 16),
              _SummaryRow(state: state, onTap: onOpenTrips),
              const SizedBox(height: 20),
              const _DispatchSection(),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PG.hairline)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: state.driverName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: ' • Body No. ${state.driverBodyNo}'
                            ' • ${state.shift.label} shift',
                        style: const TextStyle(
                          color: PG.muted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  text: 'On duty: ',
                  style: const TextStyle(fontSize: 12, color: PG.secondary),
                  children: [
                    TextSpan(
                      text: durationLabel(state.onDuty),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: PG.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatusSelector(
            value: state.status,
            onChanged: state.setStatus,
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.value, required this.onChanged});

  final DriverStatus value;
  final ValueChanged<DriverStatus> onChanged;

  static const _labels = {
    DriverStatus.available: 'Available',
    DriverStatus.onTrip: 'On trip',
    DriverStatus.onBreak: 'Break',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PG.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final status in DriverStatus.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(status),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: status == value ? PG.plum : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _labels[status]!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: status == value ? Colors.white : PG.secondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PassengerCard extends StatelessWidget {
  const _PassengerCard({required this.state});

  final AppState state;

  String _lastRegistered() {
    final at = state.lastRegisteredAt;
    if (at == null) return 'No passengers registered yet';
    final minutes = DateTime.now().difference(at).inMinutes;
    if (minutes < 1) return 'Last registered: just now';
    return 'Last registered: $minutes min${minutes == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final connected = state.connection == ButtonConnection.connected;

    return PgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConnectionRow(state: state),
          const Divider(height: 24, color: PG.hairline),
          const Text(
            "Today's live passenger count",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: PG.secondary),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(
                  '${state.passengerCount}',
                  key: ValueKey<int>(state.passengerCount),
                  style: const TextStyle(
                    fontSize: 56,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'passengers',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: PG.body),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: state.showRegisteredToast ? 1 : 0,
                child: const PgPill(
                  '+1 registered',
                  background: PG.magentaTint,
                  color: PG.magenta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.history, size: 14, color: PG.muted),
              const SizedBox(width: 4),
              Text(_lastRegistered(),
                  style: const TextStyle(fontSize: 12, color: PG.muted)),
            ],
          ),
          const SizedBox(height: 14),
          PgButton(
            label: 'Simulate handlebar click (+1 passenger)',
            icon: Icons.touch_app,
            height: 52,
            onPressed: connected ? () => state.simulateButtonPress() : null,
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Pressing the physical handlebar button updates this count '
              'automatically once the device is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: PG.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatefulWidget {
  const _ConnectionRow({required this.state});

  final AppState state;

  @override
  State<_ConnectionRow> createState() => _ConnectionRowState();
}

class _ConnectionRowState extends State<_ConnectionRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _ConnectionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  /// Only pulse while connecting or connected, and never when the phone
  /// has animations turned off.
  void _syncPulse() {
    final active =
        widget.state.connection != ButtonConnection.disconnected &&
            !MediaQuery.disableAnimationsOf(context);
    if (active && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!active && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final connection = state.connection;

    final label = switch (connection) {
      ButtonConnection.connected => 'Handlebar button connected',
      ButtonConnection.connecting => 'Connecting to handlebar button…',
      ButtonConnection.disconnected => 'Handlebar button not connected',
    };
    final dotColor = connection == ButtonConnection.connected
        ? PG.magenta
        : (connection == ButtonConnection.connecting ? PG.plum : PG.muted);

    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => Opacity(
                  opacity: connection == ButtonConnection.disconnected
                      ? 0
                      : 0.45 * (1 - _pulse.value),
                  child: Transform.scale(
                    scale: 0.6 + _pulse.value * 0.8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration:
                          BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              key: ValueKey<String>(label),
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        if (connection == ButtonConnection.disconnected)
          TextButton(
            onPressed: state.connectButton,
            style: TextButton.styleFrom(
              foregroundColor: PG.magenta,
              minimumSize: const Size(48, 40),
            ),
            child: const Text('Reconnect'),
          )
        else if (state.batteryPercent != null)
          Row(
            children: [
              const Icon(Icons.battery_5_bar, size: 16, color: PG.muted),
              const SizedBox(width: 2),
              Text(
                '${state.batteryPercent}% battery',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: PG.secondary),
              ),
            ],
          ),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.state, required this.onOpenQueue});

  final AppState state;
  final VoidCallback onOpenQueue;

  @override
  Widget build(BuildContext context) {
    final position = state.myPosition;
    final available = state.availableQueue.length;
    final average = state.terminalAverage;
    final served = state.passengerCount;
    final difference = average - served;

    String note;
    if (position == null) {
      note = 'You are not in the queue while your status is not Available.';
    } else if (difference >= 1) {
      final n = difference.round();
      note = 'You have $n passenger${n == 1 ? '' : 's'} fewer than the '
          'terminal average, so you are prioritized in the queue.';
    } else {
      note = 'You are at or above the terminal average, so drivers with '
          'fewer passengers are served before you.';
    }

    return PgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionLabel('Fair turn queue position'),
              PgPill('Live Terminal'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                position == null ? 'Not in queue' : '#$position in line',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text(
                'of $available available drivers',
                style: const TextStyle(fontSize: 14, color: PG.secondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PG.tint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PG.hairline),
            ),
            child: Text.rich(
              TextSpan(
                text: 'You served: ',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: PG.body),
                children: [
                  TextSpan(
                    text: '$served pax',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: PG.ink),
                  ),
                  const TextSpan(text: '  •  Terminal avg: '),
                  TextSpan(
                    text: '${average.round()} pax',
                    style: const TextStyle(color: PG.secondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            note,
            style: const TextStyle(
                fontSize: 12, height: 1.45, color: PG.secondary),
          ),
          const SizedBox(height: 12),
          PgButton(
            label: 'View queue board',
            icon: Icons.format_list_numbered,
            outlined: true,
            height: 48,
            onPressed: onOpenQueue,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state, required this.onTap});

  final AppState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget cell(String value, String label) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: PG.muted)),
              ],
            ),
          ),
        );

    return PgCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          children: [
            cell('${state.todaysCompletedTrips}', 'Trips'),
            const VerticalDivider(width: 1, color: PG.hairline),
            cell('${state.passengerCount}', 'Passengers'),
            const VerticalDivider(width: 1, color: PG.hairline),
            cell('₱${state.todaysFares}', 'Total fares'),
          ],
        ),
      ),
    );
  }
}

class _DispatchSection extends StatelessWidget {
  const _DispatchSection();

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String lead, String text) => Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PG.hairline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: lead,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, height: 1.35),
                    children: [
                      TextSpan(
                        text: text,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, color: PG.body),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Live dispatch & traffic'),
        row(Icons.commute, 'Terminal dispatch: ', MockData.dispatchSummary),
        row(Icons.info_outline, '', MockData.advisory),
      ],
    );
  }
}
