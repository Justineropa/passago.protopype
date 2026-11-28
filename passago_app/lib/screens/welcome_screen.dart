import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

/// Screen 1 of 6: Welcome.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PG.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    36,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Entrance(
                    delayMs: 60,
                    child: Row(
                      children: [
                        PgLogo(size: 36),
                        SizedBox(width: 10),
                        Text(
                          'PassaGo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: PG.plum,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Entrance(
                    delayMs: 140,
                    child: Text(
                      'Wait Less.\nRide Fair.',
                      style: TextStyle(
                        fontSize: 40,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: PG.plum,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Entrance(
                    delayMs: 220,
                    child: Text(
                      'PassaGo organizes terminal passenger dispatch so that '
                      'drivers who have received fewer passengers are '
                      'prioritized in the queue.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: PG.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Entrance(
                    delayMs: 300,
                    child: _Feature(
                      icon: Icons.sync_alt,
                      title: 'Fair rotation queue',
                      text: 'Automatic turn priority based on passengers served.',
                    ),
                  ),
                  const Entrance(
                    delayMs: 380,
                    child: _Feature(
                      icon: Icons.schedule,
                      title: 'Scheduled shifts',
                      text: 'Choose morning (AM) or afternoon (PM) dispatch hours.',
                    ),
                  ),
                  const Entrance(
                    delayMs: 460,
                    child: _Feature(
                      icon: Icons.receipt_long,
                      title: 'Trip records',
                      text: 'Clear daily trip history and recorded fare totals.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Entrance(
                    delayMs: 540,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: PG.muted),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            MockData.terminalName,
                            style: TextStyle(fontSize: 13, color: PG.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Entrance(
                    delayMs: 600,
                    child: Column(
                      children: [
                        PgButton(
                          label: 'Get started',
                          onPressed: () => _openLogin(context),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have a Driver ID?',
                              style: TextStyle(fontSize: 14, color: PG.body),
                            ),
                            TextButton(
                              onPressed: () => _openLogin(context),
                              style: TextButton.styleFrom(
                                foregroundColor: PG.magenta,
                                minimumSize: const Size(48, 48),
                              ),
                              child: const Text(
                                'Log in',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PG.border),
            ),
            child: Icon(icon, size: 22, color: PG.magenta),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PG.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: PG.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
