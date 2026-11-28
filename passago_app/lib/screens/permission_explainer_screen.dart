import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

enum PermissionKind { bluetooth, camera }

/// A plain explanation shown BEFORE the system permission request, so the
/// driver knows why the permission is needed. Pops with true on Continue and
/// false on Not now.
///
/// The real system request is added together with the camera and Bluetooth
/// code. For now Continue only records that the explanation was seen.
class PermissionExplainerScreen extends StatelessWidget {
  const PermissionExplainerScreen({super.key, required this.kind});

  final PermissionKind kind;

  bool get _isBluetooth => kind == PermissionKind.bluetooth;

  @override
  Widget build(BuildContext context) {
    final title =
        _isBluetooth ? 'Allow Bluetooth access' : 'Allow camera access';
    final text = _isBluetooth
        ? 'PassaGo needs the "Nearby devices" permission to find and connect '
            'to your handlebar button. It is only used to talk to the '
            'button.'
        : 'PassaGo uses the camera only to scan the terminal QR code when '
            'you join the queue. Photos are not taken or saved.';

    return Scaffold(
      appBar: pgAppBar(
        title: _isBluetooth ? 'Bluetooth' : 'Camera',
        showLogo: false,
        onBack: () => Navigator.of(context).pop(false),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: PG.canvas,
                  borderRadius: BorderRadius.circular(PG.radius),
                  border: Border.all(color: PG.border),
                ),
                child: Icon(
                  _isBluetooth ? Icons.bluetooth : Icons.photo_camera_outlined,
                  size: 32,
                  color: PG.magenta,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: PG.plum,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: const TextStyle(fontSize: 16, height: 1.5, color: PG.body),
              ),
              const Spacer(),
              PgButton(
                label: 'Continue',
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 4),
              PgTextButton(
                label: 'Not now',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
