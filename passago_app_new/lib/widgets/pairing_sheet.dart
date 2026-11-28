import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/permission_explainer_screen.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';

/// Starts connecting the handlebar button: the Bluetooth explanation (once),
/// then the pairing bottom sheet.
Future<void> startDevicePairing(BuildContext context, AppState state) async {
  if (!state.bluetoothExplained) {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            const PermissionExplainerScreen(kind: PermissionKind.bluetooth),
      ),
    );
    if (accepted != true) return;
    state.bluetoothExplained = true;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PairingSheet(state: state),
  );
}

enum _Step { searching, found, connecting }

/// Prototype pairing flow: the simulated device is "found" after a short
/// search. The real Bluetooth version adds the Bluetooth-off and not-found
/// states with the real scan.
class _PairingSheet extends StatefulWidget {
  const _PairingSheet({required this.state});

  final AppState state;

  @override
  State<_PairingSheet> createState() => _PairingSheetState();
}

class _PairingSheetState extends State<_PairingSheet> {
  _Step _step = _Step.searching;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _searchTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _step = _Step.found);
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() => _step = _Step.connecting);
    await widget.state.connectButton();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    switch (_step) {
      case _Step.searching:
        content = const _Status(
          title: 'Looking for your PassaGo button...',
          text: 'Turn the device on and keep it close to your phone.',
          busy: true,
        );
      case _Step.found:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: PG.ink,
              ),
            ),
            const SizedBox(height: 12),
            PgPanel(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth, color: PG.magenta),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PassaGo button',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: PG.ink,
                          ),
                        ),
                        Text(
                          'Ready to connect',
                          style: TextStyle(fontSize: 12, color: PG.muted),
                        ),
                      ],
                    ),
                  ),
                  PgTextButton(label: 'Connect', onPressed: _connect),
                ],
              ),
            ),
          ],
        );
      case _Step.connecting:
        content = const _Status(
          title: 'Connecting...',
          text: 'This takes a few seconds.',
          busy: true,
        );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: content,
          ),
          const SizedBox(height: 18),
          if (_step != _Step.connecting)
            PgButton(
              label: 'Cancel',
              outlined: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.title, required this.text, required this.busy});

  final String title;
  final String text;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 14),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: PG.magenta,
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: PG.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.4, color: PG.body),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
