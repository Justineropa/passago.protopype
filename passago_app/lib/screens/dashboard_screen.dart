import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models.dart';
import '../services/passenger_button_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/pairing_sheet.dart';
import '../widgets/raise_quota_sheet.dart';
import 'qr_scan_screen.dart';

/// Screen 4 of 6: Driver Dashboard.
///
/// Shown while the driver is NOT on a trip. On a trip the app switches to
/// Trip mode instead (see shift_gate.dart).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Header(state: state),
        const SizedBox(height: 16),
        _DeviceCard(state: state),
        const SizedBox(height: 12),
        _PassengerCard(state: state),
        const SizedBox(height: 12),
        _QueueCard(state: state),
        const SizedBox(height: 20),
        PgButton(
          label: 'End shift',
          outlined: true,
          onPressed: () => _confirmEndShift(context, state),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

Future<void> _confirmEndShift(BuildContext context, AppState state) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'End your shift?',
    message: 'Your passenger count and trips will be saved.',
    detail: PgPanel(
      color: PG.tint,
      borderColor: PG.borderSoft,
      padding: const EdgeInsets.all(12),
      child: Text(
        'Passengers: ${state.shiftPassengers} of ${state.quota}\n'
        'Trips: ${state.shiftTripCount}',
        style: const TextStyle(fontSize: 14, height: 1.5, color: PG.body),
      ),
    ),
    safeLabel: 'Keep driving',
    confirmLabel: 'End shift',
  );
  if (confirmed == true) state.endShiftManually();
}

Future<void> _confirmLeaveQueue(BuildContext context, AppState state) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'Leave the queue?',
    message: 'You will go to the end of the line if you join again.',
    safeLabel: 'Stay in line',
    confirmLabel: 'Leave queue',
  );
  if (confirmed == true) state.leaveQueue();
}

// ------------------------------------------------------------------ header

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  StatusDot(color: PG.pink),
                  SizedBox(width: 6),
                  Text('Active shift',
                      style: TextStyle(fontSize: 12, color: PG.muted)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                state.driverName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: PG.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Body No. ${state.driverBodyNo} • '
                '${state.shift?.label ?? ''} shift • '
                'On duty ${durationLabel(state.onDuty)}',
                style: const TextStyle(fontSize: 13, color: PG.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            const Text('Break',
                style: TextStyle(fontSize: 12, color: PG.muted)),
            Switch(
              value: state.phase == DriverPhase.onBreak,
              onChanged: state.setBreak,
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ device

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final connection = state.connection;

    final String title;
    final String subtitle;
    var subtitleColor = PG.muted;
    switch (connection) {
      case ButtonConnection.connected:
        title = 'Handlebar button connected';
        if (state.lowBattery) {
          subtitle = 'Low battery (${state.batteryPercent}%). Charge soon.';
          subtitleColor = PG.dangerText;
        } else {
          subtitle = state.batteryPercent == null
              ? 'Ready'
              : 'Battery ${state.batteryPercent}%';
        }
      case ButtonConnection.connecting:
        title = 'Connecting to handlebar button...';
        subtitle = 'Keep the device near your phone.';
      case ButtonConnection.reconnecting:
        title = 'Connection lost - reconnecting';
        subtitle = 'Passengers you count in the app are still saved.';
      case ButtonConnection.disconnected:
        title = 'Handlebar button not connected';
        subtitle = 'The +1 button still works without the device.';
    }

    final busy = connection == ButtonConnection.connecting ||
        connection == ButtonConnection.reconnecting;

    return PgPanel(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Icon(
            connection == ButtonConnection.connected
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled,
            color: connection == ButtonConnection.connected
                ? PG.magenta
                : PG.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PG.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: PG.magenta,
                ),
              ),
            )
          else if (connection == ButtonConnection.disconnected)
            PgTextButton(
              label: 'Connect',
              onPressed: () => startDevicePairing(context, state),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- passengers

class _PassengerCard extends StatelessWidget {
  const _PassengerCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final progress = state.quota == 0
        ? 0.0
        : (state.shiftPassengers / state.quota).clamp(0.0, 1.0).toDouble();

    return PgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passengers this shift',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: PG.body),
              ),
              PgTag('Not on a trip'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(
                  '${state.shiftPassengers}',
                  key: ValueKey<int>(state.shiftPassengers),
                  style: const TextStyle(
                    fontSize: 56,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: PG.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'passengers',
                style: TextStyle(fontSize: 16, color: PG.body),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quota: ${state.quota}',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: PG.ink),
              ),
              PgTextButton(
                label: 'Raise quota',
                onPressed: () => showRaiseQuotaSheet(context, state),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(PG.radiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: PG.surface,
              color: PG.magenta,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${state.shiftPassengers} of ${state.quota} passengers',
            style: const TextStyle(fontSize: 12, color: PG.muted),
          ),
          const SizedBox(height: 16),
          PgButton(
            label: '+1 passenger',
            icon: Icons.add,
            height: 56,
            onPressed: () => state.registerPassenger(fromButton: false),
          ),
          const SizedBox(height: 8),
          const Text(
            'Works with or without the handlebar button. Your first '
            'passenger starts a trip.',
            style: TextStyle(fontSize: 12, height: 1.4, color: PG.muted),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- queue

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final Widget body;

    switch (state.phase) {
      case DriverPhase.inQueue:
        final position = state.myPosition ?? 1;
        final next = state.nextInLine;
        final iAmNext = next != null && next.isMe;
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '#$position',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: PG.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'in line of ${state.line.length} drivers',
                    style: const TextStyle(fontSize: 14, color: PG.body),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (iAmNext)
              const PgTag('You are next',
                  background: PG.magentaTint, color: PG.magenta)
            else
              Text(
                next == null
                    ? ''
                    : 'Next: ${next.name} (Body ${next.bodyNo})',
                style: const TextStyle(fontSize: 13, color: PG.muted),
              ),
            const SizedBox(height: 14),
            PgButton(
              label: 'Leave queue',
              outlined: true,
              onPressed: () => _confirmLeaveQueue(context, state),
            ),
          ],
        );
      case DriverPhase.onBreak:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You left the queue. Join again after your break.',
              style: TextStyle(fontSize: 14, height: 1.4, color: PG.body),
            ),
            const SizedBox(height: 14),
            PgButton(
              label: 'Join queue',
              icon: Icons.qr_code_scanner,
              onPressed: () => openQrScan(context, state),
            ),
          ],
        );
      case DriverPhase.idle:
      case DriverPhase.onTrip:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are not in the queue. Scan the terminal QR code to join '
              'the end of the line.',
              style: TextStyle(fontSize: 14, height: 1.4, color: PG.body),
            ),
            const SizedBox(height: 14),
            PgButton(
              label: 'Join queue',
              icon: Icons.qr_code_scanner,
              onPressed: () => openQrScan(context, state),
            ),
          ],
        );
    }

    return PgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Terminal queue'),
          const SizedBox(height: 2),
          const Text(
            MockData.terminalName,
            style: TextStyle(fontSize: 13, color: PG.muted),
          ),
          const SizedBox(height: 12),
          body,
        ],
      ),
    );
  }
}
