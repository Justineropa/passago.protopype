import 'package:flutter/material.dart';

import '../services/passenger_button_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/pairing_sheet.dart';

/// Settings, opened from the gear icon in the top bar. It is a secondary
/// screen, not one of the six main screens.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final connection = state.connection;

    final String deviceStatus;
    switch (connection) {
      case ButtonConnection.connected:
        deviceStatus = 'Connected';
      case ButtonConnection.connecting:
        deviceStatus = 'Connecting...';
      case ButtonConnection.reconnecting:
        deviceStatus = 'Connection lost - reconnecting';
      case ButtonConnection.disconnected:
        deviceStatus = 'Not connected';
    }

    return Scaffold(
      appBar: pgAppBar(
        title: 'Settings',
        showLogo: false,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionLabel('Driver'),
            const SizedBox(height: 8),
            PgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.driverName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: PG.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Body No. ${state.driverBodyNo}'
                    '${state.shift == null ? '' : ' • ${state.shift!.label} shift'}',
                    style: const TextStyle(fontSize: 13, color: PG.muted),
                  ),
                  const SizedBox(height: 14),
                  PgButton(
                    label: 'Sign out',
                    outlined: true,
                    height: 48,
                    onPressed: () {
                      state.signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionLabel('Handlebar button'),
            const SizedBox(height: 8),
            PgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bluetooth, color: PG.magenta),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          deviceStatus,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: PG.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (connection == ButtonConnection.disconnected) ...[
                    const SizedBox(height: 14),
                    PgButton(
                      label: 'Connect',
                      height: 48,
                      onPressed: () => startDevicePairing(context, state),
                    ),
                  ] else if (connection == ButtonConnection.connected) ...[
                    const SizedBox(height: 14),
                    PgButton(
                      label: 'Forget device',
                      outlined: true,
                      height: 48,
                      onPressed: state.disconnectButton,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionLabel('Text size'),
            const SizedBox(height: 8),
            PgSegmented(
              labels: const ['Normal', 'Large'],
              selected: state.largeText ? 1 : 0,
              onChanged: (i) => state.setLargeText(i == 1),
            ),
            const SizedBox(height: 22),
            const SectionLabel('About'),
            const SizedBox(height: 8),
            const PgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PassaGo prototype',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: PG.ink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Drivers with fewer passengers are prioritized in the '
                    'queue. Passenger distribution depends on drivers\' own '
                    'records. The app cannot control passengers who hail a '
                    'tricycle on the road.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: PG.body),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionLabel('Demo tools'),
            const SizedBox(height: 8),
            PgButton(
              label: 'Simulate next driver leaving the line',
              outlined: true,
              height: 48,
              onPressed: state.shiftActive ? state.simulateDriverCycle : null,
            ),
            const SizedBox(height: 8),
            PgButton(
              label: 'Simulate Bluetooth connection lost',
              outlined: true,
              height: 48,
              onPressed: connection == ButtonConnection.connected
                  ? state.simulateConnectionLoss
                  : null,
            ),
            const SizedBox(height: 8),
            PgButton(
              label: 'Reset demo data',
              outlined: true,
              height: 48,
              onPressed: () => _confirmReset(context, state),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, AppState state) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Reset demo data?',
      message: 'This ends any shift, restores the sample drivers and trips, '
          'and returns to the start.',
      safeLabel: 'Cancel',
      confirmLabel: 'Reset demo data',
    );
    if (confirmed != true) return;
    state.resetDemo();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
