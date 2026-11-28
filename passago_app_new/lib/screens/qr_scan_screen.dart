import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'permission_explainer_screen.dart';

/// Opens the QR check-in: the camera explanation (once), then the scan screen.
Future<void> openQrScan(BuildContext context, AppState state) async {
  if (!state.cameraExplained) {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            const PermissionExplainerScreen(kind: PermissionKind.camera),
      ),
    );
    if (accepted != true) return;
    state.cameraExplained = true;
  }
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => const QrScanScreen()),
  );
}

/// Proof of arrival: the driver scans the QR code posted at the terminal to
/// join the queue.
///
/// PROTOTYPE: the camera and the real QR check are added in the next phase.
/// For now "Simulate scan success" stands in for scanning the demo QR code.
class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  void _simulateScan(BuildContext context) {
    final state = AppScope.of(context);
    if (state.joinQueue()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const QrSuccessScreen()),
      );
    } else {
      showInfoSnack(context, 'You cannot join the queue right now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PG.scanBackdrop,
      appBar: AppBar(
        backgroundColor: PG.scanBackdrop,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Join the queue',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const SizedBox(
                width: 260,
                height: 260,
                child: CustomPaint(
                  painter: _ScanFramePainter(),
                  child: Center(
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 72,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Align the QR code at the terminal within the frame.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.4, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                MockData.terminalName,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const Spacer(),
              const Text(
                'Demo mode: the camera is not connected yet.',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 10),
              PgButton(
                label: 'Simulate scan success',
                onPressed: () => _simulateScan(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Four corner brackets around the scan area.
class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    const arm = 40.0;
    final w = size.width;
    final h = size.height;

    void corner(Offset a, Offset b, Offset c) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy),
        paint,
      );
    }

    corner(const Offset(0, arm), const Offset(0, 0), const Offset(arm, 0));
    corner(Offset(w - arm, 0), Offset(w, 0), Offset(w, arm));
    corner(Offset(0, h - arm), Offset(0, h), Offset(arm, h));
    corner(Offset(w - arm, h), Offset(w, h), Offset(w, h - arm));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Shown right after a successful scan.
class QrSuccessScreen extends StatelessWidget {
  const QrSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final position = state.myPosition;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(Icons.check_circle, size: 64, color: PG.magenta),
              const SizedBox(height: 20),
              const Text(
                'You joined the queue',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: PG.plum,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                position == null
                    ? 'You are in the line.'
                    : 'Your position: #$position',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: PG.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'When you load your first passenger, count them with +1 or '
                'the handlebar button. You will leave the queue and the trip '
                'starts.',
                style: TextStyle(fontSize: 15, height: 1.45, color: PG.body),
              ),
              const Spacer(),
              PgButton(
                label: 'Back to dashboard',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
